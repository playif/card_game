part of dominion;




const AITagger AI_ACTION=const AITagger(0);
const AITagger AI_BUY=const AITagger(1);
const AITagger AI_ATTACK=const AITagger(2);
const AITagger AI_ATTACKED=const AITagger(3);

Map<int, DominionCardDef> toDef(List cmds, GameModel model){
  return cmds.map((AllowClickCard cmd)=>
      CardSet.def( model[cmd.uid][cmd.did][cmd.pos].cid)
    ).toList().asMap();
}


class DominionAI extends AI{
  bool learn;
  DominionAI([this.learn=false]);

  Random rand=new Random();
  
  bool preferCard(){
    
  }
  
  calculateCommand(State state) {
    //InstanceMirror cm=reflect(state);
    
    //String title=state.title;
    
    //InstanceMirror tm=reflect(title);
    //print(cm.type.metadata[0].reflectee);
    
    List btns=state.btns;
    List<AllowClickCard> cmds=state.getAllowCommands(model);
    
    var cards=toDef(cmds,model);
    
    List<int> list=cards.keys.toList()..sort((int i,int j){
      var a=cards[i],b=cards[j];
//      print(cmds[i]['uid']);
//      print(cmds[j]['uid']);
      if(cmds[i].uid==uid && cmds[j].uid!=uid) return 1;
      if(cmds[i].uid!=uid && cmds[j].uid==uid) return -1;
      
      if(state[AI_ACTION] || state[AI_BUY]){
        if(cmds[i].uid == uid){
          if(a.types[CardType.ACTION] && !b.types[CardType.ACTION]) return 1;
          if(!a.types[CardType.ACTION] && b.types[CardType.ACTION]) return -1;
          if(a.name == "Village") return 1;
          if(b.name == "Village") return -1;
          if(a.name == "Festival") return 1;
          if(b.name == "Festival") return -1;          
          if(a.name == "Smithy") return 1;
          if(b.name == "Smithy") return -1;  
          if(a.name == "Council_Room") return 1;
          if(b.name == "Council_Room") return -1;            
          
        }
        
        
        if(a.cost > b.cost)return 1;
        if(a.cost < b.cost)return -1;
        if(a.cost == b.cost && rand.nextInt(100)>50)return 1;
        else return -1;
      } else if(state[AI_BUY]){
        
        if(a.cost>b.cost)return 1;
        if(a.cost<b.cost)return -1;
      }
      
      return -1;
    });
    //if(idx>=2) idx-= rand.nextInt(2);
    
    //print(list);
    //print(cmds);
    var cmd=cmds[list.last];
    int cid=model[cmd.uid][cmd.did][cmd.pos].cid;
    var card=CardSet.def(cid);
    if(state[AI_ACTION] || state[AI_BUY]){
      if(cmd.uid!=uid){
        
        if(card.cost==0 && btns!=null){
          return{
            'cmd':'clickButton',
            'bid':0,
          };
        }
      }
    }
    
    
    
    if(state[AI_BUY]){
      state.train(AI_BUY,cid,1/cards.values.where((s)=>s.name == card.name).length);
      if(learn){
        var re=cards.keys.toList()..sort((i,j){
          var c1=cmds[i],c2=cmds[j];
          var cid1=model[c1.uid][c1.did][c1.pos].cid;
          var cid2=model[c2.uid][c2.did][c2.pos].cid;
          var a=cards[i],b=cards[j];
          if(cmds[i].uid==uid && cmds[j].uid!=uid) return 1;
          if(cmds[i].uid!=uid && cmds[j].uid==uid) return -1;
          if(state[AI_ACTION] || state[AI_BUY]){
            if(cmds[i].uid == uid){
              if(a.types[CardType.ACTION] && !b.types[CardType.ACTION]) return 1;
              if(!a.types[CardType.ACTION] && b.types[CardType.ACTION]) return -1;
              if(a.name == "Village") return 1;
              if(b.name == "Village") return -1;
              if(a.name == "Festival") return 1;
              if(b.name == "Festival") return -1;          
              if(a.name == "Smithy") return 1;
              if(b.name == "Smithy") return -1;  
              if(a.name == "Council_Room") return 1;
              if(b.name == "Council_Room") return -1;            
              
            }
            
            
            if(a.cost > b.cost)return 1;
            if(a.cost < b.cost)return -1;
            //if(a.cost == b.cost && rand.nextInt(100)>50)return 1;
            //else return -1;
          } else if(state[AI_BUY]){
            
            if(a.cost>b.cost)return 1;
            if(a.cost<b.cost)return -1;
          }
          //print ("here");

          if(!GameModel.s_prob.containsKey(AI_BUY)) GameModel.s_prob[AI_BUY]=new Map<int,double>();

          double p1=GameModel.s_prob[AI_BUY][cid1];
          double p2=GameModel.s_prob[AI_BUY][cid2];
          
          if(p1 == null) p1=.0;
          if(p2 == null) p2=.0;
          
          //print("$p1 $p2");
          if(p1 == p2){
            if(rand.nextInt(100)>50)return 1;
            else return -1;
          }
          double m=min(p1,p2)-10;
          p1-=m;
          p2-=m;
          //print("$p1 $p2");
          if(rand.nextInt((p1+p2).toInt())>p2)return 1;
          else return 0;
          
          if(p1 > p2) return 1;
          if(p1 == p2) return 0;
          if(p1 < p2) return -1;
        });
        cmd=cmds[re.last];
        //GameModel.s_prob[cid]
      }
    }
    if(state[AI_ACTION]){
      state.train(AI_ACTION,cid,1/cards.values.where((s)=>s.name == card.name).length);
      if(learn ){
        var re=cards.keys.toList()..sort((i,j){
          var c1=cmds[i],c2=cmds[j];
          var cid1=model[c1.uid][c1.did][c1.pos].cid;
          var cid2=model[c2.uid][c2.did][c2.pos].cid;
          var a=cards[i],b=cards[j];
          
          if(cmds[i].uid==uid && cmds[j].uid!=uid) return 1;
          if(cmds[i].uid!=uid && cmds[j].uid==uid) return -1;
          
          if(state[AI_ACTION] || state[AI_BUY]){
            if(cmds[i].uid == uid){
              if(a.types[CardType.ACTION] && !b.types[CardType.ACTION]) return 1;
              if(!a.types[CardType.ACTION] && b.types[CardType.ACTION]) return -1;
              if(a.name == "Village") return 1;
              if(b.name == "Village") return -1;
              if(a.name == "Festival") return 1;
              if(b.name == "Festival") return -1;          
              //if(a.name == "Smithy") return 1;
              //if(b.name == "Smithy") return -1;  
              //if(a.name == "Council_Room") return 1;
              //if(b.name == "Council_Room") return -1;            
              
            }
            
            
            if(a.cost > b.cost)return 1;
            if(a.cost < b.cost)return -1;
            //if(a.cost == b.cost && rand.nextInt(100)>50)return 1;
            //else return -1;
          } else if(state[AI_BUY]){
            
            if(a.cost>b.cost)return 1;
            if(a.cost<b.cost)return -1;
          }
          
          //print ("here");
          
          
          if(!GameModel.s_prob.containsKey(AI_ACTION)) GameModel.s_prob[AI_ACTION]=new Map<int,double>();
          double p1=GameModel.s_prob[AI_ACTION][cid1];
          double p2=GameModel.s_prob[AI_ACTION][cid2];
          if(p1 == null) p1=.0;
          if(p2 == null) p2=.0;
          
          if(p1 == p2){
            if(rand.nextInt(100)>50)return 1;
            else return -1;
          }
          double m=min(p1,p2)-10;
          p1-=m;
          p2-=m;
          
          //print("here");
          if(rand.nextInt((p1+p2).toInt())>p2)return 1;
          else return 0;
          
          if(p1 > p2) return 1;
          if(p1 == p2) return 0;
          if(p1 < p2) return -1;
        });
        cmd=cmds[re.last];
        //GameModel.s_prob[cid]
      }
    }

    return {
      'cmd':'clickCard',
      'uid':cmd.uid,
      'did':cmd.did,
      'pos':cmd.pos,
    };
  }
  

  
}



class RandomAI extends AI{
  bool learn;
  RandomAI([this.learn=false]);

  
  Random rand=new Random();
  calculateCommand(State state){
    List<AllowClickCard> cmds=state.getAllowCommands(model);
    
    
    var btns=state.btns;
    if(cmds==null || cmds.length==0){
      if(btns==null)return {};
      return {
        'cmd':'clickButton',
        'bid':0
      };
    }
    
    var idx=cmds.length-(1);
    if(idx>=2) idx-= rand.nextInt(2);
    var cmd=cmds[idx];
    var cards=toDef(cmds,model);
    int cid=model[cmd.uid][cmd.did][cmd.pos].cid;
    var card=CardSet.def(cid);
    
    
    if(state[AI_BUY]){
      state.train(AI_BUY,cid,1/cards.values.where((s)=>s.name == card.name).length);
      if(learn){
        var re=cards.keys.toList()..sort((i,j){
          var c1=cmds[i],c2=cmds[j];
          var cid1=model[c1.uid][c1.did][c1.pos].cid;
          var cid2=model[c2.uid][c2.did][c2.pos].cid;
          var a=cards[i],b=cards[j];
          
          if(cmds[i].uid==uid && cmds[j].uid!=uid) return 1;
          if(cmds[i].uid!=uid && cmds[j].uid==uid) return -1;
          
          if(a.cost > b.cost)return 1;
          if(a.cost < b.cost)return -1;
          //if(a.cost == b.cost && rand.nextInt(100)>50)return 1;
          //else return -1;

          
          if(!GameModel.s_prob.containsKey(AI_BUY)) GameModel.s_prob[AI_BUY]=new Map<int,double>();

          double p1=GameModel.s_prob[AI_BUY][cid1];
          double p2=GameModel.s_prob[AI_BUY][cid2];
          
          if(p1 == null) p1=.0;
          if(p2 == null) p2=.0;
          //print("$p1 $p2");
          if(p1 == p2){
            if(rand.nextInt(100)>50)return 1;
            else return -1;
          }
          double m=min(p1,p2)-1;
          p1-=m;
          p2-=m;
          
          //print("here");
          if(rand.nextInt((p1+p2).toInt())>p2)return 1;
          else return 0;
          
          if(p1 > p2) return 1;
          if(p1 == p2) return 0;
          if(p1 < p2) return -1;
        });
        cmd=cmds[re.last];
        //GameModel.s_prob[cid]
      }
    }
    if(state[AI_ACTION]){
      
      state.train(AI_ACTION,cid,1/cards.values.where((s)=>s.name == card.name).length);
      if(learn){
        var re=cards.keys.toList()..sort((i,j){
          var c1=cmds[i],c2=cmds[j];
          var cid1=model[c1.uid][c1.did][c1.pos].cid;
          var cid2=model[c2.uid][c2.did][c2.pos].cid;
          var a=cards[i],b=cards[j];
          if(cmds[i].uid==uid && cmds[j].uid!=uid) return 1;
          if(cmds[i].uid!=uid && cmds[j].uid==uid) return -1;
          
          if(cmds[i].uid == uid){
            if(a.types[CardType.ACTION] && !b.types[CardType.ACTION]) return 1;
            if(!a.types[CardType.ACTION] && b.types[CardType.ACTION]) return -1;
          
            
          }
          
          if(!GameModel.s_prob.containsKey(AI_ACTION)) GameModel.s_prob[AI_ACTION]=new Map<int,double>();
          double p1=GameModel.s_prob[AI_ACTION][cid1];
          double p2=GameModel.s_prob[AI_ACTION][cid2];
          

          //if(a.cost == b.cost && rand.nextInt(100)>50)return 1;
          
          if(p1 == null) p1=.0;
          if(p2 == null) p2=.0;
          
          if(p1 == p2){
            if(rand.nextInt(100)>50)return 1;
            else return -1;
          }
          double m=min(p1,p2)-1;
          p1-=m;
          p2-=m;

          if(rand.nextInt((p1+p2).toInt())>p2)return 1;
          else return 0;
          
          if(p1 > p2) return 1;
          if(p1 == p2) return 0;
          if(p1 < p2) return -1;
        });
        cmd=cmds[re.last];
        //GameModel.s_prob[cid]
      }
      
    }
    if(state[AI_ACTION] || state[AI_BUY]){
      if(cmd.uid!=uid){
        
        if(card.cost==0 && btns!=null){
          return{
            'cmd':'clickButton',
            'bid':0,
          };
        }
      }
    }
    
    return {
      'cmd':'clickCard',
      'uid':cmd.uid,
      'did':cmd.did,
      'pos':cmd.pos,
    };

  }
}




