import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaytraceExample extends FlameGame
    with
        HasCollisionDetection,
        TapDetector,
        MouseMovementDetector,
        TapDetector {
  static const description = '''
In this example the raytrace functionality is showcased.
Click to start sending out a ray which will bounce around to visualize how it
works. If you move the mouse around the canvas, rays and their reflections will
be moved rendered and if you click again some more objects that the rays can
bounce on will appear.
  ''';

  final _colorTween = ColorTween(
    begin: Colors.amber.withOpacity(1.0),
    end: Colors.lightBlueAccent.withOpacity(1.0),
  );
  final random = Random();
  Ray2? ray;
  Ray2? reflection;
  Vector2? origin;
  bool isOriginCasted = false;
  Paint rayPaint = Paint();
  final boxPaint = BasicPalette.gray.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  late Path path;
  @override
  Future<void> onLoad() async {
    addAll([
      ScreenHitbox(),
      CircleComponent(
        radius: min(canvasSize.x, canvasSize.y) / 2,
        paint: boxPaint,
        children: [CircleHitbox()],
      ),
    ]);
  }

  bool isClicked = false;
  final extraChildren = <Component>[];
  @override
  void onTap() {
    if (!isClicked) {
      isClicked = true;
      return;
    }
    _timePassed = 0;
    if (extraChildren.isEmpty) {
      addAll(
        extraChildren
          ..addAll(
            [
              CircleComponent(
                position: Vector2(100, 100),
                radius: 50,
                paint: boxPaint,
                children: [CircleHitbox()],
              ),
              CircleComponent(
                position: Vector2(150, 500),
                radius: 50,
                paint: boxPaint,
                anchor: Anchor.center,
                children: [CircleHitbox()],
              ),
              CircleComponent(
                position: Vector2(150, 500),
                radius: 150,
                paint: boxPaint,
                anchor: Anchor.center,
                children: [CircleHitbox()],
              ),
              RectangleComponent(
                position: Vector2.all(300),
                size: Vector2.all(100),
                paint: boxPaint,
                children: [RectangleHitbox()],
              ),
              RectangleComponent(
                position: Vector2.all(500),
                size: Vector2(100, 200),
                paint: boxPaint,
                children: [RectangleHitbox()],
              ),
              CircleComponent(
                position: Vector2(650, 275),
                radius: 50,
                paint: boxPaint,
                anchor: Anchor.center,
                children: [CircleHitbox()],
              ),
              RectangleComponent(
                position: Vector2(550, 200),
                size: Vector2(200, 150),
                paint: boxPaint,
                children: [RectangleHitbox()],
              ),
              RectangleComponent(
                position: Vector2(350, 30),
                size: Vector2(200, 150),
                paint: boxPaint,
                angle: tau / 10,
                children: [RectangleHitbox()],
              ),
            ],
          ),
      );
    } else {
      removeAll(extraChildren);
      extraChildren.clear();
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final origin = info.eventPosition.widget;
    isOriginCasted = origin == this.origin;
    this.origin = origin;
  }

  final Ray2 _ray = Ray2.zero();
  var _timePassed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isClicked) {
      _timePassed += dt;
    }
    rayPaint.color = _colorTween.transform(0.5 + (sin(_timePassed) / 2))!;
    if (origin != null) {
      _ray.origin.setFrom(origin!);
      _ray.direction
        ..setValues(1, 1)
        ..normalize();
      collisionDetection
          .raytrace(
            _ray,
            maxDepth: min((_timePassed * 8).ceil(), 1000),
            out: results,
          )
          .toList();
      isOriginCasted = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (origin != null) {
      renderResult(canvas, origin!, results, rayPaint);
    }
  }

  void renderResult(
    Canvas canvas,
    Vector2 origin,
    List<RaycastResult<ShapeHitbox>> results,
    Paint paint,
  ) {
    var originOffset = origin.toOffset();
    for (final result in results) {
      if (!result.isActive) {
        continue;
      }
      final intersectionPoint = result.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
      originOffset = intersectionPoint;
    }
  }
}
