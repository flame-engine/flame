import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

abstract class MyCollidable extends PositionComponent
    with Draggable, Hitbox, Collidable, HasGameRef<MultipleShapes> {
  double rotationSpeed = 0.0;
  final Vector2 velocity;
  final delta = Vector2.zero();
  double angleDelta = 0;
  bool _isDragged = false;
  final _activePaint = Paint()..color = Colors.amber;
  late final Color _defaultDebugColor = debugColor;
  bool _isHit = false;

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
    if (!_isHit) {
      debugColor = _defaultDebugColor;
    } else {
      _isHit = false;
    }
    delta.setFrom(velocity * dt);
    position.add(delta);
    angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final localCenter = (size / 2).toOffset();
    if (_isDragged) {
      canvas.drawCircle(localCenter, 5, _activePaint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    _isHit = true;
    switch (other.runtimeType) {
      case ScreenCollidable:
        _handleScreenCollision(intersectionPoints);
        break;
      case CollidablePolygon:
        debugColor = Colors.blue;
        break;
      case CollidableCircle:
        debugColor = Colors.green;
        break;
      case CollidableRectangle:
        debugColor = Colors.cyan;
        break;
      default:
        debugColor = Colors.pink;
    }
  }

  void _handleScreenCollision(Set<Vector2> intersectionPoints) {
    final averageIntersection = intersectionPoints.reduce((sum, v) => sum + v) /
        intersectionPoints.length.toDouble();
    final collisionDirection = (averageIntersection - absoluteCenter)
      ..normalize()
      ..round();
    final angleToCollision = velocity.angleToSigned(collisionDirection);
    const fuzzyBorder = 10;
    if (averageIntersection.x > gameRef.size.x - fuzzyBorder) {

    } else if (averageIntersection.y > gameRef.size.y - fuzzyBorder) {

    } else if (averageIntersection.x < fuzzyBorder) {

    } else if (averageIntersection.y < fuzzyBorder) {

    }
    velocity.rotate(pi- 2 * angleToCollision);
    position.add(velocity.normalized() * delta.length * 1.1);
    angle = (angle - angleDelta) % (2 * pi);
  }

  @override
  bool onDragUpdate(int pointerId, _) {
    _isDragged = true;
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo event) {
    velocity.setFrom(event.velocity / 10);
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
  void render(Canvas canvas, _) {
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
  @override
  bool debugMode = true;

  final TextPaint fpsTextPaint = TextPaint(
    config: TextPaintConfig(
      color: BasicPalette.white.color,
    ),
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
        return CollidableCircle(position, collidableSize, velocity)
          ..rotationSpeed = rotationSpeed;
      case Shapes.rectangle:
        return CollidableRectangle(position, collidableSize, velocity)
          ..rotationSpeed = rotationSpeed;
      case Shapes.polygon:
        return CollidablePolygon(position, collidableSize, velocity)
          ..rotationSpeed = rotationSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextPaint.render(
      canvas,
      '${fps(120).toStringAsFixed(2)}fps',
      Vector2(0, size.y - 24),
    );
  }
}
