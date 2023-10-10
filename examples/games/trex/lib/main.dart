import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:trex_game/glowing_foreground.dart';
import 'package:trex_game/trex_game.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Color(0x00000000),
      home: Scaffold(
        body: GamePage(),
      ),
    ),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final game = TRexGame();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF000000),
      child: Stack(
        children: [
          GameWidget(
            game: game,
          ),
          Positioned.fill(
            child: GlowingForeground(game: game),
          ),
        ],
      ),
    );
  }
}
