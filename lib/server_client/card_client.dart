library card_client;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import '../card_game/card_game.dart';

//abstract class Client {
////  GameModel clientModel;
//  Client();
//  
//  void createModel(){
//    clientModel=new GameModel();
//  }
//
////  void onMessage(Event e);
//  void sendCommand(command);
//}

//class ClientToLocal extends Client {
//  final CardGame _game;
//  
//  ClientToLocal(this._game,List<AI> ais){
//    //_game=new DominionGame();
//    createModel();
//    UserCommander commander=new UserCommander(0,_game);
//    commander.changes.stream.listen((op){
//      clientModel.changeModel(op);      
//    });
//    _game.addCommander(commander);
//
//    
//    for(int i=0;i<ais.length;i++){
//      ComputerCommander comm=new ComputerCommander(i+1, _game,ais[i]);
//      comm.changes.stream.listen((op){
//        comm.ai.model.changeModel(op);
//        Timer t=new Timer(new Duration( milliseconds: 50), (){
//          comm.calculateCommand(op);
//        });
//      });
//      _game.addCommander(comm);
//    }
//    
//    _game.setup();
//  }
//
//  void sendCommand(command) {
//    _game.commanders[0].commands.add(command);
//  }
//}


class Client {
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);
  bool _onLine;
  UserCommander _comm;
  GameModel clientModel;
  
  bool _connectPending = false;
  WebSocket _socket;
  
  Client()  {

  }
  
  void sendCommand(command) {
    if(_onLine){
      _socket.send(JSON.encode(command));
    }
    else{
      _comm.add(command);
    }

  }
  
  createLoaclGame(CardGame game){
    _onLine=false;
    clientModel=new GameModel();
    _comm=game.createUser();
    _comm.changes.listen((op){
      clientModel.changeModel(op);      
    });
//    clientModel=game.model;
    game.setup();
  }
  
  createOnlneGame(){
    _onLine=true;
    clientModel=new GameModel();
    _connectPending = false;
    _socket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');
    
    _socket.onOpen.first.then((e) {
      _onConnected();
      _socket.onClose.first.then((e) {
        print("Connection disconnected to ${_socket.url}");
        _onDisconnected(e);
      });
    });
    _socket.onError.first.then((e) {
      _onDisconnected(e);
    });
  }


  void _onConnected() {
    _socket.onMessage.listen((e) {
      //print(e.data);
      clientModel.changeModel(JSON.decode(e.data));
    });
  }

  void _onDisconnected(d) {
    if (_connectPending) return;
    _connectPending = true;
    new Timer(RECONNECT_DELAY, createOnlneGame);
    
    //clientModel=disConnect(d);
  }

}