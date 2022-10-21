import 'package:ember_quest/ember_quest.dart';
import 'package:ember_quest/overlays/game_over.dart';
import 'package:ember_quest/overlays/main_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EmberQuestGameApp());
}

class EmberQuestGameApp extends StatelessWidget {
  const EmberQuestGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ember Quest',
      home: Scaffold(
        body: GameWidget<EmberQuestGame>(
          game: EmberQuestGame(),
          overlayBuilderMap: {
            'MainMenu': (_, gameRef) => MainMenu(gameRef: gameRef),
            'GameOver': (_, gameRef) => GameOver(gameRef: gameRef),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
