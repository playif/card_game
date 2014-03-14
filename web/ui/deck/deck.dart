part of ui;

@NgComponent(selector: 'deck', templateUrl: 'ui/deck/deck.html', cssUrl: 'ui/deck/deck.css',
    publishAs: 'c')
class DeckUI {

  @NgOneWay('model')
  DeckModel deck;
  
  
  ClientService service;
  
  DeckUI(this.service){
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
    service.clickCard(card);
  }
  
  String getBackground(CardModel card) {
    return "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }

}