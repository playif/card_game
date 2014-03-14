import 'dart:html';

import 'package:angular/angular.dart';

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




