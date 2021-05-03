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
  final ScreenCollidable screenCollidable;

  MyCollidable(
    Vector2 position,
    Vector2 size,
    this.velocity,
    this.screenCollidable,
  ) {
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
    // Takes rotation into consideration (which topLeftPosition doesn't)
    final topLeft = absoluteCenter - (size / 2);
    if (topLeft.x + size.x < 0 ||
        topLeft.y + size.y < 0 ||
        topLeft.x > screenCollidable.size.x ||
        topLeft.y > screenCollidable.size.y) {
      final moduloSize = screenCollidable.size + (size * gameRef.camera.zoom);
      topLeftPosition = topLeftPosition % moduloSize;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isDragged) {
      final localCenter = (size / 2).toOffset();
      canvas.drawCircle(localCenter, 5, _activePaint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    _isHit = true;
    switch (other.runtimeType) {
      case ScreenCollidable:
        debugColor = Colors.teal;
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
      case CollidableSnowman:
        debugColor = Colors.amber;
        break;
      default:
        debugColor = Colors.pink;
    }
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
  CollidablePolygon(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
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
  CollidableRectangle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    addShape(HitboxRectangle());
  }
}

class CollidableCircle extends MyCollidable {
  CollidableCircle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
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

  SnowmanPart(double definition, Vector2 relativeOffset, Color hitColor)
      : super(definition: definition) {
    this.relativeOffset.setFrom(relativeOffset);
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
  CollidableSnowman(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    rotationSpeed = 0.3;
    anchor = Anchor.topLeft;
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
    await super.onLoad();
    final screenCollidable = ScreenCollidable();
    final snowman = CollidableSnowman(
      Vector2.all(150),
      Vector2(100, 200),
      Vector2(-100, 100),
      screenCollidable,
    );
    MyCollidable lastToAdd = snowman;
    add(screenCollidable);
    add(snowman);
    var totalAdded = 1;
    while (totalAdded < 10) {
      lastToAdd = createRandomCollidable(lastToAdd, screenCollidable);
      final lastBottomRight =
          lastToAdd.toAbsoluteRect().bottomRight.toVector2();
      final screenSize = size / camera.zoom;
      if (lastBottomRight.x < screenSize.x &&
          lastBottomRight.y < screenSize.y) {
        add(lastToAdd);
        totalAdded++;
      } else {
        break;
      }
    }
  }

  final _rng = Random();
  final _distance = Vector2(100, 0);

  MyCollidable createRandomCollidable(
    MyCollidable lastCollidable,
    ScreenCollidable screen,
  ) {
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
    final velocity = (Vector2.random(_rng) - Vector2.random(_rng)) * 400;
    final rotationSpeed = 0.5 - _rng.nextDouble();
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    switch (shapeType) {
      case Shapes.circle:
        return CollidableCircle(position, collidableSize, velocity, screen)
          ..rotationSpeed = rotationSpeed;
      case Shapes.rectangle:
        return CollidableRectangle(position, collidableSize, velocity, screen)
          ..rotationSpeed = rotationSpeed;
      case Shapes.polygon:
        return CollidablePolygon(position, collidableSize, velocity, screen)
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
