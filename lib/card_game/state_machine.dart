part of card_game;

typedef bool StateFunc (Command cmd);


//need a flow controler
typedef bool CommandHandler(Command e);
typedef bool EventHandler(e);



class AITagger{

//  final String name;
  final int value;
  const AITagger([this.value=0]);
  
  String toString() => "$value";
  
  bool operator > (AITagger tagger){
//    if(name != tagger.name) return false;
//    if(name == "") return false;
    return value > tagger.value;
  }
  
  bool operator >= (AITagger tagger){
//    if(name != tagger.name) return false;
    return value >= tagger.value;
  }
  
  bool operator < (AITagger tagger){
//    if(name != tagger.name) return false;
    return value < tagger.value;
  }
  
  bool operator <= (AITagger tagger){
//    if(name != tagger.name) return false;
    return value <= tagger.value;
  }
  

  

  
}




class State  {

  final Condition _cond;

  final GameModel _model;
  final int sender;
  final bool blockOthers;

  final Set<AITagger> _ai=new Set<AITagger>();
  //Set<AITagger> get ai =>_ai;
  bool operator << (AITagger tagger){
    return _ai.add(tagger);
  }
  
  bool operator >> (AITagger tagger){
    return _ai.remove(tagger);
  }
  
  bool operator [] (AITagger tagger){
    return _ai.contains(tagger);
  }
  
  void train(AITagger tag, int cid, double prob){
    //for(var tag in _ai){
      //tag._train(sender,cid);
      //void _train(int sender, int cid){
    while(_model._prob.length <= sender) {
      _model._prob.add(new Map<AITagger,Map<int,double>>());
    }
    if(! _model._prob[sender].containsKey(tag)) _model._prob[sender][tag]=new Map<int,double>();
    if(! _model._prob[sender][tag].containsKey(cid)) _model._prob[sender][tag][cid]=0.0;
    _model._prob[sender][tag][cid]+=2;
    //print(prob);
      //}
    //}
  }
  
  String _title;
  String get title{
    return (_patent!=null && !_patent.title.startsWith("請等候"))? ( _patent.title + " ==> " + _title) : _title ; 
  }
  
  void set title(String title){
    _title=title;
    _dirtyTitle=true;
  }
  
  bool _dirtyTitle=true;
  bool _dirtyState=true;
  
  final List<String> _btns;
  List<String> get btns=>_btns;
  
  void leave(){
    _died=true;
  }
  
  State _patent=null;
  DoubleLinkedQueue<State> _stateQueue=new DoubleLinkedQueue<State>();
  
  State pushState(State state){
    _stateQueue.addFirst(state);
    state._patent=this;
  }
  
  State addState(State state){

    _stateQueue.addLast(state);
    state._patent=this;
  }
  
  State removeState(State state){
    _stateQueue.remove(state);
    state._patent=null;
  }
  

//  void join(StateMachine sm){
//   sm.pushState(this); 
//  }
//  
//  void insert(StateMachine sm){
//    sm.addState(this);
//  }
//  
//  void leave(){
//    if(_patent!=null){
//      _patent.removeState(this);
//    }
//  }
  
  bool _first=true;
  bool _died=false;
  
  EventHandler _init=null;
  EventHandler _end=null;  
  EventHandler _check=null;  
  CommandHandler _action=null;
  
  void init(EventHandler handler){
    _init=handler;
  }
  

  void end(EventHandler handler){
    _end=handler;
  }
  
  void check(EventHandler handler){
    _check=handler;
  }
  
  void action(CommandHandler handler){
    _action=handler;
  }
  
  
  //1 當她排到前面時馬上執行   所謂前面的定義對每個使用者不同
  //2 當她離他時執行
  //3  主要迴圈
  
//  State operator >> (State state){
//    State list= new State._('list',HOST,this.title,this._btns,this._cond,this.blockOthers)
//    ..addState(this)
//    ..addState(state);
//    list.init((cmd){
//      list.leave();
//    });
//    return list;
//  }
  
  
  
//  final List<>
  
  State._(this._model,this.sender,this._title,this._btns,this._cond,this.blockOthers);
  
  
  
  
  bool validate(Command cmd){
    return _cond.test(cmd);
  }
  
  
  List<AllowClickCard> getAllowCommands(GameModel model){
    var move=new List<AllowClickCard>();
    //var data={'sender':sender};
    for(int uid=-1;uid<model.userNum;uid++){
      var user=model[uid];
      //data['uid']=uid;
      //Command userCmd=new UserCommand._(data);
      
      //if(validate(userCmd)){
      //print(data);
      for(int did=0;did<user.deckNum;did++){
        var deck=user[did];
        int max=deck.getSeeNum(sender);
        //data['did']=did;
        //print (max);
        //Command deckCmd=new DeckCommand._(data);
        
       // if(validate(deckCmd)){
        for(int pos=0;pos<max;pos++){
//          int max=deck.maxShow;
//          if(max!=0 && pos>=max)break;
          //data['pos']=pos;
          //data['cid']=model[uid][did][pos].cid;
          Command cardCmd=new CardCommand._create(sender,uid,did,pos,model[uid][did][pos].cid);
          if(validate(cardCmd)){
            move.add(new AllowClickCard(uid, did, pos));
//                {
//              'op':'clickCard',
//              'uid':uid,
//              'did':did,
//              'pos':pos,
//            });
          }
        }
        //  }
          
       // }
      }
    }
//    for(int bid=0;bid<5;bid++){
//      data['bid']=bid;
//      Command buttonCmd=new ButtonCommand._(data);
//      if(validate(buttonCmd)){
//        move.add({          
//          'op':'clickButton',
//          'bid':bid,
//        });
//      }
//    }
    return move;
  }
  
}

class AllowClickCard{
  final int uid;
  final int did;
  final int pos;
  AllowClickCard(this.uid,this.did,this.pos);
  toString(){
    return "$uid $did $pos";
  }
  
  factory AllowClickCard.fromString(String str){
    var vals=str.split(' ').map((s)=>int.parse(s)).toList();
    return new AllowClickCard(vals[0], vals[1], vals[2]);
  }
}

//class 

abstract class Condition{
  AndCondition operator & (Condition cond){
    return new AndCondition(this,cond);
  }
  
  OrCondition operator | (Condition cond){
    return new OrCondition(this,cond);
  }
  
  NotCondition operator ~ (){
    return new NotCondition(this);
  }  
  
  bool test(Command cmd);
  
  static final Condition SELF=new SelfCondition();

  //static final Condition BUTTON=new IsButtonCondition(3);
  
  static final Condition WAIT = new NoCondition();

}


class NoCondition extends Condition{
  bool test(Command cmd) {
    return false;
  }
}

class NotCondition extends Condition{
  final NotCondition cond;
  NotCondition(this.cond);
  bool test(Command cmd){
    return !cond.test(cmd);
  }
}

class UserCondition extends Condition{
  final int uid;
  UserCondition(this.uid);
  bool test(CardCommand cmd){
    return cmd.uid==uid;
  }
}

class SelfCondition extends Condition{
  SelfCondition();
  bool test(CardCommand cmd){
    return cmd.uid==cmd.sender;
  }
}

class DeckCondition extends Condition{
  final int did;
  DeckCondition(this.did);
  bool test(CardCommand cmd){
    return cmd.did==did;
  }
}

typedef bool CardTester(int cid);

class CardCondition extends Condition{
  final CardTester cardTester;
  CardCondition(this.cardTester);
  bool test(CardCommand cmd){
    return cardTester(cmd.cid);
  }
}

class CardIDCondition extends Condition{
  final int cid;
  CardIDCondition(this.cid);
  bool test(CardCommand cmd){
    return cmd.cid==cid;//command.did==CardDef;
  }
}

class CardPosCondition extends Condition{
  final int pos;
  CardPosCondition(this.pos);
  bool test(CardCommand cmd){
    return cmd.pos==pos;//command.did==CardDef;
  }
}

//class IsButtonCondition extends Condition{
//  final int max;
//  IsButtonCondition(this.max);
//  bool test(Command cmd){
//    return cmd is ButtonCommand && cmd.bid<max;
//  }
//}
//
//class ButtonCondition extends Condition{
//  final int bid;
//  ButtonCondition(this.bid);
//  bool test(Command cmd){
//    return cmd is ButtonCommand && cmd.bid==bid;
//  }
//}


abstract class ComplexCondition extends Condition{
  //List<Condition> _conditions=new List<Condition>();
  final Condition a,b;
  ComplexCondition(this.a,this.b);
//  add(Condition cond){
//    _conditions.add(cond);
//  }
}

//class AnyCondition extends ComplexCondition{
//  bool test(Command cmd){
//    return _conditions.any((cond)=>cond.test(cmd));
//  }
//}
//
//class EveryCondition extends ComplexCondition{
//  bool test(Command cmd){
//    return _conditions.every((cond)=>cond.test(cmd));
//  }
//}

class OrCondition extends ComplexCondition{
  OrCondition(Condition a, Condition b) : super(a, b);
  bool test(Command cmd){
    return a.test(cmd) || b.test(cmd);
  }
}

class AndCondition extends ComplexCondition{
  AndCondition(Condition a, Condition b) : super(a, b);
  bool test(Command cmd){
    return a.test(cmd) && b.test(cmd);
  }
}

class Command{
  //static String
  final int sender;
  //final State state;
  //final GameModel _model;
  //int uid;
  
  factory Command(data){
    String cmd=data['cmd'];
    switch(cmd){
      case 'clickCard':
        return new CardCommand._(data);
        //break;
      
      case 'clickButton':
        return new ButtonCommand._(data);
        break;

      case 'clickUser':
        //return new UserCommand._(data);
        break;      
      
      default:
        
        break;
    }
    //return new CardCommand({});
  }
  
  Command._(data):sender=data['sender'];
  Command._create(this.sender); 
   
}

//////目前還沒有需求
//class UserCommand extends Command{
//  final int uid;
//  UserCommand._(data)
//    :super._(data),
//    uid=data['uid'];
//  
//  UserCommand._create(int sender,this.uid):super._create(sender);
//}
//
//////目前還沒有需求
//class DeckCommand extends UserCommand{
//  final int did;
////  final DeckModel deck;
//  DeckCommand._(data)
//    :super._(data),
//    did=data['did'];
////    deck=data['deck'];
//  
//  DeckCommand._create(int sender,int uid,this.did):super._create(sender,uid);
//}

class CardCommand extends Command{
  final int uid;
  final int did;
  final int cid;
  final int pos;
//  final CardModel card;
  CardCommand._(data)
    :super._(data),
    uid=data['uid'],
    did=data['did'],
    pos=data['pos'],
    cid=data['cid'];
//    card=data['card'];
  
  CardCommand._create(int sender,this.uid,this.did,this.pos,this.cid):super._create(sender);
  
  String toString(){
    return "uid:$uid did:$did pos:$pos";
  }
}

class ButtonCommand extends Command{
  final int bid;
  ButtonCommand._(data)
    :super._(data),
    bid=data['bid'];
  
  String toString(){
    return "[$sender] btn: $bid";
  }
}


