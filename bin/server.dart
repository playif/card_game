import 'package:card_game/server_client/card_server.dart';
import 'package:card_game/dominion_card.dart';


main() {
  var i = 0;
  var cs = new Server();

  //告訴IDE 真正的Game Type
  cs.listen(() {
    var game = new DominionGame();
    game.createComputer(new DominionAI());
    game.computerDelay = 50;
    return game;
  });

}