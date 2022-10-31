import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/rendering.dart';

class SnippetHudControlsGame extends FlameGame with HasTappables {
  late Flower _flower;
  final double _speed = 10.0;
  final Vector2 _velocity = Vector2(0, 0);
  int _xAxisInput = 0;

  @override
  Future<void> onLoad() async {
    const offset = 10.0;

    _flower = Flower(
      size: 40,
      position: canvasSize / 2,
    );
    add(_flower);

    final leftButton = HudButtonComponent(
      priority: 1,
      button: RectangleComponent.square(size: 30),
      margin: const EdgeInsets.only(bottom: offset, left: offset),
      onPressed: () {
        _xAxisInput = -1;
      },
      onReleased: () {
        _xAxisInput = 0;
      },
    );
    add(leftButton);

    final rightButton = HudButtonComponent(
      priority: 1,
      button: RectangleComponent.square(size: 30),
      margin: const EdgeInsets.only(bottom: offset, right: offset),
      onPressed: () {
        _xAxisInput = 1;
      },
      onReleased: () {
        _xAxisInput = 0;
      },
    );
    add(rightButton);
  }

  @override
  void update(double dt) {
    _velocity.x = _xAxisInput * _speed;
    _flower.position += _velocity * dt;
    super.update(dt);
  }
}
