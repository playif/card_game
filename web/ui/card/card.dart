import 'package:angular/angular.dart';
import 'package:card_game/card_game/card_game.dart';


@NgComponent(selector: 'card', templateUrl: 'ui/card/card.html', cssUrl: 'card/card.css',
    publishAs: 'c')
class CardUI extends NgAttachAware {
  @NgTwoWay('card')
  CardModel card;

  
  @override
  void attach() {
    
    
    // TODO: implement attach
  }
}