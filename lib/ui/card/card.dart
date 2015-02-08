part of ui;

@Component(selector: 'card', useShadowDom:false, templateUrl: 'packages/card_game/ui/card/card.html')
class CardUI implements AttachAware {
  @NgOneWay('model')
  CardModel card;
  Element element;


  ClientService service;

  CardUI(this.service, this.element) {
  }

  void clickCard() {
    service.clickCard(card);
  }

  void enterCard() {
    service.displayTip='block';
    service.curCard = CardSet.def(card.cid);
  }

  void leaveCard() {
    service.displayTip='none';
  }

  String get getCardImage {
    return "background-image : url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }

  String getCardStyle() {
    if (card.model.cmds.contains("${card.uid} ${card.did} ${card.pos}")) {
      return "canSelectRedInset";
    }
    return "";
  }

  @override
  void attach() {
    element.style.backgroundImage = "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }

}