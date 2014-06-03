library ui;

import 'dart:html';
import 'package:angular/angular.dart';
import 'package:card_game/card_game/card_game.dart';
import 'package:card_game/dominion_card.dart';
import 'package:card_game/server_client/card_client.dart';

part 'host/host.dart';
part 'user/user.dart';
part 'deck/deck.dart';
part 'card/card.dart';


//@Directive(selector: '[flex]', map: const {
//	'direction': '<=>direction'
//})
//class FlexUI extends AttachAware {
//	//  @NgAttr('direction ')
//	String direction = 'row';
//	Element element;
//
//	FlexUI(this.element) {
//		element.style.display = "flex";
//	}
//
//
//	@override
//	void attach() {
//		element.style.flexDirection = direction;
//	}
//}
//

final Client _client = new Client();

@Injectable()
class ClientService {
	void clickCard(CardModel card) {
		_client.sendCommand({
			'cmd': 'clickCard',
			'uid': card.uid,
			'did': card.did,
			'pos': card.pos,
		});
	}
	
	void createLocalGame(){
		var game = new DominionGame();
		var ais = [new DominionAI(), new DominionAI(), new DominionAI()];
		game.computerDelay = 200;
		for (int i = 0; i < ais.length; i++) {
			game.createComputer(ais[i]);
		}
		_client.createLoaclGame(game);
	}
	
	void sendCommand(cmd){
		_client.sendCommand(cmd);
	}
	
	GameModel get model{
		return _client.clientModel;
	}
}

