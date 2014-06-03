part of ui;

@Component(selector: 'host', publishAs: 'cmp', templateUrl: 'packages/card_game/ui/host/host.html', cssUrl: 'packages/card_game/ui/host/host.css')
class HostUI {
	//static final List<String> deckNames = ["SOURCE", "HAND", "TABLE", "TRUNK", "REVEAL"];


	//  @NgTwoWay('deck')
	//  DeckModel deck;
	@NgOneWay('model')
	UserModel userModel;

	int get uid {
		return 1;
	}

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
