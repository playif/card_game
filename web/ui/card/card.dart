part of ui;

@NgComponent(selector: 'card', templateUrl: 'ui/card/card.html', cssUrl: 'ui/card/card.css',
    publishAs: 'c')
class CardUI {
  @NgOneWay('model')
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
  
//  List<CardModel> getDecks(){
//    return model[uid][did][cid];
//  }
  
//  Map<String,String> background={
//     'float': 'left',
//     'cursor': 'pointer',
//     'width': '40px',
//     'height': '60px',
//     'background-size': '100% 100%'
//  };
  
  
  
  void clickCard(){
    //print(card.pos);
    service.clickCard(card);
  }
  
  String getBackground() {
    
    //if (cid == null) return "";
    
    //background['background-image']= "url('${getSmallImg(cid)}')";
    //print("url('${getSmallImg(cid)}')");
    //print("url('img/75px-${CardSet.def(cid).name}.jpg')");
    return "url('img/75px-${CardSet.def(card.cid).name}.jpg')";
  }
  
//  String getSmallImg(int cid) {
//    return ;
//  }
  
//  @override
//  void attach() {
//    
//    
//    // TODO: implement attach
//  }
}