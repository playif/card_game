part of ui;

@NgComponent(selector: 'deck', templateUrl: 'ui/deck/deck.html', cssUrl: 'ui/deck/deck.css',
    publishAs: 'c')
class DeckUI {

  @NgOneWay('model')
  DeckModel deck;
  
  
  DeckUI(){
    //deck.
  }
  

  
//  @NgTwoWay('uid')
//  int uid;
//  
//  @NgTwoWay('did')
//  int did;
  
//  List<CardModel> cards;
//  
//  List<CardModel> getDecks(){
//    return model[uid][did].cards;
//  }
//  
//
//  @override
//  void attach() {
//    
//    
//  }
}