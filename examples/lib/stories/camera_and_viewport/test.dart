import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/square_component.dart';

class TestGame extends BaseGame {
  @override
  Future<void> onLoad() async {
    final bigSquare = SquareComponent()..size = Vector2.all(200);
    final red = Paint()..color = Colors.red;
    final smallSquare = SquareComponent()..size = Vector2.all(100)..position = Vector2.all(100)..paint = red;
    add(bigSquare);
    add(smallSquare);
    camera.zoom = 2;
    camera.snapTo(Vector2.all(100));
  }
}
