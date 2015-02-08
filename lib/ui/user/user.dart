part of ui;

@Component(selector: 'user', useShadowDom:false, templateUrl: 'packages/card_game/ui/user/user.html')
class UserUI {
	static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];

	@NgOneWay('model')
	UserModel userModel;

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
