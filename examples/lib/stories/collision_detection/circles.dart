import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

const circlesInfo = '''
This example will create a circle every time you tap on the screen. It will have
the initial velocity towards the center of the screen and if it touches another
circle both of them will change color.
''';

class MyCollidable extends PositionComponent
    with HasGameRef<Circles>, Hitbox, Collidable {
  late Vector2 velocity;
  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  bool _isWallHit = false;
  bool _isCollision = false;

  MyCollidable(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(100),
          anchor: Anchor.center,
        ) {
    addHitbox(HitboxCircle());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final center = gameRef.size / 2;
    velocity = (center - position)..scaleTo(150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isWallHit) {
      removeFromParent();
      return;
    }
    debugColor = _isCollision ? _collisionColor : _defaultColor;
    position.add(velocity * dt);
    _isCollision = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderHitboxes(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is ScreenCollidable) {
      _isWallHit = true;
      return;
    }
    _isCollision = true;
  }
}

class Circles extends FlameGame with HasCollidables, TapDetector {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(ScreenCollidable());
  }

  @override
  void onTapDown(TapDownInfo info) {
    add(MyCollidable(info.eventPosition.game));
  }
}
