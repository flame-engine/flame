import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TapCallbacksMultipleExample extends FlameGame {
  static const String description = '''
    In this example we show the `Tappable` mixin functionality. You can add the
    `Tappable` mixin to any `PositionComponent`.\n\n
    Tap the squares to see them change their angle around their anchor.
  ''';

  static const int maxItems = 1000000;
  final tappableRootComponent = Component(priority: 1);

  @override
  Future<void> onLoad() async {
    tappableRootComponent.add(TappableSquare(active: true)
      ..anchor = Anchor.center
      ..x = 500);

    final bottomSquare = TappableSquare(active: true)
      ..x = 500
      ..y = 350;
    tappableRootComponent.add(bottomSquare);
    world.add(tappableRootComponent);

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

    componentsAtPointRoot = tappableRootComponent;
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
