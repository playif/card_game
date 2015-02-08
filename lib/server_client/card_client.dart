library card_client;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import '../card_game/card_game.dart';

import 'package:angular/angular.dart';


@Injectable()
class Client {
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);
  bool _onLine;
  UserCommander _comm;
  GameModel clientModel;
  GameModel get model{
    return clientModel;
  }
  
  bool _connectPending = false;
  WebSocket _socket;

  void clickCard(CardModel card) {
    sendCommand({
        'cmd': 'clickCard',
        'uid': card.uid,
        'did': card.did,
        'pos': card.pos,
    });
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

  }

}