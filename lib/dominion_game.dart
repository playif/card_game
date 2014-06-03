part of dominion;

const int DRAW = 0;
const int HAND = 1;
const int TABLE = 2;
const int TRUNK = 3;
const int REVEAL = 4;


const String SETUP = 'setup';
//const String PLAY_CARD='playCard';
//const String BUY_CARD='buyCard';
const String EMPTY = 'empty';

const String GOLD = 'gold';
const String ACTION = 'action';
const String BUY = 'buy';

///繼承至CardGame，處理所有Dominion的遊戲流程，並提供較高等級的API (如抽卡[drawCard])。
class DominionGame extends CardGame {

//  DominionCardDef getDef(int cid){
//    CardDef cd=model.def(cid);
//    return CardSet.def[cd.set][cd.cid];
//  }
  bool hasType(int uid, CardType type, [int did=HAND]) {
    return model[uid][did].cards.any((s) {
      var doc = CardSet.def(s.cid);
      return doc.types[type];
    });
  }

  bool hasCard(int uid, int cid, [int did=HAND]) {
    return model[uid][did].cards.any((s) => s.cid == cid);
  }

  bool hasAttacked(int uid) {
    return model[uid][HAND].cards.any((s) {
      var doc = CardSet.def(s.cid);
      return doc.attacked != null;
    });
  }

  void endReveal(int uid, [int did=HAND]) {
    moveAllCard(uid, REVEAL, uid, did);
  }

  State _createAttackedState(int uid, State attack) {
    State state = createState("請選擇反應卡。",
    Conds.HAND_ATTACKED,
    sender:uid,
    btns:['結束'],
    blockOthers: false
    );
    state << AI_ATTACKED;
    state.end((s) {
      //對於Moat的特別處理。
      if (hasCard(uid, 9, REVEAL)) {
        //print("hi2");
        attack.leave();
      }
      endReveal(uid);
      state.leave();
    });
    state.action((cmd) {
      if (cmd is CardCommand) {
        var doc = CardSet.def(model[cmd.uid][HAND][cmd.pos].cid);
        doc.attacked(this, cmd);
        msg(HOST, "~${cmd.uid};使用@${cmd.cid};。");
        revealCard(cmd.uid, HAND, cmd.pos);
        if (!hasAttacked(uid)) {
          state.leave();
        }
      }
      else if (cmd is ButtonCommand) {
        print("end");
        state.leave();
      }
    });
    return state;
  }

  int getHandNum([int uid]) {
    if (uid == null)uid = this[USER];
    return model[uid][HAND].cardNum;
  }

  State createActionState(String title, {List<String> btns, Condition cond}) {
    cond = (cond == null) ? Conds.HAND_CARD : cond;
    State state = createState(title, cond, btns:btns);
    state << AI_ACTION;
    return state;
  }

//  State createAdHocState(String title,{List<String> btns, Condition cond}){
//    cond= (cond == null) ? Conds : cond;
//    return createState('action', title, cond , btns:btns );
//  }

  ///產生一個讓對手處理攻擊的State，若被攻擊的玩家有反應卡，先解。

  State createAttackState(int uid, String title, {Condition cond:null, List<String> btns, bool invoke:true}) {
    cond = (cond == null) ? Condition.WAIT : cond;

    State attack = createState(title, cond, btns:btns, sender: uid, blockOthers: false);
    attack << AI_ATTACK;

    //print("$uid ${invoke}");
    //若被攻擊的玩家有反應卡，先解。
    if (hasAttacked(uid) && invoke) {
      State react = _createAttackedState(uid, attack);
      attack.addState(react);
    }

    return attack;
  }

//  bool endWait(State wait){
//    this[WAIT]--;
//    if(this[WAIT]<=0){
//      //print('removed');
//      _removeState(wait);
//    }
//    return true;
//  }

  bool checkDraw(int uid) {
    DeckModel draw = model[uid][DRAW];
    if (!draw.hasCard) {
      shuffle(uid, TRUNK);
      moveAllCard(uid, TRUNK, uid, DRAW);
    }

    if (!draw.hasCard) {
      //TODO 需要處理
      //print('ERROR!!');
      return false;
    }
    return true;
  }

  ///玩家[uid]從他的抽牌堆頂端抽一張卡片，如果牌堆抽完，則重洗棄牌堆並加至抽牌堆。
  ///若指定數量則重複[times]次抽牌動作。
  ///回傳 true 則表示正確執行完畢。

  bool drawCard(int uid, [int times=1]) {
    loop(times, (i) {
      if (!checkDraw(uid)) return;
      moveCard(uid, DRAW, LAST_CARD, uid, HAND, LAST_CARD);
    });
    return true;
  }

  ///玩家[uid]從他的手牌打出一張行動牌[pos]，並執行卡片上的動作。
  ///被選擇的卡片會觸發[play]事件。

  bool _playActionCard(CardCommand cmd) {

    int uid = this[USER];
//    CardModel card=model[uid][HAND][cmd.pos];
    DominionCardDef doc = CardSet.def(cmd.cid);

    this[ACTION]--;
//    this[CARD]=pos;
    if (doc.playTrash) {
      trashCard(uid, HAND, cmd.pos);
    }
    else {
      discardCard(uid, HAND, cmd.pos);
    }

    doc.play(this, cmd);

  }

  //bool playActionCard(CardCommand cmd){

  ///玩家[uid]從他的手牌打出一張寶物[pos]，獲得金幣。
  ///被選擇的卡片會觸發[play]事件。

  bool playTresureCard(Command cmd) {
    if (cmd is CardCommand) {
      int uid = this[USER];
      DominionCardDef doc = CardSet.def(model[uid][HAND][cmd.pos].cid);

      //    this[CARD]=pos;
      discardCard(uid, HAND, cmd.pos);
      doc.play(this, cmd);
    }
  }

  ///玩家[uid]從Supply購買一張卡片[pos]，將其置入棄牌堆[TRUNK]。
  ///玩家的金錢必須高於指定要購買的卡片[pos]，本函數不會檢查。
  ///(不確定)被選擇的卡片會觸發[buy]和[gain]事件(如果卡片有定義該事件)。

  bool buyCard(Command cmd) {
    if (cmd is CardCommand) {
      DominionCardDef doc = CardSet.def(model[HOST][cmd.did][0].cid);
      if (this[BUY] > 0 && (this[GOLD] >= doc.cost)) {
        this[BUY]--;
        this[GOLD] -= doc.cost;
        if (getDeckValue(HOST, cmd.did, "vt") == 1) {
          setDeckValue(HOST, cmd.did, "vt", 0);

          plusUserValue(HOST, "route", 1);
        }

        gainCardFromSupply(cmd.did);
        msg(HOST, "~${this[USER]}購買了%Yellow[${doc.name}]@${cmd.cid};。");
        if (model[HOST][cmd.did].cardNum <= 0) {
          //print(this[EMPTY]);
          if (cmd.did == 5) {
            _endGame();
          }
          else {
            this[EMPTY]++;
            if (this[EMPTY] >= 3) {
              _endGame();
            }
          }
        }
      }
    }
  }

  ///玩家[uid]獲得一張卡片[doc]，

  bool gainCardFromSupply(int did, [int did2=TRUNK, int uid2]) {
    if (uid2 == null)uid2 = this[USER];
    if (model[HOST][did].cardNum <= 0)return false;



    moveCard(HOST, did, 0, uid2, did2, LAST_CARD);

    if (model[HOST][did].cardNum <= 0) {
      if (did == 5) {
        _endGame();
      }
      else {
        this[EMPTY]++;
        if (this[EMPTY] >= 3) {
          _endGame();
        }
      }
    }

    return true;
  }

  bool gainCardFromUser(int uid, int did, int pos, [int uid2, int did2=TRUNK]) {
    if (uid2 == null)uid2 = this[USER];
    //game.moveCard(HOST, cmd.did, cmd.pos, game[USER], TRUNK);
    moveCard(uid, did, pos, uid2, did2, LAST_CARD);
  }

  ///玩家[uid]從他的手牌捨棄一張卡片[pos]。
  ///被選擇的卡片會觸發[discard]事件(如果有定義的話)。  

  bool discardCard(int uid, int did, [int pos=LAST_CARD]) {
//    if(pos<this[CARD]){
//      this[CARD]--;
//    }
    //DominionCardDef doc=CardSet.def(model[uid][HAND][pos].cid);
    //TODO

    moveCard(uid, did, pos, uid, TABLE, LAST_CARD);
  }

  bool revealCard(int uid, int did, [int pos=LAST_CARD, int times=1]) {
    //TODO 要處理抽光牌的問題。
    loop(times, (i) {
      if (did == DRAW && !checkDraw(uid))return;
      moveCard(uid, did, pos, uid, REVEAL, LAST_CARD);
    });
    return true;
  }

  ///玩家[uid]從他的手牌刪除一張卡片[pos]。
  ///被選擇的卡片會觸發[trash]事件(如果有定義的話)。  

  bool trashCard(int uid, int did, [int pos=LAST_CARD]) {
//    if(pos<this[CARD]){
//      this[CARD]--;
//    }
    //DominionCardDef doc=CardSet.def(model[uid][HAND][pos].cid);


    removeCard(uid, did, pos);
  }

  bool _endGame() {
    if (this["OVER"] == 1)return true;
    loop(model.userNum, (s) {
      this[USER] = s;
      moveAllCard(s, DRAW, s, TABLE);
      moveAllCard(s, HAND, s, TABLE);
      moveAllCard(s, TRUNK, s, TABLE);

      int score = 0;
      loop(model[s][TABLE].cardNum, (c) {
        var doc = CardSet.def(model[s][TABLE][c].cid);
        score += doc.score;
        if (doc.victory != null) {
          score += doc.victory(this).toInt();
        }
      });

      msg(HOST, "~${s}獲得了 %yellow[${score}]分!!");
      setUserValue(s, "victory", score);
      //model[s].setValue("victory",score);

    });
    this[USER] = 1;
    this["OVER"] = 1;
    clearState();
    pushState(createWaitState("遊戲結束!", HOST));

    endGame();
  }

  _nextTurn() {
    moveAllCard(this[USER], HAND, this[USER], TRUNK);
    moveAllCard(this[USER], TABLE, this[USER], TRUNK);
    drawCard(this[USER], 5);
    //_setMenu(HOST, "等候其他玩家出牌...");

    this[USER] = (this[USER] + 1) % model.userNum;
    //popState();
    _setupTurn();
  }

  _setupTurn() {
    this[ACTION] = 1;
    this[BUY] = 1;
    this[GOLD] = 0;
    _createPlayState();

    //_setMenu(this[USER], "換你出牌...", ['結束','2']);
  }


  _createPlayState() {
    //print("hi${this[GOLD]}");
    State state = createState("行動階段",
    Conds.HAND_ACTION_TRESURE | (Conds.SUPPLY & new CanBuyCondition(model)), btns:['結束']);
    state << AI_ACTION;
    state.check((handler) {
      if (this[ACTION] == 0) {
        state.leave();
      }
    });
    state.end((handler) {
      _setupBuy();
    });

    state.action((Command cmd) {
      if (cmd is CardCommand) {
        var doc = CardSet.def(cmd.cid);
        if (cmd.uid == HOST) {
          if (this[GOLD] >= doc.cost) {
            buyCard(cmd);
            state.leave();
          }
        }
        else {
          if (doc.types[CardType.ACTION]) {
            if (this[ACTION] > 0) {
              _playActionCard(cmd);
            }
          }
          else if (doc.types[CardType.TRESURE]) {
            playTresureCard(cmd);
            state.leave();
          }
        }
      }
      else if (cmd is ButtonCommand) {
        state.leave();
      }
    });
    pushState(state);
  }

  _setupBuy() {
    State state = createState("購物階段",
    Conds.HAND_TRESURE | (Conds.SUPPLY & new CanBuyCondition(model))
    , btns:['結束']);
    state << AI_BUY;
    state.init((handler) {
      this[ACTION] = 0;
    });
    state.check((handler) {
      if (this[BUY] == 0) {
        state.leave();
      }
      if (this[GOLD] == 0 && !hasType(this[USER], CardType.TRESURE)) {
        state.leave();
      }
    });
    state.end((handler) {
      _nextTurn();
    });
    state.action((Command cmd) {
      if (cmd is CardCommand) {
        var doc = CardSet.def(cmd.cid);
        if (cmd.uid == HOST) {
          if (this[GOLD] >= doc.cost) {
            buyCard(cmd);
          }
        }
        else {
          if (doc.types[CardType.TRESURE]) {
            playTresureCard(cmd);
          }
        }
      }
      else if (cmd is ButtonCommand) {
        state.leave();
      }
    });
    pushState(state);
  }


//  Condition get IsUser{
//    return new SenderCondition(this[USER]);
//  }
//  

  start() {

    var hand = {
        'showCard':1,
        'showNum':2,
        'max':0,
        'min':0
    };
    var showAll = {
        'showCard':2,
        'showNum':2,
        'max':0,
        'min':0
    };
    var draw = {
        'showCard':0,
        'showNum':2,
        'max':1,
        'min':0
    };
    var showOne = {
        'showCard':2,
        'showNum':2,
        'max':1,
        'min':0
    };


    //def basic cards
//    loop(7,(i){
//      defCard(0, i);
//    });

    this[EMPTY] = 0;

//    loop(7,(i){
//      int did=createDeck(HOST,showOne);
//      DominionCardDef dcf=CardSet.def(i);
//      loop(dcf.cardNum,(j){
//        insertCard(HOST,did,i);
//      });
//    });

    //TODO 隨機抽卡，並使用統一的隨機變數。  Random rand=new Random();
//    loop(CardSet.dominion.length,(i){
//      CardSet(1, i);
//    });

//    loop(CardSet.length,(i){
//      int did=createDeck(HOST,showOne);
//      DominionCardDef doc=CardSet.def(i);
//      loop(doc.cardNum,(j){
//        insertCard(HOST,did,i);
//      });
//    });
    loop(7, (i) {
      int did = createDeck(HOST, showOne);
      DominionCardDef doc = CardSet.def(i);
      loop(doc.cardNum, (j) {
        insertCard(HOST, did, i);
      });
    });
//
    List<int> cids = <int>[7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32];
    loop(cids.length, (i) {
      int did = createDeck(HOST, showOne);
      DominionCardDef doc = CardSet.def(cids[i]);
      loop(doc.cardNum, (j) {
        insertCard(HOST, did, cids[i]);
      });
    });

    setUserValue(HOST, "route", 0);
    for (int i = 0;i < model[HOST].deckNum;i++) {
      if (CardSet.def(model[HOST][i][0].cid).types[CardType.VICTORY]) {
        setDeckValue(HOST, i, "vt", 1);
      }
    }


    loop(model.userNum, (uid) {
      createDeck(uid, draw);
      createDeck(uid, hand);
      createDeck(uid, showAll);
      createDeck(uid, showOne);
      createDeck(uid, showAll);


      loop(7, (i) {
        insertCard(uid, TRUNK, 0);
      });

      //TODO testing
      loop(3, (i) {
        insertCard(uid, TRUNK, 3);
      });

      drawCard(uid, 5);

    });


    this[USER] = CardGame.rand.nextInt(model.userNum);


//    State wait= createWaitState();
//    wait.loop((CardCommand cmd){
//      wait.title="a${cmd.cid}";
//      print("hi");
//    });
//    pushState(wait);


    ///馬上開始換當前玩家[USER]進行回合。
    _setupTurn();


    startNotification();

    //pushPlayState();


  }

  List<int> scanCard(int uid, int did, bool test(DominionCardDef doc)) {
    //_cards.where(test).map(f)
    List<int> results = new List<int>();
    for (int i = 0;i < model[uid][did].cardNum;i++) {
      if (test(CardSet.def(model[uid][did][i].cid))) {
        results.add(i);
      }
    }
    return results;
  }


}