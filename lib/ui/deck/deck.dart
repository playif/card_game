part of ui;

@Component(selector: 'deck',useShadowDom:false, templateUrl: 'packages/card_game/ui/deck/deck.html', cssUrl: 'packages/card_game/ui/deck/deck.css',
    publishAs: 'dcmp')
class DeckUI {

  @NgOneWay('model')
  DeckModel deckModel;
  
  
//  ClientService service;
  
  DeckUI(){
    //print(controller.hashCode);
  }
  
  String getCardStyle(CardModel card) {
    //if (card == null) return "";
    if (card.model.cmds.contains("${card.uid} ${card.did} ${card.pos}")) {
      return "canSelectRedInset";
    }
    return "";
  }
  
  void clickCard(CardModel card){
    //service.clickCard(card);
  }
  
  String getBackgroundImg(CardModel card) {
    return "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }

}