import 'package:cursa4/logic/enum/cell_content.dart';
import 'package:cursa4/simulation_widget.dart';
import 'package:flutter/material.dart';

import 'logic/cell.dart';
import 'logic/game.dart';


void main() {

  Game game = Game(45, 45, populationSize: 15);

  game.init();
  print(game.board.length);
  print(game.board[0].length);
  runApp(MyApp(game: game));
}



class MyApp extends StatelessWidget{
  final Game game;

  const MyApp({super.key, required this.game});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: SimulationWidget(game: game,),
    );
  }



}

