import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DoubleTapCallbacksExample extends FlameGame with DoubleTapCallbacks {
  static const String description = '''
  In this example, we show you can use the `DoubleTapCallbacks` mixin on
  `Component`. Double tap the Ember and see the color changes.
  This example also shows white circles to the position on the game you 
  double-tapped.
''';

  DoubleTapCallbacksExample();

  @override
  Future<void> onLoad() async {
    children.register<DoubleTappableEmber>();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    children
        .query<DoubleTappableEmber>()
        .forEach((element) => element.removeFromParent());
    add(DoubleTappableEmber(position: canvasSize / 2));

    super.onGameResize(canvasSize);
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    add(
      CircleComponent(
        radius: 30,
        position: event.localPosition,
        anchor: Anchor.center,
      ),
    );
  }
}

enum _EmberStatus {
  initial,
  down,
  cancel,
  doubleTap,
}

class DoubleTappableEmber extends Ember with DoubleTapCallbacks {
  _EmberStatus status = _EmberStatus.initial;
  @override
  bool debugMode = true;

  DoubleTappableEmber({Vector2? position})
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
