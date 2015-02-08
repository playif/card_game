library dominion;

import 'card_game/card_game.dart';
import 'dart:math';


part 'dominion_game.dart';
part 'dominion_ai.dart';


class CardType {
  static const TRESURE = const CardType._(0x0001);
  static const VICTORY = const CardType._(0x0002);
  static const ACTION = const CardType._(0x0004);
  static const REACTION = const CardType._(0x0008);
  static const ATTACK = const CardType._(0x0010);
  static const CURSE = const CardType._(0x0020);


  static const TRESURE_ACTION = const CardType._(0x0001 + 0x0004);
  static const ACTION_REACTION = const CardType._(0x0004 + 0x0008);
  static const ACTION_ATTACK = const CardType._(0x0004 + 0x0010);

  //TODO assign the values
  static const DURATION = const CardType._(1);
  static const PRIZE = const CardType._(1);
  static const LOOTER = const CardType._(1);
  static const RUINS = const CardType._(1);
  static const KNIGHT = const CardType._(1);
  static const SHELTER = const CardType._(1);

  //static get values => [APPLE, BANANA];

  final int _value;

  bool hasType(CardType type) {
    return _value & type._value == type._value;
  }

  ///只要有包含就是相等
  bool operator [] (CardType type){
    return _value & type._value == type._value;
  }

  //CardType operator +(CardType type)=>const CardType._(1);

  const CardType._(this._value);

//  CardType operator + (CardType type){
//    return const CardType._(_value+type._value);
//  }

}


class CardTypeCondition extends Condition {
  final CardType type;

  CardTypeCondition(this.type);

  bool test(Command command) {
    if (command is CardCommand) {
      return CardSet.def(command.cid).types[type];
      //command.did==CardDef;
    }
    return false;
  }
}

class CardCostCondition extends Condition {
  final int maxCost;
  final int minCost;

  CardCostCondition(this.maxCost, [this.minCost=0]);

//    maxCost = (max != null) ?max:min,
//    minCost = (max != null) ?min:0;
  bool test(Command command) {
    //print("hi");
    if (command is CardCommand) {

      return CardSet.def(command.cid).cost <= maxCost &&
      CardSet.def(command.cid).cost >= minCost;
      //command.did==CardDef;
    }
    return false;
  }
}

class CanBuyCondition extends Condition {
  final GameModel model;

  CanBuyCondition(this.model);

  bool test(Command command) {
    if (command is CardCommand) {
      return CardSet.def(command.cid).cost <= model.getValue(GOLD) &&
      model.getValue(BUY) >= 1;
      //command.did==CardDef;
    }
    return false;
  }
}

abstract class Conds extends Condition {

  static final Condition ButtonOnly = Condition.WAIT;

  static final Condition SUPPLY = new UserCondition(HOST) & new CardPosCondition(0);

//  static final Condition SUPPLY_CAN_BUY=SUPPLY & new CardCondition((s){
//    var doc=CardSet.def(s);
//    return doc.attacked!=null;
//  });

  static final Condition HAND_CARD = Condition.SELF & new DeckCondition(HAND);

  static final Condition REVEALS = new NotCondition(new UserCondition(HOST)) & new DeckCondition(REVEAL);

//  static Condition BUTTON_HAND= Condition.BUTTON | SELF_HAND;

  static final Condition HAND_SUPPLY = HAND_CARD | SUPPLY;

  static final Condition TRESURE = new CardTypeCondition(CardType.TRESURE);
  static final Condition ACTION = new CardTypeCondition(CardType.ACTION);

  static final Condition HAND_ACTION = HAND_CARD & ACTION;

  static final Condition HAND_TRESURE = HAND_CARD & TRESURE;

  static final Condition HAND_ACTION_TRESURE = HAND_CARD & (TRESURE | ACTION);

  static final Condition HAND_VICTORY = HAND_CARD & new CardTypeCondition(CardType.VICTORY);
  static final Condition HAND_ATTACKED = HAND_CARD & new CardCondition((s) {
    var doc = CardSet.def(s);
    return doc.attacked != null;
  });


  static final Condition COST_UP_TO_1 = new CardCostCondition(1);
  static final Condition COST_UP_TO_2 = new CardCostCondition(2);
  static final Condition COST_UP_TO_3 = new CardCostCondition(3);
  static final Condition COST_UP_TO_4 = new CardCostCondition(4);
  static final Condition COST_UP_TO_5 = new CardCostCondition(5);

//  static final Condition BUTTON=Condition.BUTTON;
//  static final Condition BUTTON_1=new ButtonCondition(1);
//  static final Condition BUTTON_2=new ButtonCondition(2);
//  static final Condition BUTTON_3=new ButtonCondition(3);

  static final Condition COPPER = new CardIDCondition(0);
  static final Condition SILVER = new CardIDCondition(1);
  static final Condition GOLD = new CardIDCondition(2);
  static final Condition CURSE = new CardIDCondition(6);
//  static Condition sender(int sender)=>new SenderCondition(sender);

//static Condition
}


typedef void onPlay(DominionGame model, Command cmd);

typedef bool effectCB(data);

typedef bool endCB();

typedef int onVictory(DominionGame model);

typedef void onAttacked(DominionGame model, Command cmd);


class DominionCardDef {
  final CardType types;
  final String text;
  final int cost;
  final int pCost;
  final int cardNum;
  final String name;
  final int score;

  final bool playTrash;

  final onPlay play;
  final onPlay discard;
  final onPlay attacked;
  final onVictory victory;

  DominionCardDef(this.name, this.cost, this.text, this.types, onPlay this.play, {
  this.pCost:0, this.cardNum:10, this.score:0, this.attacked:null, this.discard:null,
  this.victory:null, this.playTrash:false
  }) {

  }


}


///卡片的定義，基本上建議盡量使用DominionGame定義的API，以確保對應的觸發事件被正確執行。
class CardSet {

  static final basic = [
      new DominionCardDef("Copper", 0, "", CardType.TRESURE, (DominionGame game, cmd) {
        game[GOLD] += 1;
      }, cardNum:60),
      new DominionCardDef("Silver", 3, "", CardType.TRESURE, (DominionGame game, cmd) {
        game[GOLD] += 2;
      }, cardNum:40),
      new DominionCardDef("Gold", 6, "", CardType.TRESURE, (DominionGame game, cmd) {
        game[GOLD] += 3;
      }, cardNum:30),
      new DominionCardDef("Estate", 2, "", CardType.VICTORY, (game, cmd) {
      }, score:1, cardNum:24),
      new DominionCardDef("Duchy", 5, "", CardType.VICTORY, (game, cmd) {
      }, score:3, cardNum:24),
      new DominionCardDef("Province", 8, "", CardType.VICTORY, (game, cmd) {
      }, score:6, cardNum: 12),
      new DominionCardDef("Curse", 0, "", CardType.CURSE, (game, cmd) {
      }, score:-1, cardNum:30),
  ];

  static final dominion = [
      //no 1
      new DominionCardDef("Cellar", 2, "", CardType.ACTION, (DominionGame game, Command cmd) {
        //第三版重構
        //臨時性的'全域'變數(以這張卡片的所有動作來說)。
        int draw = 0;

        State state = game.createActionState("地窖--請選擇要捨棄的牌", btns: ['結束']);
        //此state 第一次可見時會執行。
        state.init((e) {
          game[ACTION] += 1; //將執行寫在裡面確保順序正確。
          if (game.getHandNum() == 0) {
            state.leave();
          }
        });

        //此state 結束時會執行。
        state.end((e) {
          game.drawCard(game[USER], draw);
          return true;
        });

        //處理使用者的互動。
        state.action((Command cmd) {
          if (cmd is CardCommand) {
            game.discardCard(cmd.uid, HAND, cmd.pos);
            draw++;
            if (game.getHandNum() == 0) {
              state.leave();
            }
          }
          else if (cmd is ButtonCommand) {
            state.leave();
          }
        });
        //把此state push 到目前最優先執行的佇列。
        game.pushState(state);

      }),
      //no 2
      new DominionCardDef("Chapel", 2, "", CardType.ACTION, (DominionGame game, Command cmd) {
        int trash = 0;

        State state = game.createActionState("教堂--請選擇要捨棄的牌", btns:['結束']);
        state.action((cmd) {
          if (cmd is CardCommand) {
            trash++;
            game.trashCard(cmd.uid, HAND, cmd.pos);
            if (trash >= 4)state.leave();
          }
          else if (cmd is ButtonCommand) {
            state.leave();
          }
        });

        game.pushState(state);
      }),
      //no 3
      new DominionCardDef("Moat", 2, "", CardType.ACTION_REACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER], 2);
          state.leave();
        });
        game.pushState(state);
        //不是很安全的寫法，不確定未來。
//      game.loop(2, (i){
//        game.drawCard(game[USER]);
//      });
      }, attacked:(DominionGame game, CardCommand cmd) {
        game.setUserValue(cmd.uid, "Moat", 1);
      }),

      //no 4
      new DominionCardDef("Chancellor", 3, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createActionState("請選擇是否將抽排堆的牌置入棄牌堆",
        cond:Conds.ButtonOnly,
        btns:['是', '否']);
        state.init((e) {
          game[GOLD] += 2;
        });
        state.action((ButtonCommand cmd) {
          if (cmd.bid == 0) {
            game.moveAllCard(game[USER], DRAW, game[USER], TRUNK);
          }
          state.leave();
        });
        game.pushState(state);
      }),

      //no 5
      new DominionCardDef("Village", 3, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER]);
          game[ACTION] += 2;
          //print('here');
          state.leave();
        });
        game.pushState(state);
      }),
      //no 6
      new DominionCardDef("Woodcutter", 3, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game[BUY] += 1;
          game[GOLD] += 2;
          state.leave();
        });
        game.pushState(state);
      }),
      //no 7
      new DominionCardDef("Workshop", 3, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createActionState("工坊--請選擇要獲得的牌",
        cond:Conds.SUPPLY & Conds.COST_UP_TO_4);
        state.action((CardCommand cmd) {
          game.gainCardFromSupply(cmd.did);
          state.leave();
        });
        game.pushState(state);
      }),
      //no 8

      new DominionCardDef("Bureaucrat", 4, "", CardType.ACTION_ATTACK, (DominionGame game, CardCommand cmd) {

        State wait = game.createWaitState();
        wait.init((e) {
          game.gainCardFromSupply(1, DRAW);
          wait.leave();
        });

        game.loop(game.model.userNum, (uid) {
          if (uid == game[USER]) return;

          State attack = game.createAttackState(uid, '官員--請選擇要捨棄的牌',
          cond:Conds.HAND_VICTORY);

          attack.init((e) {
            if (!game.hasType(uid, CardType.VICTORY)) {
              game.msg(HOST, "~${uid};no victory card.");
              attack.leave();

            }
//          else{
//            
//           
//          }
          });
          attack.action((CardCommand cmd) {
            //print("here");
            game.moveCard(cmd.uid, HAND, cmd.pos, cmd.uid, DRAW, LAST_CARD);
            game.msg(HOST, "~${cmd.uid};將@${cmd.cid};放回抽排堆。");
            attack.leave();
            //wait.leave();

          });

          wait.pushState(attack);
        });


        game.pushState(wait);

      }),

      //no 9
      new DominionCardDef("Feast", 3, "", CardType.ACTION, (DominionGame game, Command cmd) {

        State state = game.createActionState("饗宴--請選擇要獲得的牌",
        cond:Conds.SUPPLY & Conds.COST_UP_TO_5);
        state.action((CardCommand cmd) {

          game.gainCardFromSupply(cmd.did);
          state.leave();
        });
        game.pushState(state);

      }, playTrash:true),

      //no 10
      new DominionCardDef("Gardens", 4, "", CardType.VICTORY, (DominionGame game, Command cmd) {
      }, victory:(DominionGame game) {
        return game.model[ game[USER]][TRUNK].cardNum / 10;
      }, cardNum:12),

      //no 11
      new DominionCardDef("Militia", 4, "", CardType.ACTION_ATTACK, (DominionGame game, Command cmd) {

        //int wNum=game.model.userNum-1;
        State wait = game.createWaitState("義勇軍");
        wait.init((e) {
          game[GOLD] += 2;
          wait.leave();
        });

        game.loop(game.model.userNum, (uid) {
          if (uid == game[USER]) return;
          State attack = game.createAttackState(uid, "請將手牌捨棄至剩下三張",
          cond:Conds.HAND_CARD
          );
          attack.check((e) {
            if (game.model[uid][HAND].cardNum <= 3) {
              //game.msg(HOST,"~${uid}; has less than 3 cards.");
              attack.leave();
            }
          });
          attack.action((CardCommand cmd) {
            game.discardCard(cmd.uid, HAND, cmd.pos);
            game.msg(HOST, "~${cmd.uid};捨棄@${cmd.cid};。");
          });
          wait.addState(attack);

        });
        game.pushState(wait);

      }),
      //no 12
      new DominionCardDef("Moneylender", 4, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          var cards = game.scanCard(game[USER], HAND, (doc) => doc.name == "Copper");
          if (cards.length > 0) {
            int pos = cards.first;
            game.trashCard(game[USER], HAND, pos);
            game[GOLD] += 3;
            //print("here");
          }
          //print("there");
          state.leave();
        });
        game.pushState(state);

      }),
      //no 13
      new DominionCardDef("Remodel", 4, "", CardType.ACTION, (DominionGame game, CardCommand cmd) {

        //cmd.pos

        int cost = 0;
        State pick = game.createActionState("重構--請選擇要捨棄的牌",
        cond:Conds.HAND_CARD);
        pick.check((e) {
          if (game.model[cmd.uid][cmd.did].cardNum == 0) {
            pick.leave();
          }
        });


        pick.action((CardCommand cmd) {

          game.trashCard(cmd.uid, HAND, cmd.pos);
          cost = CardSet.def(cmd.cid).cost + 2;
          pick.leave();

          State gain = game.createActionState("重構--請選擇要獲得的牌(Cost<=$cost)",
          cond:Conds.SUPPLY & new CardCostCondition(cost));

          gain.action((CardCommand cmd) {
            game.gainCardFromSupply(cmd.did);
            gain.leave();
          });

          game.pushState(gain);

        });


        //gain.push()

        //先執行 pick 再執行 gain
        game.pushState(pick);

      }),

      //no 14
      new DominionCardDef("Smithy", 4, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER], 3);
          state.leave();
        });
        game.pushState(state);

      }),

      //no 15
      new DominionCardDef("Spy", 4, "", CardType.ACTION_ATTACK, (DominionGame game, CardCommand cmd) {


        //int wNum=game.model.userNum;

        State spy = game.createActionState("間諜--請選擇要捨棄的牌(未選擇的牌會放回抽牌堆)",
        cond:Conds.REVEALS,
        btns:['結束']);

        spy.init((e) {
          game.drawCard(game[USER], 1);
          game[ACTION] += 1;
        });

        spy.action((cmd) {
          if (cmd is CardCommand) {
            //print("spy_cc: ${cmd.uid}");
            game.moveCard(cmd.uid, cmd.did, cmd.pos, cmd.uid, TRUNK, LAST_CARD);
            //var doc=CardSet.def(cmd.cid);
          }
          else if (cmd is ButtonCommand) {
            game.loop(game.model.userNum, (i) {
              //print("spy_i: $i");
              game.endReveal(i, DRAW);
            });
            spy.leave();
          }
        });


        game.loop(game.model.userNum, (uid) {
          //print("$uid ${cmd.sender}");
          //if(uid == cmd.sender) return;
          State reveal = game.createAttackState(uid, "間諜--你的抽牌堆將被翻開一張。", invoke: uid != game[USER]);
          reveal.init((s) {
            //print("spy: $uid");
            game.revealCard(uid, DRAW);
            //print("hi");
            reveal.leave();
          });
          spy.pushState(reveal);
        });


        game.pushState(spy);
      }),

      //no 16
      new DominionCardDef("Thief", 4, "", CardType.ACTION_ATTACK, (DominionGame game, CardCommand cmd) {

        int wNum = game.model.userNum;

        State thief = game.createActionState("小偷--請選擇要移除(或偷取)的牌",
        cond:Conds.REVEALS & Conds.TRESURE,
        btns:['結束']);
        thief.check((e) {
          //檢查檯面有無未處理的寶藏。
          if (!game.model.toList().any((user) {
            return game.scanCard(user.uid, REVEAL, (c) => c.types[CardType.TRESURE]).length >= 1;
          })) {
            thief.leave();
          }
        });
        //});
        thief.action((cmd) {
          if (cmd is CardCommand) {

            State chose = game.createActionState("是否將該卡片放入你的牌堆?",
            cond:Conds.ButtonOnly,
            btns:['是', '否']);
            chose.action((ButtonCommand btn) {
              if (btn.bid == 0) {
                game.gainCardFromUser(cmd.uid, cmd.did, cmd.pos);
              }
              else {
                game.removeCard(cmd.uid, cmd.did, cmd.pos);
                //game.moveCard(cmd.uid, cmd.did, cmd.pos, cmd.uid, TRUNK, LAST_CARD);
              }
              game.endReveal(cmd.uid, TRUNK);
              chose.leave();
            });

            thief.pushState(chose);


            //var doc=CardSet.def(cmd.cid);
          }
          else if (cmd is ButtonCommand) {
            game.loop(game.model.userNum, (i) {
              game.endReveal(i, DRAW);
            });
            thief.leave();
          }
        });

        game.loop(game.model.userNum, (uid) {
          if (uid == game[USER]) return;
          State reveal = game.createAttackState(uid, "小偷--你的抽牌堆將被翻開2張。");
          reveal.init((s) {
            game.revealCard(uid, DRAW, LAST_CARD, 2);

            //先把所有不是寶藏的卡放入棄牌堆。
            //TODO　會有ｂｕｇ　(當抽到兩張寶藏的時候 會 RangeError:)，要改成一次移除一張。 (先用reversed 可能可解決)
            game.scanCard(uid, REVEAL, (c) => !c.types[CardType.TRESURE]).reversed.forEach((pos) {
              game.moveCard(uid, REVEAL, pos, uid, TRUNK);
            });

            reveal.leave();
          });
          thief.pushState(reveal);
        });


        game.pushState(thief);
      }),


      //no 17
      new DominionCardDef("Throne_Room", 4, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createActionState("請選擇要搭配的行動牌 (被選擇的牌會執行兩次)",
        cond: Conds.HAND_ACTION);

        state.check((e) {
          if (!game.hasType(game[USER], CardType.ACTION)) {
            state.leave();
          }
        });
        state.action((CardCommand cmd) {
          DominionCardDef doc = CardSet.def(cmd.cid);
          if (doc.playTrash) {
            game.trashCard(cmd.uid, HAND, cmd.pos);
          }
          else {
            game.discardCard(cmd.uid, HAND, cmd.pos);
          }

          game.loop(2, (i) {
            doc.play(game, cmd);
          });

          state.leave();
        });

        game.pushState(state);

        //game[GOLD]+=2;
      }),

      //no 18
      new DominionCardDef("Council_Room", 5, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER], 4);
          game[BUY] += 1;
          game.loop(game.model.userNum, (uid) {
            game.drawCard(uid, 1);
          });
          state.leave();
        });

        game.pushState(state);

      }),

      //no 19
      new DominionCardDef("Festival", 5, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game[BUY] += 1;
          game[ACTION] += 2;
          game[GOLD] += 2;
          state.leave();
        });
        game.pushState(state);

      }),

      //no 20
      new DominionCardDef("Laboratory", 5, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER], 2);
          game[ACTION] += 1;
          state.leave();
        });
        game.pushState(state);

      }),

      //no 21
      new DominionCardDef("Library", 5, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.check((e) {

          if (!game.checkDraw(game[USER]) || game.model[game[USER]][HAND].cardNum >= 7) {
            state.leave();

            return;
          }


          game.drawCard(game[USER]);
          //print("here");
          State chose = game.createActionState("請選擇是否將該卡片放入你的牌堆(最右手邊那張)?",
          cond:Conds.ButtonOnly,
          btns:['是', '否']);

          //TODO 只有行動卡可以跳過。
          chose.action((ButtonCommand btn) {

            if (btn.bid == 1) {
              game.moveCard(game[USER], HAND, LAST_CARD, game[USER], REVEAL);
            }
            if (game.model[game[USER]][HAND].cardNum >= 7 || !game.model[game[USER]][DRAW].hasCard) {
              state.leave();
            }
            chose.leave();
          });

          state.pushState(chose);

        });
        state.end((e) {
          game.endReveal(game[USER], TRUNK);
        });


        game.pushState(state);

      }),


      //no 22
      new DominionCardDef("Market", 5, "", CardType.ACTION, (DominionGame game, Command cmd) {
        State state = game.createWaitState();
        state.init((e) {
          game.drawCard(game[USER], 1);
          game[ACTION] += 1;
          game[BUY] += 1;
          game[GOLD] += 1;
          state.leave();
        });
        game.pushState(state);

      }),


      //no 23
      new DominionCardDef("Mine", 5, "", CardType.ACTION, (DominionGame game, CardCommand cmd) {
        int cost = 1;
        State pick = game.createActionState("礦坑--請選擇要捨棄的寶藏",
        cond:Conds.HAND_TRESURE);
        pick.check((e) {
          if (game.model[game[USER]][cmd.did].cardNum == 0) {
            pick.leave();
          }
          if (!game.hasType(game[USER], CardType.TRESURE)) {
            pick.leave();
          }
        });
        pick.action((cmd) {
          if (cmd is CardCommand) {
            game.trashCard(cmd.uid, HAND, cmd.pos);
            cost = CardSet.def(cmd.cid).cost + 3;
            pick.leave();

            State gain = game.createActionState("礦坑--請選擇要獲得的寶藏(Cost<=$cost)",
            cond:Conds.SUPPLY & Conds.TRESURE & new CardCostCondition(cost));
            gain.init((e) {
              var allows = gain.getAllowCommands(game.model);
              //print(allows);
              if (allows.length == 0) {
                //print("hi");
                gain.leave();
              }
            });
            gain.action((CardCommand cmd) {
              game.gainCardFromSupply(cmd.did, HAND);
              gain.leave();
            });
            game.pushState(gain);
          }
        });


        //先執行 pick 再執行 gain
        game.pushState(pick);

      }),


      //no 24
      new DominionCardDef("Witch", 5, "", CardType.ACTION_ATTACK, (DominionGame game, Command cmd) {

        //int wNum=game.model.userNum-1;
        State wait = game.createWaitState("女巫");
        wait.init((e) {
          game.drawCard(game[USER], 2);
          wait.leave();
        });

        game.loop(game.model.userNum, (uid) {
          if (uid == game[USER]) return;
          State attack = game.createAttackState(uid, "你將獲得1張詛咒");
          attack.init((e) {
            game.gainCardFromSupply(6, TRUNK, uid);
            attack.leave();
          });
          wait.addState(attack);

        });
        game.pushState(wait);

      }),

      //no 25
      new DominionCardDef("Adventurer", 6, "", CardType.ACTION, (DominionGame game, Command cmd) {
        int treasure = 0;
        State state = game.createWaitState();
        state.init((e) {
          while (true) {
            if (!game.checkDraw(game[USER]) || treasure >= 2) {
              state.leave();
              return;
            }
            game.drawCard(game[USER], 1);
            var doc = CardSet.def(game.model[game[USER]][HAND][LAST_CARD].cid);
            if (doc.types[CardType.TRESURE]) {
              treasure++;
            }
            else {
              game.moveCard(game[USER], HAND, LAST_CARD, game[USER], REVEAL);
            }

            //print("here");


          }
        });
        state.end((e) {
          game.endReveal(game[USER], TRUNK);
        });
        game.pushState(state);

      }),

  ];


  static final prosperity = [
      //no 1
      new DominionCardDef("Loan", 3, "", CardType.TRESURE, (DominionGame game, CardCommand cmd) {
        State state = game.createActionState("", cond:Conds.ButtonOnly);
        state.init((e) {
          game[GOLD] += 1;
          while (true) {
            if (!game.checkDraw(game[USER])) {
              game.endReveal(game[USER], TRUNK);
              state.leave();
              //print("hi");
              return;
            }
            game.revealCard(game[USER], DRAW);
            var doc = CardSet.def(game.model[game[USER]][REVEAL][LAST_CARD].cid);

            if (doc.types[CardType.TRESURE]) {

              State chose = game.createActionState("請選擇如何處置該寶藏?",
              cond:Conds.ButtonOnly,
              btns:['捨棄', '移除']);
              chose.action((ButtonCommand btn) {
                if (btn.bid == 1) {
                  game.trashCard(game[USER], REVEAL);
                }
                else {
                  game.discardCard(game[USER], REVEAL);
                  //game.moveCard(cmd.uid, cmd.did, cmd.pos, cmd.uid, TRUNK, LAST_CARD);
                }
                game.endReveal(game[USER], TRUNK);
                //game.endReveal(cmd.uid, TRUNK);
                chose.leave();
                state.leave();
              });

              state.pushState(chose);
              return;

            }
          }
        });
        game.pushState(state);

      }),

      //no 2
      new DominionCardDef("Loan", 3, "", CardType.TRESURE, (DominionGame game, CardCommand cmd) {
        State state = game.createActionState("");
        state.init((e) {
          game[GOLD] += 1;
          while (true) {
            if (!game.checkDraw(game[USER])) {
              game.endReveal(game[USER], TRUNK);
              state.leave();
              return;
            }
            game.revealCard(game[USER], DRAW);
            var doc = CardSet.def(game.model[game[USER]][REVEAL][LAST_CARD].cid);
            print(doc.name);
            if (doc.types[CardType.TRESURE]) {

              State chose = game.createActionState("請選擇如何處置該寶藏?",
//                cond:Conds.BUTTON,
              btns:['移除', '捨棄']);
              chose.action((ButtonCommand btn) {
                if (btn.bid == 0) {
                  game.trashCard(game[USER], REVEAL);
                }
                else {
                  game.discardCard(game[USER], REVEAL);
                  //game.moveCard(cmd.uid, cmd.did, cmd.pos, cmd.uid, TRUNK, LAST_CARD);
                }
                game.endReveal(game[USER], TRUNK);
                //game.endReveal(cmd.uid, TRUNK);
                chose.leave();
                state.leave();
              });

              state.pushState(chose);
              return;

            }
          }
        });
        game.pushState(state);

      }),
  ];

  static final _cards = [basic, dominion, prosperity];

  static int get length {
    return SUM(_cards, (Iterable s) => s.length);
  }

  static DominionCardDef def(int cid) {
    int set = 0;
    while (cid >= _cards[set].length) {
      cid -= _cards[set].length;
      set++;
    }

    return _cards[set][cid];
  }

}


