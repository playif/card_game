import 'package:angular/angular.dart';
import 'package:perf_api/perf_api.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:collection';


import 'package:card_game/server_client/card_client.dart';
import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';
import 'ui/ui.dart';

import 'dart:async';

const int SINK = 0;
const int HAND = 1;
const int TABLE = 2;
const int TRUNK = 3;


Point mp = new Point(0, 0), cp;
int scroll;
//List<String> names=<String>["Copper","Silver"];
//@NgFilter(name: 'cardNameFilter')
//class CardNameFilter{
//  call(List<String> list){
//    return list.map((String s){
//      List data=new List();
//      for(var m in s.split('@')){
//        var d={'text':m};
//        for(var n in names){
//          if(m.startsWith(n)){
//            d['img']=true;
//            break;
//          }
//        }
//        data.add(d);
//      }
//
//      //RegExp exp=new RegExp(r"@{\w+}", caseSensitive:false );
//
////      for (Match m in exp.allMatches(s)) {
////        String match = m.group(0);
////        match=match.substring(2,match.length-1);
////        //print(match);
////      }
//
//
//
//      return data;
//      //return {'type':1,'name':s};
//    }).toList();
//  }
//}

//@NgService()
//class s1{
//  
//}

final Client _client = new Client();

class ClientService{
  void clickCard(CardModel card) {
    _client.sendCommand({
      'cmd': 'clickCard',
      'uid': card.uid,
      'did': card.did,
      'pos': card.pos,
    });
  }
}



@NgController(selector: '[card-game]', publishAs: 'c')
class GameController {
  final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];

  GameModel model;
  DominionCardDef curCard;
  //String hi="hi";

  GameController() {
    //DivElement div=new DivElement();
    var game = new DominionGame();
    var ais = [new DominionAI(), new DominionAI(), new DominionAI()];
    game.computerDelay = 50;
    for (int i = 0; i < ais.length; i++) {
      game.createComputer(ais[i]);
    }
    _client.createLoaclGame(game);
    //_client.createOnlneGame();

    model = new GameModel();
    Timer wait = new Timer(new Duration(milliseconds: 500), setup);
    //setup();

    window.onMouseMove.listen((s) {
      mp = s.client;
      cp = s.screen;
      //hindCard();
      //Point sp=s.screen;
      //scroll=table.scrollTop;
      //print("${mp.y} ${cp.y} ${sp.y} ${table.scrollTop}");
    });
    //    if(_client is ClientToRemote){
    //      _client.OnDisConnect(disConnect);
    //    }


    //$('').html('');
  }
  //_client=new ClientHandler();



  //  String seg(String str)
  //  {
  //    return str+"hi";
  //  }

  //  DominionCardDef getDef(int cid){
  //    CardDef cd=model.def(cid);
  //
  //    //print(cd.set);
  //    return CardSet.def[cd.set][cd.cid];
  //  }

  String getCardStyle(CardModel card) {
    if (card == null) return "";
    if (model.cmds.contains("${card.uid} ${card.did} ${card.pos}")) {
      return "canSelectRedInset";
    } else {
      return "";
    }
  }


  
  Map<String,String> background={
     'float': 'left',
     'cursor': 'pointer',
     'width': '40px',
     'height': '60px',
     'background-size': '100% 100%'
  };

  Map<String,String> getBackground(int cid) {
    //if (cid == null) return "";
    
    background['background-image']= "url('${getSmallImg(cid)}')";
    //print("url('${getSmallImg(cid)}')");
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
    //print(model.id);
    //print(model.id);
    if (model.id == null) return null;
    //    print("here${model.id}");
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

  void clickCard(CardModel card) {
//    print({
//      'cmd': 'clickCard',
//      'uid': card.uid,
//      'did': card.did,
//      'pos': card.pos,
//    });
    _client.sendCommand({
      'cmd': 'clickCard',
      'uid': card.uid,
      'did': card.did,
      'pos': card.pos,
    });
    hindCard();
  }

  void clickButton(int bid) {
    _client.sendCommand({
      'cmd': 'clickButton',
      'bid': bid,
    });
  }



  void showCard(int cid) {
    var tip = querySelector('#tipCard');
    int rx = (mp.x + 400) > window.screen.width ? mp.x - 240 : mp.x + 220;
    int ry = (mp.y + 450) > window.screen.height ? mp.y - 200 : mp.y + 20;
    //int rx=window.screen.width-200;
    //int ry=window.screen.height-450;
    tip.style.left = "${rx}px";
    tip.style.top = "${ry}px";
    tip.style.display = "inline";
    //tip.clientTop=my;

    curCard = CardSet.def(cid);
  }

  void hindCard() {
    var tip = querySelector('#tipCard');
    tip.style.display = "none";
  }

  void onMessage(e) {
    var data = JSON.decode(e.data);
    model.changeModel(data);
    //print(e);
  }

  //  GameModel disConnect(e) {
  //    print("disconnect");
  //    var game=new DominionGame();
  //    //_client=new ClientToLocal(game);
  //    setup();
  //    return model;
  //  }

  //  void setupSinglePlayer(){
  //    var game=new DominionGame();
  //
  //    Commander commander=new UserCommander(0,game);
  //    game.addCommander(commander);
  //    game.setup();
  //  }

  void setup() {

    model = _client.clientModel;
    //var game=new DominionGame();

    //Commander commander=new UserCommander(0,game);
    //game.addCommander(commander);
    //game.setup();
    //model=game.model;

    //model=_client.clientModel;//new GameModel();

    //print(e);
    var logs = querySelector('#logs');
    logs.children.clear();


    model.logStream.listen((s) {
      var logs = querySelector('#logs');
      //print(logs);
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
      //List data=new List();
      //print(s);

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
                var img = new ImageElement(src: 'img/75px-$name.jpg', width: 30,
                    height: 48);
                if (cid != -1) {
                  img.onMouseOver.listen((s) {
                    showCard(cid);
                  });
                }
                img.onMouseOut.listen((s) {
                  hindCard();
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
            //stack.last.text+=token;
            //stack.last.attributes['']+=token;
            break;
        }
      }
      check();
      logs.children.insert(0, div);
      //logs.scrollByPages(100);
      //return data;
    });

    //print('here');
    var input = querySelector("#inputBox") as TextAreaElement;
    input.onInput.listen((s) {
      if (input.value.contains('\n')) {
        _client.sendCommand({
          'cmd': 'talk',
          'msg': input.value,
        });
        input.value = "";
      }
      //      if(!s.shiftKey && s.keyCode==KeyCode.ENTER){
      //        sendCommand({
      //          'cmd':'talk',
      //          'msg':input.value,
      //        });
      //
      //      }

      //print(s.data);
    });


  }
}


class GameModule extends Module {
  GameModule() {
    type(GameController);
    type(Profiler, implementedBy: Profiler);
    type(HostUI);
    type(UserUI);
    type(DeckUI);
    type(CardUI);
    type(ClientService);    
    //type(CardNameFilter); // comment out to enable profiling
  }
}


void main() {
  //  Dropdown.use();
  //  Tooltip.wire(element)

  var logs = querySelector("#logs");
  DivElement info = querySelector("#info") as DivElement;
  var input = querySelector("#inputBox") as TextAreaElement;
  input.onKeyPress.listen((s) {
    if (!s.shiftKey && s.keyCode == 13) {

    }
  });

  void adjustLayout() {
    var rect = info.getBoundingClientRect();
    logs.style.height =
        "${window.innerHeight-info.clientHeight-input.clientHeight}px";
  }

  //  info.addEventListener("resize", (e){
  //    print("here");
  //    adjustLayout();
  //  },true);

  window.onResize.listen((s) {
    adjustLayout();
  });

  window.onLoad.first.then((s) {
    adjustLayout();

  });

  //var table=querySelector("#table");
  //  window.onMouseMove.listen((s){
  //    mp=s.client;
  //    cp=s.screen;
  //    //Point sp=s.screen;
  //    //scroll=table.scrollTop;
  //    //print("${mp.y} ${cp.y} ${sp.y} ${table.scrollTop}");
  //  });

  ngBootstrap(module: new GameModule());
}
