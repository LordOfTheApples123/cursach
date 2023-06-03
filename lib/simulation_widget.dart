import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'logic/bot.dart';
import 'logic/cell.dart';
import 'logic/enum/cell_content.dart';
import 'logic/game.dart';

class SimulationWidget extends StatefulWidget {
  final Game game;

  const SimulationWidget({super.key, required this.game});

  @override
  State<StatefulWidget> createState() {
    return _SimulationState();
  }
}

class _SimulationState extends State<SimulationWidget> {
  int currMove = 0;
  int highScore = -1;
  TextEditingController mutationChanceController = TextEditingController();
  TextEditingController mutationRatioController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    Cell cell = Cell(content: CellContent.bot);
    cell.bot = Bot(40, 50);
    return Scaffold(
      body: boardToWidget(),
    );
  }

  Widget boardToWidget() {
    int currGen = widget.game.populationController.currGen;
    final List<Widget> rows = [];
    for (int row = widget.game.board.length - 1; row >= 0; row--) {
      List<_BoardTile> curr = [];
      for (int col = 0; col < widget.game.board[0].length; col++) {
        curr.add(_BoardTile(cell: widget.game.board[row][col]));
      }
      rows.add(Row(children: curr));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Column(
              children: rows,
            ),
            TextButton(
                onPressed: () => startSimulation(),
                child: const Text("start simulation"))
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "curr move: $currMove",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            Center(
              child: Text("current gen: $currGen",
                style: const TextStyle(fontSize: 40),),
            ),
            Center(
              child: Text(
                "high score: $highScore",
                style: const TextStyle(fontSize: 40),
              ),
            ),

          ],

        ),

      ],
    );
  }

  startSimulation() async{

    int foodCounter = 0;
    int poisonCounter = 0;
    widget.game.populationController.population.activateBots();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1), () {
        // Do something
      });

      setState(() {

        currMove++;
        widget.game.simulateNext();
        foodCounter++;
        poisonCounter++;
        if (widget.game.foodPeriod == foodCounter) {
          foodCounter = 0;
          widget.game.generateFood();
        }
        if (widget.game.poisonPeriod == poisonCounter) {
          poisonCounter = 0;
          widget.game.generatePoison();
        }

        if (widget.game.populationController.population.active.isEmpty || currMove == 10000) {
          if(currMove > highScore){
            highScore = currMove;
          }
          widget.game.nextGen();
          currMove = 0;
          foodCounter = 0;
          poisonCounter = 0;
        }
      });
    }
  }
}

class _BoardTile extends StatelessWidget {
  final Cell cell;

  const _BoardTile({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    int botHealth = -1;
    if (cell.content == CellContent.food) {
      color = Colors.green;
    }
    if (cell.content == CellContent.poison) {
      color = Colors.red;
    }

    if (cell.content == CellContent.bot) {
      color = Colors.blue;
      botHealth = cell.bot!.health;
    }

    return Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          border: Border.all(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
        child: _ContentWidget(
          colorBox: color,
          botHealth: botHealth,
        ));
  }
}

class _ContentWidget extends StatelessWidget {
  final Color colorBox;
  final int botHealth;

  const _ContentWidget(
      {super.key, required this.colorBox, required this.botHealth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: SizedBox(
        width: 18,
        height: 18,
        child: ColoredBox(
          color: colorBox,
          child: SizedBox(
            width: 19,
            height: 19,
            child: Center(
              child: Text(
                botHealth == -1 ? "" : botHealth.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w100,
                  fontSize: 8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
