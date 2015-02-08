library card_server;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;


import '../card_game/card_game.dart';


final Logger log = new Logger('CardGame');
//Function a;


//typedef Rule<G>(G game);
class Match {

}

typedef CardGame CreateGame();


class Connector {
  String name;
  WebSocket socket;
  StreamSubscription<WebSocket> subscription;
  Connector(this.socket);
}

class Server {
  //Set<CardGame> _games=new Set<CardGame>();
  List<Connector> _users = new List<Connector>();


  Server() {
    //var g=_game as Game;
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }


  listen(CreateGame newGame/*,{int port:9223}*/) {

    var portEnv = Platform.environment['PORT'];
    var port = portEnv == null ? 9999 : int.parse(portEnv);
    print(port);

    var buildPath = Platform.script.resolve('../web').toFilePath();
    if (!new Directory(buildPath).existsSync()) {
      log.severe("The 'build/' directory was not found. Please run 'pub build'.");
      return;
    }

    HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
      log.info("Search server is running on "
      "'http://${Platform.localHostname}:$port/'");

      Router router = new Router(server);


      router.serve('/ws').transform(new WebSocketTransformer())
      .listen((WebSocket socket) {

        //int socketID = socket.hashCode;
        Connector conn= CreateConnector(socket);





//        if(_users.length==2){
//          var game=newGame();
//          for(int uid=0;uid<_users.length;uid++) {
//            CreateUserCommand(_users[uid],game);
//          }
//          game.setup();
//          _users=new List<WebSocket>();
//
//          socket.done.then((v){
//            game.msg(HOST, 'error...');
//          });
//        }


      }, onError:(e) {
        print("here");
      });


      // Set up default handler. This will serve files from our 'build' directory.
      var virDir = new http_server.VirtualDirectory(buildPath);
      // Disable jail-root, as packages are local sym-links.
      virDir.jailRoot = false;
      virDir.allowDirectoryListing = true;
      virDir.directoryHandler = (dir, request) {
        // Redirect directory-requests to index.html files.
        var indexUri = new Uri.file(dir.path).resolve('dominion.html');
        virDir.serveFile(new File(indexUri.toFilePath()), request);
      };

      // Add an error page handler.
      virDir.errorPageHandler = (HttpRequest request) {
        log.warning("Resource not found ${request.uri.path}");
        request.response.statusCode = HttpStatus.NOT_FOUND;
        request.response.close();
      };

      // Serve everything not routed elsewhere through the virtual directory.
      virDir.serve(router.defaultStream);

    });
  }

  Connector CreateConnector(WebSocket socket) {
    Connector conn = new Connector(socket);
    _users.add(conn);
    for(var user in _users){
      user.socket.add(JSON.encode({'info':{'usernum':_users.length}}));
    }
    conn.subscription= socket.listen((String name) {
      //print (name);
      if( name!= '' && name!=null && !_users.any((Connector c)=>c.name == name)){
        // 可使用的名稱
        conn.name=name;
        socket.add(JSON.encode({'info':{'msg':'ok'}}));
      }
      else{
        socket.add(JSON.encode({'info':{'msg':'no'}}));
      }

      

      //comm.add(JSON.decode(command));
    }, onDone: () {
      _users.remove(conn);
      for(var user in _users){
        user.socket.add(JSON.encode({'info':{'usernum':_users.length}}));
      }
    });


    return conn;
  }

  UserCommander CreateUserCommand(WebSocket socket, CardGame game) {
    UserCommander comm = game.createUser();
    socket.listen((String command) {
      comm.add(JSON.decode(command));
    }, onDone: () {
      //TODO 通知有玩家離開
      //commands.close();
    });
    comm.changes.listen((op) {
      socket.add(JSON.encode(op));
    });

    return comm;
  }

}
