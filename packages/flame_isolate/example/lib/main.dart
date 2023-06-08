import 'package:flame/game.dart';
import 'package:flame_isolate_example/colonists_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ColonistsGame()));
}
