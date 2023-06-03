import 'dart:math';

import 'package:cursa4/logic/enum/direction.dart';

import 'cell.dart';
import 'enum/bot_status.dart';
import 'network.dart';

class Bot {
  NeuralNetwork brain = NeuralNetwork();
  int health = 100;
  int healthSum = 0;
  int survived = 0;
  double fitness = -1;
  BotStatus status = BotStatus.alive;
  bool wallsBumped = false;
  bool repetative = false;
  int foodCollected = 0;
  Direction? lastMove;
  double punish = 0;

  int x;
  int y;

  Bot(this.x, this.y);

  void provideInput(List<double> list) {
    brain.provideInput(list);
    if(repetative || wallsBumped) {
      punish -=0.1;
    }
    else{
      punish = 0;
    }
    brain.input[brain.inputNeurons - 1] = punish;

  }

  void processMove() {
    if (status == BotStatus.dead) {
      return;
    }
    if (health <= 0) {
      status = BotStatus.dead;
    }

    health--;
    survived++;
    healthSum += health;
  }

  void addHealth(int foodValue) {
    health += foodValue;
    if (health > 100) {
      health = 100;
    }
  }

  void calcFitness() {
    // if (survived < 1000) {
    //   fitness = (healthSum as double) - 100*wallsBumped;
    // } else {
    //   fitness = (survived as double) * pow(1.25, foodCollected);
    fitness = (1 + foodCollected) as double;
  }

  void reset() {
    healthSum = 0;
    health = 100;
    survived = 0;
    fitness = -1;
    status = BotStatus.alive;
    wallsBumped = false;
    foodCollected = 0;
  }

  String getStats() {
    return "$survived $foodCollected $healthSum";
  }

  Direction getDirection() {
    Direction currMove = brain.getDirection();

    repetative = lastMove == currMove.opposite();

    lastMove = currMove;
    return brain.getDirection();
  }
}
