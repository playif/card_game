part of ui;

@NgComponent(selector: 'host', templateUrl: 'ui/host/host.html', cssUrl: 'ui/host/host.css',
    publishAs: 'c')
class HostUI{
  //static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];
  
  
//  @NgTwoWay('deck')
//  DeckModel deck;
  @NgOneWay('model')
  UserModel host;
  
//  @NgTwoWay('client')
//  Client client;
  
//  @NgTwoWay('uid')
//  int uid;
  
//  List<DeckModel> decks;
//  String getName(DeckModel deck){
//    return UserUI.deckNames[deck.did];
//  }
  
//  DeckUI(NgInjectableService service){
//    
//  }

//  @override
//  void attach() {
//    decks=model[uid].decks;
//    
//  }
}