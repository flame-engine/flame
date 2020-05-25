import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

class Player extends SpriteComponent {
  double maxSpeed = 100; // pixels per second
  Offset velocity = Offset.zero;

  Player() {
    sprite = Sprite('player.png');
    anchor = Anchor.center;
  }

  void updateVelocity(Offset relativeVelocity) {
    // The relative velocity's distance (size) is in range 0-1.
    // Multiplying it by the maxSpeed will result in a vector that has the same
    // direction and has a size which is a certain percentage of the maxSpeed.
    velocity = relativeVelocity * maxSpeed;
  }

  @override
  void resize(Size size) {
    // The player's size will be 12% of the screens width
    width = height = size.width * 0.12;
    x = size.width / 2;
    y = size.height / 2;
  }

  @override
  void update(double t) {
    super.update(t);
    // Update the player's position according to the velocity
    x += velocity.dx * t;
    y += velocity.dy * t;
  }
}
