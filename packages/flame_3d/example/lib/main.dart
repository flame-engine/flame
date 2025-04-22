import 'package:example/example_game_3d.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    const GameWidget.controlled(
      gameFactory: ExampleGame3D.new,
    ),
  );
}
