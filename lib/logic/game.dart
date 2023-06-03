import 'dart:math';

import 'package:cursa4/logic/population.dart';
import 'package:cursa4/logic/population_controller.dart';

import 'bot.dart';
import 'cell.dart';
import 'enum/bot_status.dart';
import 'enum/cell_content.dart';
import 'enum/direction.dart';

class Game {
  List<List<Cell>> board;
  PopulationController populationController;

  int initFoodGenerated;
  int initFoodPeriod;

  late int foodGenerated;
  int poisonGenerated;
  int poisonCount = 0;
  int maxPoison;


  int foodValue;
  int poisonValue;

  late int foodPeriod;
  int poisonPeriod;

  Game(int width, int height,
      {this.initFoodGenerated = 4,
      this.poisonGenerated = 1,
      int populationSize = 15,
      this.foodValue = 20,
      this.poisonValue = 30,
      this.initFoodPeriod = 3,
      this.maxPoison = 50,
      this.poisonPeriod = 10})
      : board = new List.generate(
            width, (index) => new List.generate(height, (index) => new Cell())),
        populationController = PopulationController(populationSize);

  void init() {
    // for( List<Cell> lst in board){
    //   for(Cell cell in lst){
    //     print(cell.content);
    //   }
    // }
    _spreadBots();
    poisonCount = 0;
    foodGenerated = initFoodGenerated;
    foodPeriod = initFoodPeriod;
    generateFood();
    generatePoison();

    // for( List<Cell> lst in board){
    //   for(Cell cell in lst){
    //     print(cell.content);
    //   }
    // }
  }

  void resetBoard() {
    for (List<Cell> lst in board) {
      for (Cell cell in lst) {
        cell.content = CellContent.blank;
      }
    }
    init();



  }

  void _spreadBots() {
    List<int> freeCellsX = [];
    List<int> freeCellsY = [];
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        if (board[i][j].content == CellContent.blank) {
          freeCellsX.add(i);
          freeCellsY.add(j);
        }
      }
    }

    for (int i = 0; i < populationController.population.size; i++) {
      if (freeCellsX.isEmpty) {
        return;
      }
      int index = Random().nextInt(freeCellsX.length);
      board[freeCellsX[index]][freeCellsY[index]].content = CellContent.bot;
      board[freeCellsX[index]][freeCellsY[index]].bot =
          populationController.population.bots[i];
      populationController.population.bots[i].x = freeCellsX[index];
      populationController.population.bots[i].y = freeCellsY[index];
      freeCellsX.removeAt(index);
      freeCellsY.removeAt(index);
    }
  }

  void startSimulation() {
    int foodCounter = 0;
    int poisonCounter = 0;
    while (populationController.population.active.isNotEmpty) {
      simulateNext();
      foodCounter++;
      poisonCounter++;
      if (foodPeriod == foodCounter) {
        foodCounter = 0;
        generateFood();
      }
      if (poisonPeriod == poisonCounter) {
        poisonCounter = 0;
        generatePoison();
      }
    }
  }

  void generateFood() {
    List<int> freeCellsX = [];
    List<int> freeCellsY = [];

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        if (board[i][j].content == CellContent.blank) {
          freeCellsX.add(i);
          freeCellsY.add(j);
        }
      }
    }

    for (int i = 0; i < foodGenerated; i++) {
      if (freeCellsX.isEmpty) {
        return;
      }
      int index = Random().nextInt(freeCellsX.length);
      board[freeCellsX[index]][freeCellsY[index]].content = CellContent.food;
      freeCellsX.removeAt(index);
      freeCellsY.removeAt(index);
    }
  }

  void generatePoison() {
    List<int> freeCellsX = [];
    List<int> freeCellsY = [];

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        if (board[i][j].content == CellContent.blank) {
          freeCellsX.add(i);
          freeCellsY.add(j);
        }
      }
    }

    for (int i = 0; i < poisonGenerated; i++) {
      if(poisonCount == maxPoison){
        return;
      }
      if (freeCellsX.isEmpty) {
        return;
      }
      poisonCount++;
      int index = Random().nextInt(freeCellsX.length);
      board[freeCellsX[index]][freeCellsY[index]].content = CellContent.poison;
      freeCellsX.removeAt(index);
      freeCellsY.removeAt(index);
    }
  }

  void simulateNext() {
    for (Bot bot in populationController.population.active) {
      if (bot.status == BotStatus.alive) {
        bot.provideInput(_getInputForCoords(bot.x, bot.y));
        moveBot(bot, bot.getDirection());
      } else {
        board[bot.x][bot.y].content = CellContent.blank;
        board[bot.x][bot.y].bot = null;
        populationController.population.active.remove(bot);
        foodGenerated = foodGenerated *
            (populationController.population.active.length /
                    populationController.population.size)
                .ceil();
        foodPeriod++;
      }
    }
    populationController.population.processMove();
  }

  void nextGen() {
    populationController.evolve();
    resetBoard();
  }

  void moveBot(Bot bot, Direction dir) {
    int newX = bot.x;
    int newY = bot.y;

    switch (dir) {
      case Direction.u:
        newY = bot.y + 1;
        break;
      case Direction.ur:
        newX = bot.x + 1;
        newY = bot.y + 1;
        break;
      case Direction.r:
        newY = bot.y + 1;
        break;
      case Direction.dr:
        newX = bot.x + 1;
        newY = bot.y - 1;
        break;
      case Direction.d:
        newY = bot.y - 1;
        break;
      case Direction.dl:
        newX = bot.x - 1;
        newY = bot.y - 1;
        break;
      case Direction.l:
        newX = bot.x - 1;
        break;
      case Direction.ul:
        newX = bot.x - 1;
        newY = bot.y + 1;
        break;
    }

    if (newX < 0) {
      newX = board.length - 1;
    }
    if (newX == board.length) {
      newX = 0;
    }
    if (newX == board.length + 1) {
      newX = 1;
    }

    if (newY < 0) {
      newY = board[0].length - 1;
    }
    if (newY == board[0].length) {
      newY = 0;
    }
    if (newY == board[0].length + 1) {
      newY = 1;
    }

    if (bot.wallsBumped = (board[newX][newY].content == CellContent.wall ||
        board[newX][newY].content == CellContent.bot)) {
      return;
    }
    if (board[newX][newY].content == CellContent.food) {
      bot.addHealth(foodValue);
      bot.foodCollected++;
    }
    if (board[newX][newY].content == CellContent.poison) {
      bot.health -= poisonValue;
    }

    _moveBot(bot, newX, newY);
  }

  void _moveBot(Bot bot, int newX, int newY) {
    board[bot.x][bot.y].bot = null;
    board[bot.x][bot.y].content = CellContent.blank;

    bot.x = newX;
    bot.y = newY;

    board[bot.x][bot.y].bot = bot;
    board[bot.x][bot.y].content = CellContent.bot;
  }

  List<double> _getInputForCoords(int x, int y) {
    List<double> input = [];

    // print("x: $x");
    // print("y: $y");
    int coordX = 0;
    int coordY = 0;
    for (int i = x - 2; i <= x + 2; i++) {
      for (int j = y - 2; j <= y + 2; j++) {
        ///skip bot square
        if (i == x && j == y) {
          continue;
        }

        coordX = i;
        coordY = j;
        if (i < 0) {
          coordX = board.length - 1;
        }
        if (i == board.length) {
          coordX = 0;
        }
        if (i > board.length) {
          coordX = 1;
        }

        if (j < 0) {
          coordY = board[0].length - 1;
        }
        if (j == board[0].length) {
          coordY = 0;
        }
        if (j > board[0].length) {
          coordY = 1;
        }

        if (board[coordX][coordY].content == CellContent.poison) {
          input.add(-1);
        } else if (board[coordX][coordY].content == CellContent.wall ||
            board[coordX][coordY].content == CellContent.bot) {
          input.add(-0.5);
        } else if (board[coordX][coordY].content == CellContent.food) {
          input.add(1);
        } else if (board[coordX][coordY].content == CellContent.blank) {
          input.add(0);
        } else {
          // print("i: $i");
          // print("j: $j");
        }
      }
    }

    return input;
  }
}
