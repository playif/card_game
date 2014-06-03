part of ui;

@Component(selector: 'card', useShadowDom:false, templateUrl: 'packages/card_game/ui/card/card.html',
    publishAs: 'ccmd')
class CardUI implements AttachAware{
  @NgOneWay('model')
  CardModel card;
  Element element;
  
//  @NgTwoWay('uid')
//  int uid;
//  
//  @NgTwoWay('did')
//  int did;
//  
//  @NgTwoWay('cid')
//  int cid;
  
  ClientService service;
  
  CardUI(this.service,this.element){
    //print(controller.hashCode);
  }
  
  String get getCardImage {
  	//print("hi");
  	//return "url('img/75px-Copper.jpg')";
    return  "background-image : url('img/75px-${CardSet.def(card.cid).name}.jpg')";
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

  @override
  void attach(){
    element.style.backgroundImage="url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }
  
}