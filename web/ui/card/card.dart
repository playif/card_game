part of ui;

@Component(selector: 'card', templateUrl: 'ui/card/card.html', cssUrl: 'ui/card/card.css',
    publishAs: 'c',map:const{
    	'model':'<=>card'
    })
class CardUI {
//  @NgOneWay('model')
  CardModel card;
  
//  @NgTwoWay('uid')
//  int uid;
//  
//  @NgTwoWay('did')
//  int did;
//  
//  @NgTwoWay('cid')
//  int cid;
  
  ClientService service;
  
  CardUI(this.service){
    //print(controller.hashCode);
  }
  
  String getCardStyle() {
    //if (card == null) return "";
    if (card.model.cmds.contains("${card.uid} ${card.did} ${card.pos}")) {
      return "canSelectRedInset";
    }
    return "";
  }
  
  void clickCard(){
    service.clickCard(card);
  }
  
  String getBackground() {
    return "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }
  
}