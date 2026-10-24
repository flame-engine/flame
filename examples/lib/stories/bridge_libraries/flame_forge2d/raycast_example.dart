import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:material_ui/material_ui.dart' show Colors, Paint;

class RaycastExample() extends Forge2DExampleGame with MouseMoveCallbacks {
  static const String description = '''
    This example shows how ray casts can be used to find the nearest and
    farthest shapes.
    The red ray finds the nearest shape, the blue ray the farthest shape and
    the green ray marks every shape that it passes through.
    All rays are `RayCastComponent`s, which cast and render their rays on
    every update.
  ''';

  final random = Random();

  final redRay = RayCastComponent(
    paint: Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5,
    hitRadius: 1,
  );
  final blueRay = RayCastComponent(
    paint: Paint()
      ..color = Colors.blue
      ..strokeWidth = 0.5,
    mode: RayCastMode.farthest,
    hitRadius: 1,
  );
  final greenRay = RayCastComponent(
    paint: Paint()
      ..color = Colors.green
      ..strokeWidth = 0.5,
    mode: RayCastMode.all,
    hitRadius: 1,
  );

  this : super(gravity: Vector2.zero());

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
    world.addAll([redRay, blueRay, greenRay]);
  }

  @override
  void onMouseMove(MouseMoveEvent event) {
    final rayStart = screenToWorld(
      Vector2(
        camera.viewport.size.x / 4,
        camera.viewport.size.y / 2,
      ),
    );

    final worldPosition = screenToWorld(event.canvasPosition);
    aimRay(redRay, rayStart, worldPosition + Vector2(0, 2));
    aimRay(blueRay, rayStart, worldPosition - Vector2(0, 2));
    aimRay(greenRay, rayStart, worldPosition);

    super.onMouseMove(event);
  }

  void aimRay(RayCastComponent ray, Vector2 rayStart, Vector2 rayTarget) {
    ray.origin.setFrom(rayStart);
    ray.translation
      ..setFrom(rayTarget)
      ..sub(rayStart);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final nearestBox = redRay.hit?.shape.userData as Box?;
    final farthestBox = blueRay.hit?.shape.userData as Box?;
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

class Box(final Vector2 initialPosition) extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(position: initialPosition);
    return world.createBody(bodyDef)
      ..createShape(Polygon.box(2.0, 4.0), ShapeDef(userData: this));
  }
}
