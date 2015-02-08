part of card_game;

abstract class Commander  {
  final int uid;
//  final CardGame _game;
  final StreamController _commands=new StreamController();
  void add(data){
    //print(data);
    _commands.add(data);
  }
  Commander._(this.uid){

  }

//  void changeModel(op) {
//    changes.add(op);
//  }
}



class UserCommander extends Commander{
  final StreamController _changes=new StreamController();
  Stream get changes=>_changes.stream;
  UserCommander._(int uid):super._(uid){

  }


}


class ComputerCommander extends Commander{
  final AI ai;
  final CardGame _game;
  final GameModel _model;
  ComputerCommander._(int uid,this.ai,CardGame game):
    super._(uid),
    _game=game,
    _model=game.model{
    ai._model=_model;
    ai._uid=uid;
  }
  
  void _invoke(State state){
    if(_game.computerDelay!=0){
      Timer t=new Timer(new Duration( milliseconds:_game.computerDelay), (){
        _calculateCommand(state);
      });
    }else{
      _calculateCommand(state);
    }
  }
  
  Random rand=new Random();
  
  //同menu 一起傳送 可操作範圍，
  void _calculateCommand(State state){

    //if(ai.model.getValue("OVER")==1)return;
//    var op=data['op'];
//    if(op=='menu'){
      String title=state.title;
      //print(title);
      if(title.startsWith("請等候"))return;
      //print(data['title']);
      List<AllowClickCard> cmds=state.getAllowCommands(_model);

      var btns=state.btns;
      if(cmds==null || cmds.length==0){
        if(btns==null)return;
        add({
          'cmd':'clickButton',
          'bid':0}
        );
        return;
      }
      
      
      
      add(ai.calculateCommand(state));

      

//    }
    
  }
  
  
}

abstract class AI{
  int _uid;
  int get uid=>_uid;
  GameModel _model;
  GameModel get model=>_model;
  AI();
  calculateCommand(State state);
}



