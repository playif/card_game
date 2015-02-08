part of card_game;


//class CardDef{
//  final int set;
//  final int cid;
//  const CardDef(this.set,this.cid);
//}

const int LAST_CARD = -1;
const int FIRST_CARD = 0;


const int HOST = -1;
Random _rand;

class Visible {
  final int showCard;

  //0:自己看不到  1:自己看的到 2:別人看的到
  final int showNum;

  //0:自己看不到  1:自己看的到 2:別人看的到

  final int max;
  final int min;

  const Visible._(this.showCard, {this.max: 100, this.min: 0, this.showNum: 0});


  Visible._fromJson(data)
  : this._(data['showCard'], showNum: data['showNum'], max: data['max'], min: data['min']);

}

class Info {
  final String key;
  final int value;

  Info(this.key, this.value);
}

//class

//包含可以操作的狀態
//for both server and client usage, but client only has part of information
class GameModel {

  final List<UserModel> _users = new List<UserModel>();

  //  final Map<String,int> _global=new Map<String,int>();
  final StreamController<String> _logs = new StreamController<String>();

  //  final List<CardDef> _cardDef=new List<CardDef>();

  //final List<DominionUserModel> users=new List<DominionUserModel>();
  UserModel _host;

  bool _start = false;

  bool get start => _start;

  String title = "Welcome!";
  final List<String> btns = new List<String>();
  Set<String> cmds = new Set<String>();

  UserModel get host => _host;

  int _id = HOST;

  int get id => _id;

  bool get hasValue {
    return this[HOST].hasValue;
  }


  static Map<AITagger, Map<int, double>> s_prob = new Map<AITagger, Map<int, double>>();
  final List<Map<AITagger, Map<int, double>>> _prob = new List<Map<AITagger, Map<int, double>>>();


  void plus(int sender) {
    for (var tag in _prob[sender].keys) {
      for (var cid in _prob[sender][tag].keys) {
        double times = _prob[sender][tag][cid];
        if (!s_prob.containsKey(tag)) s_prob[tag] = new Map<int, double>();
        if (!s_prob[tag].containsKey(cid)) s_prob[tag][cid] = .0;
        s_prob[tag][cid] += times;
      }

    }
  }

  void minus(int sender) {
    for (var tag in _prob[sender].keys) {
      for (var cid in _prob[sender][tag].keys) {
        double times = _prob[sender][tag][cid];
        if (!s_prob.containsKey(tag)) s_prob[tag] = new Map<int, double>();
        if (!s_prob[tag].containsKey(cid)) s_prob[tag][cid] = .0;
        s_prob[tag][cid] -= times;
      }

    }
  }


  //Map<String,int> get global=new Map<String,int>();
  //  int get defNum=>_cardDef.length;


  //  List<Info> _infoView=new List<Info>();
  //  _updateInfo(){
  //    _infoView=new List<Info>();
  ////    _infoView.addAll(_global);
  //    _infoView=this[HOST]._map.keys.map((s){
  //      return new Info(s,this[HOST]._map[s]);
  //    }).toList();
  //    if(id==null || id==-1)return;
  ////    _infoView.add("--");
  ////    _infoView.addAll(_users[id]._map.keys.map((s){
  ////      return "$s => ${_users[id]._map[s]}";
  ////    }));
  //
  //  }

  //  List<Info> info()=>_infoView;

  Stream<String> get logStream => _logs.stream;

  //  _updateLogs(){
  //    int i=0;
  //    _logs.removeRange(min( 100,_logs.length), _logs.length);
  ////    _logsView=_logs.map((s){
  ////      i++;
  ////      return "$i: $s";
  ////    }).toList();
  //
  //    _logsView=_logs.map((String s){
  //      List data=new List();
  //      for(var m in s.split('@')){
  //        var d={'text':m};
  //        for(var n in _cardDef){
  //          if(m.startsWith( .n.cid)){
  //            d['img']=true;
  //            break;
  //          }
  //        }
  //        data.add(d);
  //      }
  //
  //      //RegExp exp=new RegExp(r"@{\w+}", caseSensitive:false );
  //
  ////      for (Match m in exp.allMatches(s)) {
  ////        String match = m.group(0);
  ////        match=match.substring(2,match.length-1);
  ////        //print(match);
  ////      }
  //
  //
  //
  //      return data;
  //
  //  }
  //List<String> logs()=>_logsView;
  //  Function procLog;


  //  CardDef def(int cid){
  //    return _cardDef[cid];
  //  }


  List<UserModel> toList() {
    return _users;
  }

  List<UserModel> get users {
    return _users;
  }

  int _currentUser = 0;

  int get currentUser => _currentUser;

  int get userNum => _users.length;

  int getValue(String key) {
    if (this[HOST]._map.containsKey(key)) {
      return this[HOST]._map[key];
    }
    return null;
  }

  UserModel operator [](int id) {
    if (id == HOST) {
      return _host;
    } else {
      return _users[id];
    }
  }

  //  void operator []=(String key,int value){
  //    _global[key]=value;
  //  }


  GameModel() {
    _host = new UserModel._(HOST, this);
  }


  //create insert delete

  changeModel(data) {
    String op = data['op'];
    //print(data);
    switch (op) {
      case 'setup':
        int users = data['users'];
        int seed = data['seed'];
        _id = data['uid'];

        _rand = new Random(seed);
        //use common rand seed;

        for (int i = 0; i < users; i++) {
          UserModel user = new UserModel._(i, this);
          _users.add(user);
        }
        break;
      case 'start':
        _start = true;
        break;
      case 'newDeck':
        int uid = data['uid'];
        DeckModel deck = new DeckModel._(uid, new Visible._fromJson(data['vis']), this);

        this[uid]._add(deck);

        break;
      case 'insertCard':
        int uid = data['uid'];
        int did = data['did'];
        int pos = data['pos'];
        int cid = data['cid'];
        int set = data['set'];

        DeckModel deck = this[uid][did];

        if (cid != -1) {
          CardModel card = new CardModel._(cid, this);
          deck._insert(pos, card);
        }

        deck._cardNum++;

        break;
      case 'removeCard':
        int uid = data['uid'];
        int did = data['did'];
        int pos = data['pos'];
        //card Info index

        DeckModel deck = this[uid][did];

        if (pos != -1) {
          deck._remove(pos);
        }

        deck._cardNum--;

        break;

      case 'moveCard':
        int uid1 = data['uid1'];
        int did1 = data['did1'];
        int pos1 = data['pos1'];
        //card pos index
        int uid2 = data['uid2'];
        int did2 = data['did2'];
        int pos2 = data['pos2'];
        //card pos index



        DeckModel deck1 = this[uid1][did1];
        DeckModel deck2 = this[uid2][did2];

        CardModel card = deck1._remove(pos1);

        //print("$card");

        deck1._cardNum--;
        deck2._insert(pos2, card);
        deck2._cardNum++;
        break;


      case 'shuffle':
        int uid = data['uid'];
        int did = data['did'];


        this[uid][did]._shuffle();
        break;

      case 'setValue':
        String key = data['key'];
        int value = data['value'];
        int uid = data['uid'];
        int did = data['did'];
        //print(uid);
        if (uid != null) {
          if (did != null) {
            this[uid][did]._map[key] = value;
          } else {
            this[uid]._map[key] = value;
          }
        } else {
          this[HOST]._map[key] = value;
        }
        //        if(id!=null && id!=-1){
        //          _updateInfo();
        //        }
        break;

      case 'log':
      //print (data);
        String msg = data['msg'];
        _logs.add(msg);
        //_updateLogs();
        break;

      case 'menu':
        title = data['title'];
//        if (btns != null) {
//          btns.clear();
//        }
        btns.clear();
        if(data['btns'] != null){
          for(var btn in data['btns']){
            btns.add(btn);
          }
        }
        //btns = data['btns'];
        //print("b: $btns");
        break;
      case 'allow':
        cmds = new Set<String>();
        var list = data['cmds'];
        if (list != null) {
          for (var l in list) {
            cmds.add(l);
            //print(l);
            //cmds["${l['uid']},${l['did']},${l['pos']}"]=true;
          }
        }
        break;
    }
  }

}

class Value {
  //  final Visible visible;
  final GameModel model;

  Value(this.model);

  final Map<String, Value> _values = new Map<String, Value>();

  int _value;


  int operator +(int val) {
    return _value + val;
  }

  int operator -(int val) {
    return _value - val;
  }

  Value operator <<(int val) {
    _value = val;
    return this;
  }

  Value operator [](String key) {
    if (!_values.containsKey(key)) return null;
    return _values[key];
  }

  void operator []=(String key, int val) {
    _values[key]._value = val;
  }

  void _newVal(String key, [value = 0]) {
    //    Value val=new Value();

    //    val._value=value;
    //    _values[key]=val;
  }
//  int operator = (){
//
//  }
}

//class _Value{
//
//  _Value(this.visible);
//}

class UserModel {
  final GameModel model;
  final List<DeckModel> _decks = new List<DeckModel>();
  final Map<String, int> _map = new Map<String, int>();


  final int uid;

  UserModel._(this.uid, this.model);

  bool get hasValue {
    return _map.length != 0;
  }

  DeckModel operator [](int id) => _decks[id];


  int get deckNum => _decks.length;

  void _add(DeckModel deck) {
    deck._did = _decks.length;
    _decks.add(deck);
  }

  List<DeckModel> toList() {
    return _decks;
  }

  List<DeckModel> get decks {
    return _decks;
  }


  int getValue(String key) {
    if (_map.containsKey(key)) {
      return _map[key];
    }
    return null;
  }

  void _setValue(String key, int value) {
    _map[key] = value;
  }
}


class DeckModel {
  final GameModel model;
  final List<CardModel> _cards = new List<CardModel>();
  //List<CardModel> _cardsCache = new List<CardModel>();

  final Map<String, int> _map = new Map<String, int>();
  final Visible _visible;
  final int _uid;

  int _did;

  int get did => _did;

  String _type;

  int _cardNum = 0;

  CardModel operator [](int pos) {
    if (pos == LAST_CARD) return _cards.last;
    return _cards[pos];
  }

  //int get number=>_cards.length;

  int get showCard => _visible.showCard;

  int get showNum => _visible.showNum;

  int get maxShow => _visible.max == 0 ? _cards.length : min(_cards.length, _visible.max);

  int get minShow => _visible.min;

  int get cardNum => _cardNum;

  bool get hasCard => _cardNum > 0;

  bool get hasValue {
    return _map.length != 0;
  }

  int getSeeNum(int sender) {
    bool self = (sender == _uid);
    if ((self && showCard != 0) || (!self && showCard == 2)) {
      return maxShow;
    }
    return 0;
  }

  DeckModel._(this._uid, this._visible, this.model);


  //  List<CardModel> toList([max = 100]) {
  //    return _cards.take(max).toList();
  //  }

  List<CardModel> get cards {
    //    print(max);
    //    if(maxShow==0){
    //      return _cards;
    //    }
    //    else {
    //      return _cards.skip(max(_cards.length-maxShow,0)).toList();
    //    }

    return _cards;
  }


  List<int> scanCard(bool test(i)) {
    //_cards.where(test).map(f)
    List<int> results = new List<int>();
    for (int i = 0; i < _cards.length; i++) {
      if (test(_cards[i].cid)) {
        results.add(i);
      }
    }
    return results;
  }

  //List<CardModel> _cards=new List<CardModel>();

  //  bool isUser(UserModel u){
  //    return _uid==u.id;
  //  }

  bool isType(String type) {
    return _type == type;
  }

  //  CardModel _newCard(cid){
  //    CardModel c=new CardModel(cid);
  //    _cards.add(c);
  //    return c;
  //  }

  //  _add(CardModel card){
  //    _cards.add(card);
  //  }

  _insert(int index, CardModel card) {
    card._uid = _uid;
    card._did = _did;
    card._pos = index;
    _cards.insert(index, card);

    //updateCache();
  }

  //  void _removeCard(CardModel c){
  //    _cards.remove(c);
  //  }

  CardModel _remove(int pos) {
    CardModel card = _cards.removeAt(pos);
    //updateCache();
    return card;
  }

//  void updateCache() {
//    if (maxShow == 0) {
//      _cardsCache = _cards;
//    } else {
//      _cardsCache = _cards.skip(max(_cards.length - maxShow, 0)).toList();
//    }
//  }

  //  CardModel getCard(int pos){
  //    return _cards[pos];
  //  }

  void _shuffle() {
    for (int i = 0; i < _cards.length; i++) {
      int r = _rand.nextInt(_cards.length);
      var c = _cards[i];
      _cards[i] = _cards[r];
      _cards[r] = c;
    }
  }

  int getValue(String key) {
    if (_map.containsKey(key)) {
      return _map[key];
    }
    return null;
  }

  void _setValue(String key, int value) {
    _map[key] = value;
  }

}

class CardModel {
  final GameModel _model;
  final int cid;
  int _uid;
  int _did;
  int _pos;

  GameModel get model => _model;

  //  final int set;

  int get uid => _uid;

  int get did => _did;

  //TODO cid

  int get pos {
    return _model[uid][did].cards.indexOf(this);
  }

  CardModel._(this.cid, this._model);
}
