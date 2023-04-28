import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DoubleTapCallbacksExample extends FlameGame with DoubleTapCallbacks {
  static const String description = '''
  In this example, we show how you can use the `DoubleTapCallbacks` mixin on
  a `Component`. Double tap Ember and see her color changing.
  The example also adds white circles when double-tapping on the game area.
''';

  @override
  Future<void> onLoad() async {
    children.register<DoubleTappableEmber>();
  }

  @override
  void onGameResize(Vector2 size) {
    children
        .query<DoubleTappableEmber>()
        .forEach((element) => element.removeFromParent());
    add(DoubleTappableEmber(position: size / 2));

    super.onGameResize(size);
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

class DoubleTappableEmber extends Ember with DoubleTapCallbacks {
  @override
  bool debugMode = true;

  DoubleTappableEmber({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

  @override
  void onDoubleTapUp(DoubleTapEvent event) {
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
