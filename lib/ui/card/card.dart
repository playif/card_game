part of ui;

@Component(selector: 'card', templateUrl: 'packages/card_game/ui/card/card.html', cssUrl: 'packages/card_game/ui/card/card.css',
    publishAs: 'ccmd',map:const{
    	'model':'=>!card'
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
  
  String getBackground() {
  	//print("hi");
  	return "url('img/75px-Copper.jpg')";
    //return "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
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
  

  
}