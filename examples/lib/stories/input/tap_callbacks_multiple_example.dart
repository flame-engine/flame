import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TapCallbacksMultipleExample extends FlameGame {
  static const String description = '''
    This example do the same thing as tap_callbacks_example, but with big count
    of non-interactive components at background. In such cause you will 
    experience a freeze while tapping anywhere on screen because of scanning
    all component tree.
    The example shows a way to avoid this freeze: 
    1. Place all components into game's world or camera's viewport or 
       viewfinder. This is important requirement!
    2. Place all interactive components into special grouping component.
    3. Assign this component to `componentsAtPointRoot` variable of FlameGame.
    4. Place all other components anywhere you want
    This steps makes `componentsAtPoint` function to search only 
    `componentsAtPointRoot` children and skip looping over other tree branches.
  ''';

  static const int maxItems = 1000000;

  @override
  Future<void> onLoad() async {
    final interactiveComponents = Component();
    interactiveComponents.add(TappableSquare(active: true)
      ..anchor = Anchor.center
      ..x = 1000
      ..y = 500);

    final bottomSquare = TappableSquare(active: true)
      ..x = 1000
      ..y = 750;
    interactiveComponents.add(bottomSquare);
    world.add(interactiveComponents);

    final random = Random();
    for (var i = 1; i < maxItems + 1; i++) {
      final square = TappableSquare(
        position: Vector2(
          random.nextInt(i).toDouble(),
          random.nextInt(i).toDouble(),
        ),
      )..anchor = Anchor.center;
      world.add(square);
    }

    camera.follow(bottomSquare);

    componentsAtPointRoot = interactiveComponents;
  }
}

class TappableSquare extends PositionComponent
    with
        TapCallbacks,
        HasVisibility,
        HasGameReference<TapCallbacksMultipleExample> {
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _grey = Paint()..color = const Color(0xFFA5A5A5);
  static final Paint _blue = Paint()..color = const Color(0xFFC4D9FF);

  bool _beenPressed = false;
  late Paint _defaultColor;
  var _visibilityCheckDone = false;

  TappableSquare({
    Vector2? position,
    bool active = false,
  }) : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        ) {
    _defaultColor = active ? _grey : _blue;
  }

  @override
  void render(Canvas canvas) {
    if (!_visibilityCheckDone) {
      if (!game.camera.canSee(this)) {
        isVisible = false;
      }
      _visibilityCheckDone = true;
    }
    canvas.drawRect(size.toRect(), _beenPressed ? _white : _defaultColor);
  }

  @override
  void onTapUp(_) {
    _beenPressed = false;
  }

  @override
  void onTapDown(_) {
    _beenPressed = true;
    angle += 1.0;
  }

  @override
  void onTapCancel(_) {
    _beenPressed = false;
  }
}
