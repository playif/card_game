import 'package:angular/angular.dart';
import 'package:card_game/card_game/card_game.dart';

@NgComponent(selector: 'deck', templateUrl: 'ui/deck/deck.html', cssUrl: 'deck/deck.css',
    publishAs: 'c')
class DeckUI extends NgAttachAware {
  static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];
  
  
  @NgTwoWay('deck')
  DeckModel deck;

  GameModel game;
  

  
//  DeckUI(){
//    
//  }

  @override
  void attach() {
    
    
  }
}