library card_game;

import 'dart:collection';
import 'dart:math';
import 'dart:async';



part 'card_game_model.dart';
part 'state_machine.dart';
part 'commander.dart';


const AITagger AI_WAIT=const AITagger();


SUM(Iterable seq, [fn(x)]) =>
    seq.fold(0, (prev, element) => prev + (fn != null ? fn(element) : element));

MIN(Iterable seq) =>
    seq.fold(double.MAX_FINITE, (prev, element) => prev.compareTo(element) > 0 ? element : prev);

MAX(Iterable seq) =>
    seq.fold(double.MIN_POSITIVE, (prev, element) => prev.compareTo(element) > 0 ? prev : element);

AVG(Iterable seq) => SUM(seq) / seq.length;


//class Command{
//  Command(String data){
//    
//  }
//}

const String WAIT='waitUser';
const String USER='curUser';
//const String CARD='curCard';

const int ALL_USERS=-1;



// true --> finish
typedef bool Action(Command cmd);



// 處理player input 和 data models
abstract class CardGame{
  
  final GameModel _model=new GameModel();
  final List<UserCommander> _users=new List<UserCommander>(); 
  final List<ComputerCommander> _computers=new List<ComputerCommander>();
  final List<Commander> _commanders=new  List<Commander>();
  
  //List<Commander> get commanders=>_commanders;

//  final Map<String, Action> _actions=new Map<String, Action>();
  final DoubleLinkedQueue<State> _stateQueue=new DoubleLinkedQueue<State>();
  
  
  static final Random rand=new Random(0);
  
  CardGame(){
    //_sockets=new List<WebSocket>();
  }
  

//  Map<int,Map<String,int>> get user{
//    //return model[uid][]
//  }
  
  GameModel get model=>_model;
  

//  _nextTurn(){
//
//  }
  
  UserModel currentUser(){
    return _model[_model.currentUser];
  }
  
  
//  UserModel user(int uid){
//    return _model[uid];
//  }


  

  
//  Deck getArea(bool test(Deck a)){
//    return _areas.where(test).first;
//  }
  
//  Iterable<DeckModel> getDecks(bool test(DeckModel a),{int uid}){
//    return _model._users[uid]._decks.where(test);
//  }
  
  

  
  run(Command cmd,State state){
    if(state._action != null) state._action(cmd);
    state._dirtyState=true;
    _checkStateQueue();
//    if(state==null){
//      state=_stateQueue.first;
//    }
//    if()
//    
//    bool remove=_actions[state.name](cmd);
//    if(remove == true){
//      removeState(state);
//    }
  }
  

  
  //把每個可能會執行到的state 都檢查一遍。
  void _checkStateQueue(){
    //if(dirt==false) return;
    //dirt=false;
    
    for(int i=0;i<_commanders.length;i++){
      Commander comm=_commanders[i];
      State state=getState(comm.uid);
      if(state==null){
        if(comm is UserCommander){
          _sendMenu(comm.uid,{
            'op':'menu',
            'title':'請等候其他玩家...',
          });
          _sendAllow(comm.uid,[]);
        }
        continue;
      }
      
      //if(state.title.startsWith("請選擇要捨棄的牌"))print(state.title);
      if(state._died!=true){
        if(state._check != null){
          state._check(null);
          State newState=getState(comm.uid);
          if(newState!=state){
            _checkStateQueue();
            return;
          }
        }
        if(state._first == true && state._init != null){
          state._init(null);
          state._first=false;
          State newState=getState(comm.uid);
          if(newState!=state){
            _checkStateQueue();
            return;
          }
        }
      }
      if(state._died==true) {
        if(state._end != null) state._end(null);
        _removeState(state);
        _checkStateQueue();
        return;
      }
      
      if(state._dirtyState==true){
        state._dirtyState=false;
        if(comm is UserCommander){
          _setMenu(state);
          _sendAllow(comm.uid,state.getAllowCommands(model));
        }
        else if(comm is ComputerCommander){
          comm._invoke(state);
        }
      }
    }
    //_checkStateQueue(dirt);
  }
  
  void _checkPlayerState(int i){
    
  }
  
  
   
  ///插入一個狀態([name])來接收使用者([user])的資訊，若[blockOthers]為真，則其他使用者必須等待。
  State createState(String title,Condition cond,{
                  List<String> btns,
                  int sender,
                  bool blockOthers:true
                  }){
    if(sender==null){
      sender=this[USER];
    }
//    if(btns!=null){
//      cond|=Condition.BUTTON;
//    }
    State state=new State._(model,sender,title,btns,cond,blockOthers);

    return state;
  }
  
  void pushState(State state){
    _stateQueue.addFirst(state);
    //_checkStateQueue();
  }
  
  void clearState(){
    _stateQueue.clear();
    //_checkStateQueue();
  }
  
  State createWaitState([String title= "請等候其他玩家...", int sender ]){
    State state= createState(title,Condition.WAIT, sender:sender);
    state<<AI_WAIT;
    return state;
  }
  
  State getState(int sender){
    for(State state in _stateQueue){
      if(state._stateQueue.length!=0 && state.blockOthers){
        return _getState(sender,state);
      }
      if(sender==state.sender || state.sender==HOST){
        return _getState(sender,state);
      }
      else if(state.blockOthers){
        break;
      }
    }
    return null;
  }
  
  State _getState(int sender, State state){
    if(state._stateQueue.length==0) return state;
    for(State s in state._stateQueue){
      if(s._stateQueue.length!=0  && s.blockOthers){
        return _getState(sender,s);
      }
      if(sender==s.sender || s.sender==HOST){
        return _getState(sender,s);
      }
      else if(s.blockOthers){
        break;
      }
    }
    return null;
  }
  
  void _removeState(State state){
    if(state._patent == null){
      int sender=state.sender;
      _stateQueue.remove(state);
    }
    else{
      state._patent.removeState(state);
    }
//    state=getState(sender);
//    if(state != null){
//      _setMenu(state);
//    }
//    else{
//      _setMenu(getWaitState(sender));
//    }
    //print(_stateQueue.length);
    //_checkStateQueue();
  }
  
  loop(int times, void func(index)){
    for(int i=0;i<times;i++){
      func(i);
    }
  }
  
  
//  int _getLastUID(){
//    return _users.length+_computers.length;
//  }

  Commander createUser(){
    int uid=_commanders.length;
    UserCommander comm=new UserCommander._(uid);
    _bindCommander(comm);
    _users.add(comm);
    _commanders.add(comm);
    return comm;
  }
  
  int computerDelay=0;
  Commander createComputer(AI ai){
    int uid=_commanders.length;
    ComputerCommander comm=new ComputerCommander._(uid,ai,this);
    _bindCommander(comm);
//    comm._changes.listen((op){
//      comm.ai.model.changeModel(op);
//      
//    });
    _computers.add(comm);
    _commanders.add(comm);
    return comm;
  }
  
  _bindCommander(Commander comm){
    comm._commands.stream.listen((data){
      data['sender']=comm.uid;

      if(data['cmd']=='talk'){
        msg(HOST, "~${data['sender']}說: ${data['msg']}");
        return;
      }
      
      State state=getState(comm.uid);
      if(state==null){
        return;
      }
//      print("${state.title} ${state.sender} ${model[comm.uid][1].cards.map((c){
//        return c.cid;
//      })}");
      if(data['pos']!=null){
        int uid=data['uid'];
        int did=data['did'];
        int pos=data['pos'];

        data['cid']=model[uid][did][pos].cid;

      }

      

      if(state!=null){
        
        var cmd=new Command(data);
        if(data['cmd'] == 'clickButton'){
          if(state.btns ==null) return;
          //print(state.title);
          if(data['bid'] >= state.btns.length) return; 
        }
        else if(!state.validate(cmd)){
          return;
        }
        run(cmd,state);
      }
    });
  }
  
  //需要處理好mask 的問題。
  _broadCast(data){

    
    String op=data['op'];

    
    for(int i=0;i<_users.length;i++){
      UserCommander comm=_users[i];
      
      switch(op){
        case 'setup':
          
          //data['uid']=i;
          //print("a:${comm.uid}");
          comm._changes.add({
            'op':'setup',
            'users':data['users'],
            'seed':data['seed'],
            'uid':comm.uid
          });
          //comm.changeModel(data);
          break;
        case 'newDeck':
        case 'defCard':
          comm._changes.add(data);
          break;
        case 'insertCard':
          int uid=data['uid'];
          int did=data['did'];
          
          _sendInsertCard(comm.uid,uid,did,comm,data);
          
          
          break;
          
        case 'removeCard':
          int uid=data['uid'];
          int did=data['did'];
          
          _sendRemoveCard(comm.uid,uid,did,comm,data);
          
          break;
        case 'moveCard':
          int uid1=data['uid1'];
          int did1=data['did1'];
          int pos1=data['pos1'];
          int uid2=data['uid2'];
          int did2=data['did2'];
          int pos2=data['pos2'];

          bool showCard1=_showCard(comm.uid, uid1, did1);
          //bool showNum1=_showNum(i, uid1, did1);
          
          bool showCard2=_showCard(comm.uid, uid2, did2);
          //bool showNum2=_showNum(i, uid2, did2);
          
          if(showCard1 && showCard2){
            comm._changes.add(data);

          }
          else{

            int cid2=_model[uid1][did1][pos1].cid;
            _sendRemoveCard(comm.uid,uid1,did1,comm,{
              'op':'removeCard',
              'uid':uid1,
              'did':did1,
              'pos':pos1,
            });
            _sendInsertCard(comm.uid,uid2,did2,comm,{
              'op':'insertCard',
              'uid':uid2,
              'did':did2,
              'pos':pos2,
              'cid':cid2,
            });
          }
          
//          comm.changeModel({
//            'op':'log',
//            'msg':"player $uid1 move 1 card from deck $did1 to deck $did2 of player $uid2.",
//          });
          break;
        case 'log':
          int uid=data['uid'];
          if(uid==HOST || uid==comm.uid){
            comm._changes.add(data); 
          }
          break;
        case 'setValue':
          int uid=data['uid'];
          if(uid==null || uid==HOST || uid==comm.uid){
            comm._changes.add(data); 
          }
          break;
//        case 'menu':
//          int uid=data['uid'];
//          if(uid==HOST || uid==comm.uid){
//            comm._changes.add(data); 
//          }
//          break;          
          
        default:
          comm._changes.add(data);
//          comm.changeModel({
//            'op':'log',
//            'msg': data['op'],
//          });
          break;
      }
      
    }
    
    _model.changeModel(data);
  }
  
  
  int createDeck(int uid,vis){
    _broadCast({
      'op':'newDeck',
      'uid':uid,
      'vis':vis
    });
    return _model[uid].deckNum-1;
  }
  
  int operator [](String key)=>_model.getValue(key);
  void operator []=(String key,int value){
    _broadCast({
      'op':'setValue',
      'key':key,
      'value':value,
    });
  }
  
  int getUserValue(int uid,String key)=>_model[uid].getValue(key);
  void setUserValue(int uid, String key,int value){
    _broadCast({
      'op':'setValue',
      'key':key,
      'value':value,
      'uid':uid,
    });
  }
  
  void plusUserValue(int uid, String key,int value){
    int ori=getUserValue( uid,  key);
    setUserValue(uid,key,ori+value);
  }
  
  int getDeckValue(int uid, int did,String key)=>_model[uid][did].getValue(key);
  void setDeckValue(int uid, int did, String key,int value){
    _broadCast({
      'op':'setValue',
      'key':key,
      'value':value,
      'uid':uid,
      'did':did,
    });
  }
  
  void plusDeckValue(int uid, int did, String key,int value){
    int ori=getDeckValue( uid, did,  key);
    setDeckValue(uid,did,key,ori+value);
  }
  
  
  _sendInsertCard(int cur,int uid, int did, UserCommander comm, data){
    bool showCard=_showCard(cur, uid, did);
    bool showNum=_showNum(cur, uid, did);
    if(!showCard){
      if(showNum){
        comm._changes.add({
          'op':'insertCard',
          'uid':uid,
          'did':did,
          'pos':-1,
          'cid':-1
        });
      }

    }
    else{
      comm._changes.add(data);
    }
  }
  
  _sendRemoveCard(int cur,int uid, int did, UserCommander comm, data){
    bool showCard=_showCard(cur, uid, did);
    bool showNum=_showNum(cur, uid, did);
    if(!showCard){
      if(showNum){
        comm._changes.add({
          'op':'removeCard',
          'uid':uid,
          'did':did,
          'pos':-1,
        });
      }
    }
    else{
      comm._changes.add(data);
    }
  }
  
  _showCard(int cur,int uid,int did){
    DeckModel deck=_model[uid][did];
    int showCard = deck.showCard;
    
    bool self = (cur == uid);
    
    return (self && showCard!=0) || (!self && showCard==2);
  }

  _showNum(int cur,int uid,int did){
    DeckModel deck=_model[uid][did];
    int showNum = deck.showNum;
    
    bool self = (cur == uid);
    
    return (self && showNum!=0) || (!self && showNum==2);
  }
  
//  addCommander(Commander commander){
//    _commanders.add(commander);
//  }
  
  start();
  Completer<GameModel> _completer = new Completer();
  Future<GameModel> setup(){
   // this.fin=fin;
    _broadCast({
      'op':'setup',
      'users':_commanders.length,
      'seed':CardGame.rand.nextInt(10000000)
    });

    
    start();
    _checkStateQueue();
    
    return _completer.future;
  }
  
  void endGame(){
    _completer.complete(model);
  }
 
  // TODO send data to client
  enableSelectCard(UserModel user, DeckModel deck, {bool test(CardModel c)}) {
    test= (test != null)? test : (c)=>true;
    
    
    
  }
  
  
  disableSelectCard(UserModel user, DeckModel deck, {bool test(CardModel c)}) {
    test= (test != null)? test : (c)=>true;
  }
  
//  showMenu(UserModel user, Iterable<Button> btns) {
//    
//  }
  
  closeMunu(){
    
  }
  
  enableSelectUser(UserModel user, UserModel target, {bool test(UserModel u)}) {
    test= (test != null)? test : (u)=>true;
  }
  
  disableSelectUser(UserModel user, UserModel target, {bool test(UserModel u)}) {
    test= (test != null)? test : (u)=>true;
  }
  
  
  msg(int uid,msg){
    _broadCast({
      'op':'log',
      'uid': uid,
      'msg': msg,
    });
  }
  
  insertCard(int uid, int did, int cid, [int pos=LAST_CARD]) {
    DeckModel deck=_model[uid][did];
    if(pos==LAST_CARD)pos=deck.cardNum;
    _broadCast({
      'op':'insertCard',
      'uid':uid,
      'did':did,
      'pos':pos,
      'cid':cid,
    });
  }
  
  removeCard(int uid, int did, [int pos=LAST_CARD]) {
    DeckModel deck=_model[uid][did];
    if(pos==LAST_CARD)pos=deck.cardNum-1;
    _broadCast({
      'op':'removeCard',
      'uid':uid,
      'did':did,
      'pos':pos,
    });
  }
  
  shuffle(int uid, int did) {
    _broadCast({
      'op':'shuffle',
      'uid':uid,
      'did':did,
    });
  }
  
  moveCard(int uid1, int did1, int pos1, int uid2, int did2, [int pos2=0]) {
    if(pos1==LAST_CARD){
      pos1=_model[uid1][did1].cardNum-1;
    }
    if(pos2==LAST_CARD){
      pos2=_model[uid2][did2].cardNum;
    }
    //print('Hi2');
    _broadCast({
      'op':'moveCard',
      'uid1':uid1,
      'did1':did1,
      'pos1':pos1,
      'uid2':uid2,
      'did2':did2,
      'pos2':pos2,
    });
  }
  
  startNotification(){
    _broadCast({
      'op':'start',
    });
  }
  
  moveAllCard(int uid1, int did1, int uid2, int did2) {
    DeckModel from=_model[uid1][did1];
    DeckModel to=_model[uid2][did2];
    //print('Hi');
    while(from.hasCard){
      //print(to.hasCard);
      //print(from.cardNum);
      moveCard(uid1,did1,LAST_CARD,uid2,did2,LAST_CARD);
    }
  }
  
  _setMenu(State state,[int uid]){
    if(uid==null)uid=state.sender;
    _sendMenu(uid,{
      'op':'menu',
      'title':state.title,
      'btns':state.btns,
    });
    state._dirtyTitle=false;
  }
  
  _sendMenu(int uid,data){
    if(uid==-1){
      _users.forEach((c){
        c._changes.add(data);       
      });
      return;
    }
    Commander comm=_commanders[uid];
    if(comm is UserCommander){
      comm._changes.add(data);
    }
  }
  
  _sendAllow(int uid, List<AllowClickCard> allows){

    (_commanders[uid] as UserCommander)._changes.add({
      'op':'allow',
      'cmds':allows.map((s)=>s.toString()).toList(),
    });
    
  }
  
  
//  
//  State getWaitState(int sender){
//    return new State._('wait',sender,"請等候其他玩家...",null,new SelfCondition(),true);
//  }
  
  
//  List<int> scanCard(int uid, int did, bool test(c) ) {
//    List<int> results=new  List<int>();
//    model[uid][did].scan
//  }
}

