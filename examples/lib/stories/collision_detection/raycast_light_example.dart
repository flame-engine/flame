import 'dart:math';

import 'package:examples/commons/paths_creation_mixin.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaycastLightExample extends FlameGame
    with
        HasCollisionDetection,
        TapCallbacks,
        MouseMoveCallbacks,
        PathsCreationMixin {
  static const description = '''
In this example the raycast functionality is showcased by using it as a light
source, if you move the mouse around the canvas the rays will be cast from its
location. You can also tap to create a permanent source of rays that wont move
with with mouse.
  ''';

  Ray2? ray;
  Ray2? reflection;
  Vector2? origin;
  Vector2? tapOrigin;
  bool isOriginCasted = false;
  bool isTapOriginCasted = false;
  Paint paint = Paint();
  Paint tapPaint = Paint();

  final _colorTween = ColorTween(
    begin: Colors.blue.withValues(alpha: 0.2),
    end: Colors.red.withValues(alpha: 0.2),
  );

  static const numberOfRays = 2000;
  final List<Ray2> rays = [];
  final List<Ray2> tapRays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];
  final List<RaycastResult<ShapeHitbox>> tapResults = [];

  late Path path;
  @override
  Future<void> onLoad() async {
    final paint = BasicPalette.gray.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    add(ScreenHitbox());
    addFixedPaths(paint);
    addTestPaths(paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final origin = event.canvasPosition;
    isTapOriginCasted = origin == tapOrigin;
    tapOrigin = origin;
  }

  @override
  void onMouseMove(MouseMoveEvent event) {
    final origin = event.canvasPosition;
    isOriginCasted = origin == this.origin;
    this.origin = origin;
  }

  var _timePassed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _timePassed += dt;
    paint.color = _colorTween.transform(0.5 + (sin(_timePassed) / 2))!;
    tapPaint.color = _colorTween.transform(0.5 + (cos(_timePassed) / 2))!;
    if (origin != null && !isOriginCasted) {
      collisionDetection.raycastAll(
        origin!,
        numberOfRays: numberOfRays,
        rays: rays,
        out: results,
      );
      isOriginCasted = true;
    }
    if (tapOrigin != null && !isTapOriginCasted) {
      collisionDetection.raycastAll(
        tapOrigin!,
        numberOfRays: numberOfRays,
        rays: tapRays,
        out: tapResults,
      );
      isTapOriginCasted = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (origin != null) {
      renderResult(canvas, origin!, results, paint);
    }
    if (tapOrigin != null) {
      renderResult(canvas, tapOrigin!, tapResults, tapPaint);
    }
  }

  void renderResult(
    Canvas canvas,
    Vector2 origin,
    List<RaycastResult<ShapeHitbox>> results,
    Paint paint,
  ) {
    final originOffset = origin.toOffset();
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
    }
  }
}
