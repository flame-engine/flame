import 'dart:math';

import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' show Colors, Paint, Canvas;

class RaycastExample extends Forge2DGame
    with TapDetector, MouseMovementDetector {
  static const String description = '''
    This example shows how raycasts can be used to find nearest and farthest
    fixtures.
    Red ray finds the nearest fixture and blue ray finds the farthest fixture.
  ''';

  final random = Random();

  final redPoints = List<Vector2>.empty(growable: true);
  final bluePoints = List<Vector2>.empty(growable: true);

  Box? nearestBox;
  Box? farthestBox;

  RaycastExample() : super(gravity: Vector2.zero());

  @override
  Future<void> onLoad() async {
    addAll(createBoundaries(this));

    final worldCenter = screenToWorld(camera.viewport.effectiveSize / 2);

    const numberOfRows = 3;
    const numberOfBoxes = 4;
    for (var i = 0; i < numberOfBoxes; ++i) {
      for (var j = 0; j < numberOfRows; ++j) {
        final position = worldCenter + Vector2(i * 10, j * 20 - 20);
        add(Box(position));
      }
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    bluePoints.clear();

    final rayStart = screenToWorld(
      camera.viewport.effectiveSize / 2 -
          Vector2(camera.viewport.effectiveSize.x / 4, 0),
    );

    final redRayTarget = info.eventPosition.game + Vector2(0, 2);
    fireRedRay(rayStart, redRayTarget);

    final blueRayTarget = info.eventPosition.game - Vector2(0, 2);
    fireBlueRay(rayStart, blueRayTarget);

    super.onMouseMove(info);
  }

  void fireBlueRay(Vector2 rayStart, Vector2 blueRayTarget) {
    bluePoints.add(worldToScreen(rayStart));

    final farthestCallback = FarthestBoxRayCastCallback();
    world.raycast(farthestCallback, rayStart, blueRayTarget);

    if (farthestCallback.farthestPoint != null) {
      bluePoints.add(worldToScreen(farthestCallback.farthestPoint!));
    } else {
      bluePoints.add(worldToScreen(blueRayTarget));
    }
    farthestBox = farthestCallback.box;
  }

  void fireRedRay(Vector2 rayStart, Vector2 rayTarget) {
    redPoints.clear();
    redPoints.add(worldToScreen(rayStart));

    final nearestCallback = NearestBoxRayCastCallback();
    world.raycast(nearestCallback, rayStart, rayTarget);

    if (nearestCallback.nearestPoint != null) {
      redPoints.add(worldToScreen(nearestCallback.nearestPoint!));
    } else {
      redPoints.add(worldToScreen(rayTarget));
    }
    nearestBox = nearestCallback.box;
  }

  @override
  void update(double dt) {
    children.whereType<Box>().forEach((component) {
      if ((component == nearestBox) && (component == farthestBox)) {
        component.paint.color = Colors.yellow;
      } else if (component == nearestBox) {
        component.paint.color = Colors.red;
      } else if (component == farthestBox) {
        component.paint.color = Colors.blue;
      } else {
        component.paint.color = Colors.white;
      }
    });
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (var i = 0; i < redPoints.length - 1; ++i) {
      canvas.drawLine(
        redPoints[i].toOffset(),
        redPoints[i + 1].toOffset(),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 4,
      );
    }

    for (var i = 0; i < bluePoints.length - 1; ++i) {
      canvas.drawLine(
        bluePoints[i].toOffset(),
        bluePoints[i + 1].toOffset(),
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 4,
      );
    }
  }
}

class Box extends BodyComponent {
  final Vector2 position;

  Box(this.position);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(2.0, 4.0);
    final fixtureDef = FixtureDef(shape, userData: this);
    final bodyDef = BodyDef(position: position);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class NearestBoxRayCastCallback extends RayCastCallback {
  Box? box;
  Vector2? nearestPoint;
  Vector2? normalAtInter;

  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) {
    nearestPoint = point.clone();
    normalAtInter = normal.clone();
    box = fixture.userData as Box?;

    // Returning fraction implies that we care only about
    // fixtures that are closer to ray start point than
    // the current fixture
    return fraction;
  }
}

class FarthestBoxRayCastCallback extends RayCastCallback {
  Box? box;
  Vector2? farthestPoint;
  Vector2? normalAtInter;
  double previousFraction = 0.0;

  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) {
    // Value of fraction is directly proportional to
    // the distance of fixture from ray start point.
    // So we are interested in the current fixture only if
    // it has a higher fraction value than previousFraction.
    if (previousFraction < fraction) {
      farthestPoint = point.clone();
      normalAtInter = normal.clone();
      box = fixture.userData as Box?;
      previousFraction = fraction;
    }

    return 1;
  }
}
