import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ember_quest.dart';
import 'overlays/game_over.dart';
import 'overlays/main_menu.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ember Quest',
      home: Scaffold(
        body: GameWidget<EmberQuestGame>.controlled(
          gameFactory: EmberQuestGame.new,
          overlayBuilderMap: {
            'MainMenu': (_, gameRef) => MainMenu(gameRef: gameRef),
            'GameOver': (_, gameRef) => GameOver(gameRef: gameRef),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    ),
  );
}
