import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

abstract class MyCollidable extends PositionComponent
    with Draggable, Hitbox, Collidable {
  double rotationSpeed = 0.0;
  final Vector2 velocity;
  final delta = Vector2.zero();
  double angleDelta = 0;
  bool _isDragged = false;
  final _activePaint = Paint()..color = Colors.amber;
  double _wallHitTime = double.infinity;

  MyCollidable(Vector2 position, Vector2 size, this.velocity) {
    this.position = position;
    this.size = size;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDragged) {
      return;
    }
    _wallHitTime += dt;
    delta.setFrom(velocity * dt);
    position.add(delta);
    angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderShapes(canvas);
    final localCenter = (size / 2).toOffset();
    if (_isDragged) {
      canvas.drawCircle(localCenter, 5, _activePaint);
    }
    if (_wallHitTime < 1.0) {
      // Show a rectangle in the center for a second if we hit the wall
      canvas.drawRect(
        Rect.fromCenter(center: localCenter, width: 10, height: 10),
        debugPaint,
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    final averageIntersection = intersectionPoints.reduce((sum, v) => sum + v) /
        intersectionPoints.length.toDouble();
    final collisionDirection = (averageIntersection - absoluteCenter)
      ..normalize()
      ..round();
    if (velocity.angleToSigned(collisionDirection).abs() > 3) {
      // This entity got hit by something else
      return;
    }
    final angleToCollision = velocity.angleToSigned(collisionDirection);
    if (angleToCollision.abs() < pi / 8) {
      velocity.rotate(pi);
    } else {
      velocity.rotate(-pi / 2 * angleToCollision.sign);
    }
    position.sub(delta * 2);
    angle = (angle - angleDelta) % (2 * pi);
    if (other is ScreenCollidable) {
      _wallHitTime = 0;
    }
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    _isDragged = true;
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndDetails details) {
    velocity.setFrom(details.velocity.pixelsPerSecond.toVector2() / 10);
    _isDragged = false;
    return true;
  }
}

class CollidablePolygon extends MyCollidable {
  CollidablePolygon(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    final shape = HitboxPolygon([
      Vector2(-1.0, 0.0),
      Vector2(-0.8, 0.6),
      Vector2(0.0, 1.0),
      Vector2(0.6, 0.9),
      Vector2(1.0, 0.0),
      Vector2(0.6, -0.8),
      Vector2(0, -1.0),
      Vector2(-0.8, -0.8),
    ]);
    addShape(shape);
  }
}

class CollidableRectangle extends MyCollidable {
  CollidableRectangle(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    addShape(HitboxRectangle());
  }
}

class CollidableCircle extends MyCollidable {
  CollidableCircle(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    final shape = HitboxCircle();
    addShape(shape);
  }
}

class SnowmanPart extends HitboxCircle {
  static const startColor = Colors.white;
  final hitPaint = Paint()
    ..color = startColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  SnowmanPart(double definition, Vector2 relativePosition, Color hitColor)
      : super(definition: definition) {
    this.relativePosition.setFrom(relativePosition);
    onCollision = (Set<Vector2> intersectionPoints, HitboxShape other) {
      if (other.component is ScreenCollidable) {
        hitPaint..color = startColor;
      } else {
        hitPaint..color = hitColor;
      }
    };
  }

  @override
  void render(Canvas canvas, Paint paint) {
    super.render(canvas, hitPaint);
  }
}

class CollidableSnowman extends MyCollidable {
  CollidableSnowman(Vector2 position, Vector2 size, Vector2 velocity)
      : super(position, size, velocity) {
    rotationSpeed = 0.2;
    final top = SnowmanPart(0.4, Vector2(0, -0.8), Colors.red);
    final middle = SnowmanPart(0.6, Vector2(0, -0.3), Colors.yellow);
    final bottom = SnowmanPart(1.0, Vector2(0, 0.5), Colors.green);
    addShape(top);
    addShape(middle);
    addShape(bottom);
  }
}

class MultipleShapes extends BaseGame
    with HasCollidables, HasDraggableComponents {
  final TextConfig fpsTextConfig = TextConfig(
    color: BasicPalette.white.color,
  );

  @override
  Future<void> onLoad() async {
    final screen = ScreenCollidable();
    final snowman = CollidableSnowman(
      Vector2.all(150),
      Vector2(100, 200),
      Vector2(-100, 100),
    );
    MyCollidable lastToAdd = snowman;
    add(screen);
    add(snowman);
    var totalAdded = 1;
    while (totalAdded < 20) {
      lastToAdd = createRandomCollidable(lastToAdd);
      final lastBottomRight =
          lastToAdd.toAbsoluteRect().bottomRight.toVector2();
      if (screen.containsPoint(lastBottomRight)) {
        add(lastToAdd);
        totalAdded++;
      } else {
        break;
      }
    }
  }

  final _rng = Random();
  final _distance = Vector2(100, 0);

  MyCollidable createRandomCollidable(MyCollidable lastCollidable) {
    MyCollidable collidable;
    final collidableSize = Vector2.all(50) + Vector2.random(_rng) * 100;
    final isXOverflow = lastCollidable.position.x +
            lastCollidable.size.x / 2 +
            _distance.x +
            collidableSize.x >
        size.x;
    var position = _distance + Vector2(0, lastCollidable.position.y + 200);
    if (!isXOverflow) {
      position = (lastCollidable.position + _distance)
        ..x += collidableSize.x / 2;
    }
    final velocity = Vector2.random(_rng) * 200;
    final rotationSpeed = 0.5 - _rng.nextDouble();
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    switch (shapeType) {
      case Shapes.circle:
        collidable = CollidableCircle(position, collidableSize, velocity);
        break;
      case Shapes.rectangle:
        collidable = CollidableRectangle(position, collidableSize, velocity)
          ..rotationSpeed = rotationSpeed;
        break;
      case Shapes.polygon:
        collidable = CollidablePolygon(position, collidableSize, velocity)
          ..rotationSpeed = rotationSpeed;
        break;
    }
    return collidable;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextConfig.render(
      canvas,
      '${fps(120).toStringAsFixed(2)}fps',
      Vector2(0, size.y - 24),
    );
  }
}
