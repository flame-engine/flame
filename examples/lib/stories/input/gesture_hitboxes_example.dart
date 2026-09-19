import 'dart:math';

import 'package:examples/commons/path_component.dart';
import 'package:examples/commons/paths.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum Shapes { circle, rectangle, polygon, path }

class GestureHitboxesExample extends FlameGame {
  static const description = '''
    Tap to create a PositionComponent with a randomly shaped hitbox.
    You can then hover over to shapes to see that they receive the hover events
    only when the cursor is within the shape. If you tap/click within the shape
    it is removed.
  ''';

  GestureHitboxesExample() : super(world: _GestureHitboxesWorld());
}

class _GestureHitboxesWorld extends World
    with TapCallbacks, HasGameRef<GestureHitboxesExample> {
  final _rng = Random();

  PositionComponent randomShape(Vector2 position) {
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    final shapeSize =
        Vector2.all(100) + Vector2.all(50.0).scaled(_rng.nextDouble());
    final shapeAngle = _rng.nextDouble() * 6;
    final Path path = randomPath(shapeSize.toSize());
    final hitbox = switch (shapeType) {
      Shapes.circle => CircleHitbox(),
      Shapes.rectangle => RectangleHitbox(),
      Shapes.polygon => PolygonHitbox.relative(
        [
          -Vector2.random(_rng),
          Vector2.random(_rng)..x *= -1,
          Vector2.random(_rng),
          Vector2.random(_rng)..y *= -1,
        ],
        parentSize: shapeSize,
      ),
      Shapes.path => PolygonHitbox.fromPath(
        path,
        position: shapeSize * 0.5,
        anchor: .center,
      ),
    };
    if (shapeType == .path) {
      return MyPathComponent(path: path, position: position, angle: shapeAngle);
    }
    return MyShapeComponent(
      hitbox: hitbox,
      position: position,
      size: shapeSize,
      angle: shapeAngle,
    );
  }

  final _textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 16),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      FpsTextComponent(
        position: Vector2((-gameRef.size.x / 2) + 8, (gameRef.size.y / 2) - 24),
        priority: 1,
        textRenderer: _textRenderer,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(randomShape(event.localPosition));
  }
}

class MyPathComponent extends PathComponent
    with TapCallbacks, HoverCallbacks, GestureHitboxes {
  late final Color baseColor;

  MyPathComponent({
    required super.path,
    super.position,
    super.scale,
    super.angle,
  }) : super(anchor: .center, renderHitboxes: true);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    baseColor = ColorExtension.random(withAlpha: 0.8, base: 100);
    paint.color = baseColor;
  }

  @override
  void onTapDown(TapDownEvent _) {
    removeFromParent();
  }

  @override
  void onHoverEnter() {
    paint.color = paint.color.darken(0.5);
  }

  @override
  void onHoverExit() {
    paint.color = baseColor;
  }
}

class MyShapeComponent extends PositionComponent
    with TapCallbacks, HoverCallbacks, GestureHitboxes {
  final ShapeHitbox hitbox;
  late final Color baseColor;

  MyShapeComponent({
    required this.hitbox,
    super.position,
    super.size,
    super.angle,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    baseColor = ColorExtension.random(withAlpha: 0.8, base: 100);
    hitbox.paint.color = baseColor;
    hitbox.renderShape = true;
    add(hitbox);
  }

  @override
  void onTapDown(TapDownEvent _) {
    removeFromParent();
  }

  @override
  void onHoverEnter() {
    hitbox.paint.color = hitbox.paint.color.darken(0.5);
  }

  @override
  void onHoverExit() {
    hitbox.paint.color = baseColor;
  }
}
