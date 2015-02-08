
import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';


main(){

  DateTime now = new DateTime.now();
  List<Future> threads=<Future>[];
  var body=querySelector('body');
  for(int i=0;i<1000;i++){
    var game=new DominionGame();
    List<AI> ais=<AI>[new DominionAI(),new DominionAI()];
    
    
    for(int i=0;i<ais.length;i++){
      ComputerCommander comm=game.createComputer(ais[i]);
    }

    threads.add(game.setup());
  }

  Future.wait(threads).then((s){
    DateTime fin = new DateTime.now();
    num time=(fin.millisecondsSinceEpoch-now.millisecondsSinceEpoch)/1000;
    body.appendText('$time');
    
  });

  

}




