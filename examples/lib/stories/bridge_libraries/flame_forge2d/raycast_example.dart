import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' show Colors, Paint, Canvas;

class RaycastExample extends Forge2DExampleGame with MouseMovementDetector {
  static const String description = '''
    This example shows how ray casts can be used to find the nearest and
    farthest shapes.
    The red ray finds the nearest shape and the blue ray the farthest shape.
  ''';

  final random = Random();

  final redPoints = <Vector2>[];
  final bluePoints = <Vector2>[];

  Box? nearestBox;
  Box? farthestBox;

  RaycastExample() : super(gravity: Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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

    final hits = world.castRayAll(rayStart, rayTarget - rayStart);
    if (hits.isNotEmpty) {
      // The hits are sorted from nearest to farthest.
      final farthestHit = hits.last;
      bluePoints.add(farthestHit.point.clone());
      farthestBox = farthestHit.shape.userData as Box?;
    } else {
      bluePoints.add(rayTarget);
      farthestBox = null;
    }
  }

  void fireRedRay(Vector2 rayStart, Vector2 rayTarget) {
    redPoints.clear();
    redPoints.add(rayStart);

    final nearestHit = world.castRayClosest(rayStart, rayTarget - rayStart);
    if (nearestHit != null) {
      redPoints.add(nearestHit.point.clone());
      nearestBox = nearestHit.shape.userData as Box?;
    } else {
      redPoints.add(rayTarget);
      nearestBox = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    world.children.whereType<Box>().forEach((component) {
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
    final bodyDef = BodyDef(position: initialPosition);
    return world.createBody(bodyDef)
      ..createShape(Polygon.box(2.0, 4.0), ShapeDef(userData: this));
  }
}
