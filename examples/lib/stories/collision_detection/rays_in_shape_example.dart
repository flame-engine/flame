import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

const playArea = Rect.fromLTRB(-100, -100, 100, 100);

class RaysInShapeExample extends FlameGame {
  static const description = '''
In this example we showcase the raytrace functionality where you can see whether
the rays are inside the shapes or not. Click to change the shape that the rays
are casted against. The rays originates from small circles, and if the circle is
inside the shape it will be red, otherwise green. And if the ray doesn't hit any
shape it will be gray.
''';

  RaysInShapeExample()
      : super(
          world: RaysInShapeWorld(),
          camera: CameraComponent.withFixedResolution(
            width: playArea.width,
            height: playArea.height,
          ),
        );
}

final whiteStroke = Paint()
  ..color = const Color(0xffffffff)
  ..style = PaintingStyle.stroke;

final lightStroke = Paint()
  ..color = const Color(0x50ffffff)
  ..style = PaintingStyle.stroke;

final greenStroke = Paint()
  ..color = const Color(0xff00ff00)
  ..style = PaintingStyle.stroke;

final redStroke = Paint()
  ..color = const Color(0xffff0000)
  ..style = PaintingStyle.stroke;

class RaysInShapeWorld extends World
    with
        HasGameReference<RaysInShapeExample>,
        HasCollisionDetection,
        TapCallbacks {
  final _rng = Random();
  List<Ray2> _rays = [];

  List<Ray2> randomRays(int count) => List<Ray2>.generate(
        count,
        (index) => Ray2(
          origin: (Vector2.random(_rng)) * playArea.size.width -
              playArea.size.toVector2() / 2,
          direction: (Vector2.random(_rng) - Vector2(0.5, 0.5)).normalized(),
        ),
      );

  int _componentIndex = 0;

  final _components = [
    CircleComponent(
      radius: 60,
      anchor: Anchor.center,
      position: Vector2.zero(),
      paint: whiteStroke,
      children: [CircleHitbox()],
    ),
    RectangleComponent(
      size: Vector2(100, 100),
      anchor: Anchor.center,
      position: Vector2.zero(),
      paint: whiteStroke,
      children: [RectangleHitbox()],
    ),
    PositionComponent(
      position: Vector2.zero(),
      children: [
        PolygonHitbox.relative(
          [
            Vector2(-0.7, -1),
            Vector2(1, -0.4),
            Vector2(0.3, 1),
            Vector2(-1, 0.6),
          ],
          parentSize: Vector2(100, 100),
          anchor: Anchor.center,
          position: Vector2.zero(),
        )
          ..paint = whiteStroke
          ..renderShape = true,
      ],
    ),
  ];

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    add(_components[_componentIndex]);
    _rays = randomRays(200);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    remove(_components[_componentIndex]);
    _componentIndex = (_componentIndex + 1) % _components.length;
    add(_components[_componentIndex]);
    _recording.clear();
    _rays = randomRays(200);
  }

  final Map<Ray2, RaycastResult<ShapeHitbox>?> _recording = {};

  @override
  void update(double dt) {
    super.update(dt);

    for (final ray in _rays) {
      final result = collisionDetection.raycast(ray);
      _recording.addAll({ray: result});
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final ray in _recording.keys) {
      final result = _recording[ray];
      if (result == null) {
        canvas.drawLine(
          ray.origin.toOffset(),
          (ray.origin + ray.direction.scaled(10)).toOffset(),
          lightStroke,
        );
        canvas.drawCircle(ray.origin.toOffset(), 1, lightStroke);
      } else {
        canvas.drawLine(
          ray.origin.toOffset(),
          result.intersectionPoint!.toOffset(),
          lightStroke,
        );
        canvas.drawCircle(
          ray.origin.toOffset(),
          1,
          result.isInsideHitbox ? redStroke : greenStroke,
        );
      }
    }
  }
}
