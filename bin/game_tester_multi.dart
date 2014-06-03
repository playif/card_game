
import 'dart:async';
import 'dart:isolate';
//import 'dart:convert';
//import 'dart:collection';


import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';


main(){
  ReceivePort rp=new ReceivePort();
  DateTime now = new DateTime.now();
  List threads=[];
  //eight-core
  for(int i=0;i<8;i++){
    //Timer timer=new Timer(new Duration(),run);
    
    threads.add(Isolate.spawn(run,rp.sendPort));
    //{'gid':i,'port':rp.sendPort}
  }

  Future.wait(threads).then((s){
    
    
    int count=0;

    rp.listen((data){
      //print("Game[${data['gid']}]:");
//      for(int i=0;i<data['pn'];i++){
//        //print("玩家$i得到${data['$i']}分。");
//      }
      count++;
      if(count>=4000){
        DateTime fin = new DateTime.now();
        num time=(fin.millisecondsSinceEpoch-now.millisecondsSinceEpoch)/1000;
        rp.close();
        print("共花費$time秒:");
      }
    });
    
  });


}

void run(SendPort port){
  //int gid=msg['gid'];
  //SendPort port=msg['port'];
  //send.send("hi");
  //List threads=[];
  
  for(int i=0;i<500;i++){
    var game=new DominionGame();
    List<AI> ais=<AI>[new DominionAI(),new DominionAI()];
    
    
    for(int i=0;i<ais.length;i++){
      game.createComputer(ais[i]);
    }
    
    Future result=game.setup();
    result.then((model){
      //var data={'gid':gid,'pn':ais.length};
      //print("Game[$gid]:"); 
      for(int i=0;i<ais.length;i++){
        int score=model[i].getValue("victory");
        //data['$i']=score;
        //print("玩家$i得到$score分。");
      }
      port.send(model);
  
    });
  }
}





