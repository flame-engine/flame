import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/flame_studio.dart';
import 'package:flutter/widgets.dart';

void main() {
  runFlameStudio(
    Container(
      color: const Color(0xFF1F2933),
      child: GameWidget(game: ExampleGame()),
    ),
  );
}

/// A small scene to try out the studio with: a player with nested
/// components, a crate, a text label and a couple of moving coins.
class ExampleGame() extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void onLoad() {
    addAll([
      Player(position: Vector2(200, 300)),
      Crate(position: Vector2(470, 220)),
      Coin(restPosition: Vector2(330, 480), phase: 0),
      Coin(restPosition: Vector2(330, 540), phase: pi),
      Label(),
    ]);
  }
}

class Player({required super.position}) extends RectangleComponent {
  this
    : super(
        size: Vector2.all(72),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF26A69A),
        children: [
          Eye(position: Vector2(22, 26)),
          Eye(position: Vector2(50, 26)),
        ],
      );
}

class Eye({required super.position}) extends CircleComponent {
  this
    : super(
        radius: 6,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFFFFFFF),
      );
}

class Crate({required super.position}) extends RectangleComponent {
  this
    : super(
        size: Vector2.all(56),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF8D6E63),
      );
}

/// A coin that moves from side to side around [restPosition].
class Coin({
  required final Vector2 restPosition,
  required final double phase,
}) extends CircleComponent {
  this
    : super(
        radius: 12,
        anchor: Anchor.center,
        position: restPosition.clone(),
        paint: Paint()..color = const Color(0xFFFFD54F),
      );

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    position.x = restPosition.x + 160 * sin(_time * 1.5 + phase);
  }
}

class Label() extends TextComponent {
  this
    : super(
        text: 'Flame Studio',
        position: Vector2(332, 40),
        anchor: Anchor.topCenter,
      );
}
