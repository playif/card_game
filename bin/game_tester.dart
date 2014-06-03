import 'dart:async';


import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';



List threads=[];
Completer cmp=new Completer();
int v1=0;
Future newGame(int x){
  var game=new DominionGame();
  //List<AI> ais=<AI>[new RandomAI(),new RandomAI()];
  List<AI> ais=<AI>[new RandomAI(true),new DominionAI()];
  for(int i=0;i<ais.length;i++){
    game.createComputer(ais[i]);
  }
  Future f=game.setup();
  f.then((GameModel model){
    //print("one");
    int s1=model[0].getValue("victory");
    int s2=model[1].getValue("victory");

    if(s1 >= s2){
      model.plus(0);
      //model.minus(1);
      v1++;
    }
    else{
      model.plus(1);
      //model.minus(0);
    }
    if(x-- > 0){
      newGame(x);
      //print("hi");
    }
    else{
      cmp.complete(v1);
    }
  });
  threads.add(f);
  return cmp.future;
}

main(){
  //ReceivePort rp=new ReceivePort();
  DateTime now = new DateTime.now();

//  for(int i=0;i<1;i++){
//    
//    
//    
//  }
  
  newGame(1000)//;
  
  
  //Future.wait(threads)
    .then((a){
    DateTime fin = new DateTime.now();
    num time=(fin.millisecondsSinceEpoch-now.millisecondsSinceEpoch)/1000;
    int count=0;
    //int v1=0;
//    for(GameModel model in models){
//      //for(int i=0;i<2;i++){
//      int s1=model[0].getValue("victory");
//      int s2=model[1].getValue("victory");
//
//      if(s1 >= s2){
//        v1++;
//        print(s1);
//      }
//      else{
//
//      }
//        //data['$i']=score;
//        //print("玩家$i得到$score分。");
//      //}
//    }
    GameModel.s_prob.keys.forEach((s){
      for(var cid in GameModel.s_prob[s].keys){
        print("${CardSet.def(cid).name} : ${GameModel.s_prob[s][cid]}");
      }
      print("--");
    });
    //print(GameModel.s_prob.length);
    print("共花費$time秒");
    print("P1 won $v1 games.");
    //print(prob);
  });


}






