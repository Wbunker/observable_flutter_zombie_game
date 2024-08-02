import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:observable_zombies/zombie_game.dart';

void main() async {
  final FlameGame game = ZombieGame();
  runApp(MainApp(game: game));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.game});
  final FlameGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameWidget(game: game),
    );
  }
}
