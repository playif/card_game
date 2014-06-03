part of ui;

@Component(selector: 'user', publishAs: 'cmp', templateUrl: 'packages/card_game/ui/user/user.html', cssUrl: 'packages/card_game/ui/user/user.css')
class UserUI {
	static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];


	//  @NgTwoWay('deck')
	//  DeckModel deck;
	@NgOneWay('model')
	UserModel userModel;

	//  @NgTwoWay('client')
	//  Client client;

	//  @NgTwoWay('uid')
	//  int uid;

	//  List<DeckModel> decks;
	String getName(DeckModel deck) {
		return UserUI.deckNames[deck.did];
	}

	int getClientID() {
		return userModel.model.id;
	}

	String getTitleClass() {
		if (getClientID() == userModel.uid) return "yellow";
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
