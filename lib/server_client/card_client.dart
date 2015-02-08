library card_client;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import '../card_game/card_game.dart';

import 'package:angular/angular.dart';

class Room{
  String name;
  int currentPlayer;
  int maxPlayer;
  Room(this.name,this.currentPlayer,this.maxPlayer){

  }

}

@Injectable()
class Client {
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);
  bool _onLine;
  UserCommander _comm;
  GameModel clientModel;
  GameModel get model{
    return clientModel;
  }
  String state='disConnected';
  
  bool _connectPending = false;
  WebSocket _socket;

  int userNum=0;
  String msg='';

  List<Room> rooms=new List<Room>();

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

  void sendString(str) {
    _socket.send(str);
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
  
  connectToServer(){
    _onLine=true;
    clientModel=new GameModel();
    _connectPending = false;
    _socket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');
    
    _socket.onOpen.first.then((e) {
      state = 'connected';
      //_socket.send("username");
      _socket.onMessage.listen((e) {
        var data = JSON.decode(e.data);
        if(data['op'] != null){
          clientModel.changeModel(data);
        }
        else{
          if(data['info'] != null ){
            if(data['info']['usernum'] != null){
              userNum=data['info']['usernum'];
            }
            if(data['info']['msg'] != null){
              msg=data['info']['msg'];

              if(msg == 'ok'){
                state='lobby';
                rooms.add(new Room("name1",1,4));
                rooms.add(new Room("name2",2,3));
              }

            }
          }
        }

      });
      _socket.onClose.first.then((e) {
        state = 'disConnected';
        print("Connection disconnected to ${_socket.url}");
        _onDisconnected(e);
      });
    });
    _socket.onError.first.then((e) {
      _onDisconnected(e);
    });


  }


  void _onDisconnected(d) {
    if (_connectPending) return;
    _connectPending = true;
    new Timer(RECONNECT_DELAY, connectToServer);
  }

}