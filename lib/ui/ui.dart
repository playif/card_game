library ui;

import 'dart:html';
import 'package:angular/angular.dart';
import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/server_client/card_client.dart';
import 'package:card_game/dominion_card.dart';


part 'host/host.dart';
part 'user/user.dart';
part 'deck/deck.dart';
part 'card/card.dart';


@Injectable()
class GameClient extends Client {

  DominionCardDef curCard;
  String displayTip='none';

}

