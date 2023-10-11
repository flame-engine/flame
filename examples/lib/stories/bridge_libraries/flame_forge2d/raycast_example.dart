import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' show Colors, Paint, Canvas;

class RaycastExample extends Forge2DGame with MouseMovementDetector {
  static const String description = '''
    This example shows how raycasts can be used to find nearest and farthest
    fixtures.
    Red ray finds the nearest fixture and blue ray finds the farthest fixture.
  ''';

  final random = Random();

  final redPoints = <Vector2>[];
  final bluePoints = <Vector2>[];

  Box? nearestBox;
  Box? farthestBox;

  RaycastExample() : super(gravity: Vector2.zero());

  @override
  Future<void> onLoad() async {
    super.onLoad();
    world.addAll(createBoundaries(this));

    const numberOfRows = 3;
    const numberOfBoxes = 4;
    for (var i = 0; i < numberOfBoxes; ++i) {
      for (var j = 0; j < numberOfRows; ++j) {
        world.add(Box(Vector2(i * 10, j * 20 - 20)));
      }
    }
    world.add(
      LineComponent(
        redPoints,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1,
      ),
    );
    world.add(
      LineComponent(
        bluePoints,
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 1,
      ),
    );
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final rayStart = screenToWorld(
      Vector2(
        camera.viewport.size.x / 4,
        camera.viewport.size.y / 2,
      ),
    );

    final worldPosition = screenToWorld(info.eventPosition.widget);
    final redRayTarget = worldPosition + Vector2(0, 2);
    fireRedRay(rayStart, redRayTarget);

    final blueRayTarget = worldPosition - Vector2(0, 2);
    fireBlueRay(rayStart, blueRayTarget);

    super.onMouseMove(info);
  }

  void fireBlueRay(Vector2 rayStart, Vector2 rayTarget) {
    bluePoints.clear();
    bluePoints.add(rayStart);

    final farthestCallback = FarthestBoxRayCastCallback();
    world.raycast(farthestCallback, rayStart, rayTarget);

    if (farthestCallback.farthestPoint != null) {
      bluePoints.add(farthestCallback.farthestPoint!);
    } else {
      bluePoints.add(rayTarget);
    }
    farthestBox = farthestCallback.box;
  }

  void fireRedRay(Vector2 rayStart, Vector2 rayTarget) {
    redPoints.clear();
    redPoints.add(rayStart);

    final nearestCallback = NearestBoxRayCastCallback();
    world.raycast(nearestCallback, rayStart, rayTarget);

    if (nearestCallback.nearestPoint != null) {
      redPoints.add(nearestCallback.nearestPoint!);
    } else {
      redPoints.add(rayTarget);
    }
    nearestBox = nearestCallback.box;
  }

  @override
  void update(double dt) {
    super.update(dt);
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
  }
}

class LineComponent extends Component {
  LineComponent(this.points, this.paint);

  final List<Vector2> points;
  final Paint paint;
  final Path path = Path();

  @override
  void update(double dt) {
    path
      ..reset()
      ..addPolygon(
        points.map((p) => p.toOffset()).toList(growable: false),
        false,
      );
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < points.length - 1; ++i) {
      canvas.drawLine(
        points[i].toOffset(),
        points[i + 1].toOffset(),
        paint,
      );
    }
  }
}

class Box extends BodyComponent {
  Box(this.initialPosition);

  final Vector2 initialPosition;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(2.0, 4.0);
    final fixtureDef = FixtureDef(shape, userData: this);
    final bodyDef = BodyDef(position: initialPosition);
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
