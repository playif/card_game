library ui;
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:card_game/card_game/card_game.dart';
import '../../packages/card_game/dominion_card.dart';
import '../dominion.dart';

part 'host/host.dart';
part 'user/user.dart';
part 'deck/deck.dart';
part 'card/card.dart';


@NgDirective(selector: '[flex]')
class FlexUI extends NgAttachAware{
  @NgAttr('direction ')
  String direction='row';
  Element element;
  
  FlexUI(this.element){
    element.style.display="flex";
  }
  
  
  @override
  void attach(){
    element.style.flexDirection=direction;
  }
}




