part of ui;

@NgComponent(selector: 'user', templateUrl: 'ui/user/user.html', cssUrl: 'ui/user/user.css',
    publishAs: 'c')
class UserUI{
  static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];
  
  
//  @NgTwoWay('deck')
//  DeckModel deck;
  @NgOneWay('model')
  UserModel user;
  
//  @NgTwoWay('client')
//  Client client;
  
//  @NgTwoWay('uid')
//  int uid;
  
//  List<DeckModel> decks;
  String getName(DeckModel deck){
    return UserUI.deckNames[deck.did];
  }
  
  int getClientID(){
    return user.model.id;
  }
  
  String getTitleClass(){
    if(getClientID() == user.uid) return "yellow";
    return "";
  }
  
//  DeckUI(NgInjectableService service){
//    
//  }

//  @override
//  void attach() {
//    decks=model[uid].decks;
//    
//  }
}