import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The game is 800x600, and the viewfinder of the default camera is anchored
  // at the center, so that the world origin is at (400, 300) on the canvas.
  group('localToCanvas', () {
    testWithFlameGame('maps world components through the camera', (
      game,
    ) async {
      final component = PositionComponent(
        position: Vector2(110, 60),
        size: Vector2.all(10),
      );
      game.world.add(component);
      await game.ready();
      game.camera.viewfinder
        ..position = Vector2(100, 50)
        ..zoom = 2;

      final point = localToCanvas(
        component,
        Vector2(5, 0),
        camera: game.camera,
      );
      expect(point, closeToVector(Vector2(430, 320)));
    });

    testWithFlameGame('applies the transforms of all ancestors', (game) async {
      final child = PositionComponent(position: Vector2(10, 0));
      final parent = PositionComponent(
        position: Vector2(20, 0),
        angle: pi / 2,
        scale: Vector2.all(2),
        children: [child],
      );
      game.world.add(parent);
      await game.ready();

      final point = localToCanvas(child, Vector2.zero(), camera: game.camera);
      expect(point, closeToVector(Vector2(420, 320)));
    });

    testWithFlameGame('maps viewport components without the viewfinder', (
      game,
    ) async {
      final hud = PositionComponent(position: Vector2(5, 7));
      game.camera.viewport.add(hud);
      await game.ready();
      game.camera.viewfinder.zoom = 2;

      expect(localToCanvas(hud, Vector2(1, 1)), closeToVector(Vector2(6, 8)));
    });

    testWithFlameGame('maps viewfinder components through the camera', (
      game,
    ) async {
      final component = PositionComponent(position: Vector2(10, 0));
      game.camera.viewfinder.add(component);
      await game.ready();
      game.camera.viewfinder.zoom = 2;

      expect(
        localToCanvas(component, Vector2.zero()),
        closeToVector(Vector2(420, 300)),
      );
    });

    testWithFlameGame('maps components outside of worlds directly', (
      game,
    ) async {
      final component = PositionComponent(position: Vector2(3, 4));
      game.add(component);
      await game.ready();

      expect(
        localToCanvas(component, Vector2.zero()),
        closeToVector(Vector2(3, 4)),
      );
    });

    testWithFlameGame('returns null for a camera of another world', (
      game,
    ) async {
      final component = PositionComponent();
      final otherWorld = World();
      final otherCamera = CameraComponent(world: otherWorld);
      game.world.add(component);
      game.addAll([otherWorld, otherCamera]);
      await game.ready();

      expect(localToCanvas(component, Vector2.zero()), isNull);
      expect(
        localToCanvas(component, Vector2.zero(), camera: otherCamera),
        isNull,
      );
    });
  });

  group('camerasFor', () {
    testWithFlameGame('finds the cameras looking at the world', (game) async {
      final component = PositionComponent();
      final hud = PositionComponent();
      final secondCamera = CameraComponent(world: game.world);
      game.world.add(component);
      game.camera.viewport.add(hud);
      game.add(secondCamera);
      await game.ready();

      expect(camerasFor(component), [game.camera, secondCamera]);
      expect(camerasFor(hud), [null]);
    });
  });

  group('GizmoGeometry', () {
    testWithFlameGame('describes the outline, anchor and axes', (game) async {
      final component = PositionComponent(
        position: Vector2(0, 0),
        size: Vector2(20, 10),
        anchor: Anchor.center,
        angle: pi / 2,
      );
      game.world.add(component);
      await game.ready();

      final geometry = GizmoGeometry.of(component).single;
      expect(geometry.anchor, _closeToOffset(const Offset(400, 300)));
      expect(geometry.xAxis, _closeToOffset(const Offset(0, 1)));
      expect(geometry.yAxis, _closeToOffset(const Offset(-1, 0)));
      // Rotated by 90 degrees, the 20x10 outline becomes 10x20.
      expect(geometry.corners[0], _closeToOffset(const Offset(405, 290)));
      expect(geometry.corners[2], _closeToOffset(const Offset(395, 310)));
    });
  });
}

Matcher _closeToOffset(Offset expected) {
  return predicate<Offset>(
    (offset) => (offset - expected).distance < 1e-6,
    'is close to $expected',
  );
}
