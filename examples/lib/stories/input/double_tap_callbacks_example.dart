import 'package:examples/commons/ember.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DoubleTapCallbacksExample extends FlameGame {
  static const String description = '''
  In this example, we show you can use the `DoubleTapCallbacks` mixin on
  `Component`. Double tap the Ember and see the color changes.
''';

  DoubleTapCallbacksExample();

  @override
  Future<void> onLoad() async {
    children.register<DoubleTappableEmper>();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    children
        .query<DoubleTappableEmper>()
        .forEach((element) => element.removeFromParent());
    add(DoubleTappableEmper(position: canvasSize / 2));

    super.onGameResize(canvasSize);
  }
}

enum _EmberStatus {
  initial,
  down,
  cancel,
  doubleTap,
}

class DoubleTappableEmper extends Ember with DoubleTapCallbacks {
  _EmberStatus status = _EmberStatus.initial;
  @override
  bool debugMode = true;

  DoubleTappableEmper({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  @override
  void onDoubleTap(DoubleTapEvent event) {
    debugColor = Colors.greenAccent;
  }

  @override
  void onDoubleTapCancel(DoubleTapCancelEvent event) {
    debugColor = Colors.red;
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    debugColor = Colors.blue;
  }
}
