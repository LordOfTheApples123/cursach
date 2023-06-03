import 'package:cursa4/logic/enum/bot_status.dart';

import 'bot.dart';

class Population {
  int size;
  List<Bot> bots;

  List<Bot> active;

  Population(this.size)
      : bots = List.generate(size, (index) => new Bot(0, 0)),

        active = [];

  void calcFitness() {
    for (Bot bot in bots) {
      bot.calcFitness();
    }
  }

  void activateBots(){
    int len = bots.length;

    active = List.of(bots);

    for(Bot bot in active){
      bot.reset();
    }
  }

  void processMove(){
    for(Bot bot in active){
      bot.processMove();
    }
  }

  List<String> getStats(){
    List<String> res = [];
    for(Bot bot in active){
      res.add(bot.getStats());
    }
    return res;
  }
}
