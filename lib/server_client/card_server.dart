library card_server;

import 'dart:io';
import 'dart:convert';
import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;


import '../card_game/card_game.dart';








final Logger log = new Logger('CardGame');
//Function a;


//typedef Rule<G>(G game);
class Match{
  
}

typedef CardGame CreateGame();

class Server{
  Set<CardGame> _games=new Set<CardGame>();
  List<WebSocket> _users=new List<WebSocket>();
  //T _game;
  
  
  Server(){
    //var g=_game as Game;
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }
  


  listen(CreateGame newGame/*,{int port:9223}*/){
    
    var portEnv = Platform.environment['PORT'];
    var port = portEnv == null ? 9999 : int.parse(portEnv);
    print(port);
    
    var buildPath = Platform.script.resolve('../build').toFilePath();
    if (!new Directory(buildPath).existsSync()) {
      log.severe("The 'build/' directory was not found. Please run 'pub build'.");
      return;
    }
    
    HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
      log.info("Search server is running on "
          "'http://${Platform.localHostname}:$port/'");
      
      var router = new Router(server);
      
      router.serve('/ws').transform(new WebSocketTransformer())
      .listen((WebSocket socket){

//          WebSocketTransformer.upgrade(request).then((socket){
        //log.info(socket.connectionInfo.remoteAddress.toString()+" connected..");
        int socketID=socket.hashCode;
        _users.add(socket);
        if(_users.length==2){
          var game=newGame();
          for(int uid=0;uid<_users.length;uid++) {
            addUserCommand(_users[uid],game);
          }
          game.setup();
          _users=new List<WebSocket>();
          
          socket.done.then((v){
            game.msg(HOST, 'error...');
            //game['gold']=40;
            //print("here");
          });
        }
        

        
      },onError:(e){
        print("here");
      });

//        },onError:(e){
//          print("here");
//        });


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
  
  void addUserCommand(WebSocket socket,CardGame game){
    UserCommander comm=game.createUser();
    //Commander commander=new UserCommander._(uid,game);
    socket.listen((String command){
      comm.add(JSON.decode(command));
    },onDone: (){
      //TODO 通知有玩家離開
      //commands.close();
    });
    comm.changes.listen((op){
      //print(op);
      socket.add(JSON.encode(op));
    });
    //game.addCommander(commander);
    //return commander;
    //print("hi");
  }
  
}
