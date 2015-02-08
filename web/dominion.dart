import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';


import 'dart:html';
import 'dart:convert';
import 'dart:collection';


import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';
import 'package:card_game/server_client/card_client.dart';
import 'package:card_game/ui/ui.dart';


const int SINK = 0;
const int HAND = 1;
const int TABLE = 2;
const int TRUNK = 3;


Point mp = new Point(0, 0);
int scroll;


@Injectable()
class DominionClient extends GameClient {

  final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];
  String playerName;

  void login(){
//    if(playerName == null){
//      playerName = "player-$userNum";
//    }
    print(playerName);

    sendString(playerName);
  }

  void joinRoom(Room room){

  }

  int rating = 3;

  DominionClient() {
    void createLocalGame() {
      var game = new DominionGame();
      var ais = [new DominionAI()];//, new DominionAI(), new DominionAI()];
      game.computerDelay = 0;
      for (int i = 0; i < ais.length; i++) {
        game.createComputer(ais[i]);
      }
      this.createLoaclGame(game);
    }
    //createLocalGame();
    this.connectToServer();
    //services.createLocalGame();
    setup();


    window.onMouseMove.listen((s) {
      mp = s.client;
    });

  }

  String getCardStyle(CardModel card) {
    if (card == null) return "";
    if (model.cmds.contains("${card.uid} ${card.did} ${card.pos}")) {
      return "canSelectRedInset";
    } else {
      return "";
    }
  }


  Map<String, String> background = {
      'float': 'left',
      'cursor': 'pointer',
      'width': '40px',
      'height': '60px',
      'background-size': '100% 100%'
  };

  Map<String, String> getBackground(int cid) {
    background['background-image'] = "url('${getSmallImg(cid)}')";
    return background;
  }

  String getSmallImg(int cid) {
    return 'img/75px-${CardSet.def(cid).name}.jpg';
  }

  //
  String getLargeImg(int cid) {
    if (cid == null) return null;
    return 'img/200px-${CardSet.def(cid).name}.jpg';
  }

  UserModel get clientUser {
    if (model.id == null) return null;
    return model[model.id];
  }

  int get clientID {
    if (model.users.length == 0) return null;

    return model.id;
  }

  UserModel get currentUser {
    if (model.users.length == 0) return null;
    return model.users[model.getValue(USER)];
  }

  int get currentID {
    return model.getValue(USER);
  }

  String get currentName {
    if (currentID != model.id) {
      return "玩家[${currentID}]";
    } else {
      return "你";
    }
  }

  String getName(int uid) {
    if (uid != model.id) {
      return "玩家[${uid}]";
    } else {
      return "你";
    }
  }

//  void clickCard(CardModel card) {
//    services.sendCommand({
//        'cmd': 'clickCard',
//        'uid': card.uid,
//        'did': card.did,
//        'pos': card.pos,
//    });
//
//  }

  void clickButton(int bid) {
    this.sendCommand({
        'cmd': 'clickButton',
        'bid': bid,
    });
  }

  void onMessage(e) {
    var data = JSON.decode(e.data);
    model.changeModel(data);
  }


  void setup() {

    //model = this.model;

    var logs = querySelector('#logs');
    logs.children.clear();


    model.logStream.listen((s) {
      var logs = querySelector('#logs');
      DoubleLinkedQueue<Element> stack = new DoubleLinkedQueue<Element>();
      var div = new DivElement();
      String temp = "";

      stack.add(div);

      void push(String type) {
        var span = new SpanElement();
        span.title = type;
        stack.last.children.add(span);
        stack.add(span);
      }

      void check() {
        if (temp != "") {
          var span = new SpanElement();
          span.text = temp;
          stack.last.children.add(span);
          temp = "";
        }
      }

      for (String token in s.split('')) {
        switch (token) {
          case '@':
            check();
            push('card');
            break;
          case '%':
            check();
            push('color');
            break;
          case '^':
            check();
            push('size');
            break;
          case ']':
            check();
            stack.removeLast();
            break;
          case '[':
          case ';':
            var span = stack.last;
            switch (span.title) {
              case 'card':
                int cid;
                cid = int.parse(temp, onError: (e) {
                  return -1;
                });
                String name = (cid == -1) ? temp : CardSet.def(cid).name;
                var img = new ImageElement(src: 'img/75px-$name.jpg', width: 30, height: 48);
                if (cid != -1) {
                  img.onMouseOver.listen((s) {
                    //showCard(cid);
                  });
                }
                img.onMouseOut.listen((s) {
                  //hindCard();
                });
                span.children.add(img);
                span.title = name;
                stack.removeLast();
                break;
              case 'color':
                span.style.color = temp;
                span.title = "";
                break;
              case 'size':
                span.style.fontSize = temp + 'px';
                break;
            }
            temp = "";
            break;
          default:
            temp += token;

            break;
        }
      }
      check();
      logs.children.insert(0, div);

    });


    var input = querySelector("#inputBox") as TextAreaElement;
    input.onInput.listen((s) {
      if (input.value.contains('\n')) {
        this.sendCommand({
            'cmd': 'talk',
            'msg': input.value,
        });
        input.value = "";
      }
    });


  }
}


class GameModule extends Module {
  GameModule() {
    bind(GameClient, toInstanceOf:DominionClient);
    bind(HostUI);
    bind(UserUI);
    bind(DeckUI);
    bind(CardUI);
  }
}


void main() {
  applicationFactory()
    ..rootContextType(DominionClient)
    ..addModule(new GameModule())
    ..run();
}

