import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

class MultipleShapesExample extends FlameGame
    with HasCollisionDetection, HasDraggables, FPSCounter {
  static const description = '''
    An example with many hitboxes that move around on the screen and during
    collisions they change color depending on what it is that they have collided
    with. 
    
    The snowman, the component built with three circles on top of each other, 
    works a little bit differently than the other components to show that you
    can have multiple hitboxes within one component.
    
    On this example, you can "throw" the components by dragging them quickly in
    any direction.
  ''';

  final TextPaint fpsTextPaint = TextPaint();

  @override
  Future<void> onLoad() async {
    final screenCollidable = ScreenCollidable();
    final snowman = CollidableSnowman(
      Vector2.all(150),
      Vector2(120, 250),
      Vector2(-100, 100),
      screenCollidable,
    );
    MyCollidable lastToAdd = snowman;
    add(screenCollidable);
    add(snowman);
    var totalAdded = 1;
    while (totalAdded < 100) {
      lastToAdd = nextRandomCollidable(lastToAdd, screenCollidable);
      final lastBottomRight =
          lastToAdd.toAbsoluteRect().bottomRight.toVector2();
      if (lastBottomRight.x < size.x && lastBottomRight.y < size.y) {
        add(lastToAdd);
        totalAdded++;
      } else {
        break;
      }
    }
  }

  final _rng = Random();
  final _distance = Vector2(100, 0);

  MyCollidable nextRandomCollidable(
    MyCollidable lastCollidable,
    ScreenCollidable screenCollidable,
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
    return randomCollidable(
      position,
      collidableSize,
      velocity,
      screenCollidable,
      rng: _rng,
    );
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

abstract class MyCollidable extends PositionComponent
    with Draggable, CollisionCallbacks, GestureHitboxes {
  double rotationSpeed = 0.0;
  final Vector2 velocity;
  final delta = Vector2.zero();
  double angleDelta = 0;
  final Color _defaultColor = Colors.blue.withOpacity(0.8);
  final Color _collisionColor = Colors.green.withOpacity(0.8);
  late final Paint _dragIndicatorPaint;
  final ScreenCollidable screenCollidable;
  HitboxShape? hitbox;

  MyCollidable(
    Vector2 position,
    Vector2 size,
    this.velocity,
    this.screenCollidable,
  ) : super(position: position, size: size, anchor: Anchor.center) {
    _dragIndicatorPaint = BasicPalette.white.paint();
  }

  @override
  void onMount() {
    hitbox?.paint.color = _defaultColor;
    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDragged) {
      return;
    }
    delta.setFrom(velocity * dt);
    position.add(delta);
    angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);
    // Takes rotation into consideration (which topLeftPosition doesn't)
    final topLeft = absoluteCenter - (scaledSize / 2);
    if (topLeft.x + scaledSize.x < 0 ||
        topLeft.y + scaledSize.y < 0 ||
        topLeft.x > screenCollidable.scaledSize.x ||
        topLeft.y > screenCollidable.scaledSize.y) {
      final moduloSize = screenCollidable.scaledSize + scaledSize;
      topLeftPosition = topLeftPosition % moduloSize;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      final localCenter = (scaledSize / 2).toOffset();
      canvas.drawCircle(localCenter, 5, _dragIndicatorPaint);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox?.paint.color = _collisionColor;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox?.paint.color = _defaultColor;
    }
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    velocity.setFrom(info.velocity / 10);
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
    hitbox = HitboxPolygon.fromNormals(
      [
        Vector2(-1.0, 0.0),
        Vector2(-0.8, 0.6),
        Vector2(0.0, 1.0),
        Vector2(0.6, 0.9),
        Vector2(1.0, 0.0),
        Vector2(0.6, -0.8),
        Vector2(0, -1.0),
        Vector2(-0.8, -0.8),
      ],
      size: size,
    )..renderShape = true;
    add(hitbox!);
  }
}

class CollidableRectangle extends MyCollidable {
  CollidableRectangle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    hitbox = HitboxRectangle()..renderShape = true;
    add(hitbox!);
  }
}

class CollidableCircle extends MyCollidable {
  CollidableCircle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    hitbox = HitboxCircle()..renderShape = true;
    add(hitbox!);
  }
}

class SnowmanPart extends HitboxCircle {
  @override
  final renderShape = true;
  final startColor = Colors.white.withOpacity(0.8);
  final Color hitColor;

  SnowmanPart(double radius, Vector2 position, this.hitColor)
      : super(radius: radius, position: position, anchor: Anchor.center) {
    paint.color = startColor;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, HitboxShape other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.hitboxParent is ScreenCollidable) {
      paint.color = startColor;
    } else {
      paint.color = hitColor.withOpacity(0.8);
    }
  }

  @override
  void onCollisionEnd(HitboxShape other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      paint.color = startColor;
    }
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
    final top = SnowmanPart(
      size.x * 0.3,
      Vector2(size.x / 2, size.y * 0.15),
      Colors.red,
    );
    final middle = SnowmanPart(
      size.x * 0.4,
      Vector2(size.x / 2, size.y * 0.40),
      Colors.yellow,
    );
    final bottom = SnowmanPart(
      size.x / 2,
      Vector2(size.x / 2, size.y - size.y / 4),
      Colors.green,
    );
    add(bottom);
    add(middle);
    add(top);
  }
}

MyCollidable randomCollidable(
  Vector2 position,
  Vector2 size,
  Vector2 velocity,
  ScreenCollidable screenCollidable, {
  Random? rng,
}) {
  final _rng = rng ?? Random();
  final rotationSpeed = 0.5 - _rng.nextDouble();
  final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
  switch (shapeType) {
    case Shapes.circle:
      return CollidableCircle(position, size, velocity, screenCollidable)
        ..rotationSpeed = rotationSpeed;
    case Shapes.rectangle:
      return CollidableRectangle(position, size, velocity, screenCollidable)
        ..rotationSpeed = rotationSpeed;
    case Shapes.polygon:
      return CollidablePolygon(position, size, velocity, screenCollidable)
        ..rotationSpeed = rotationSpeed;
  }
}
