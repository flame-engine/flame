import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/gizmo/move_drag.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GizmoGeometry.handleAt', () {
    const geometry = GizmoGeometry(
      corners: [],
      anchor: Offset(100, 100),
      xAxis: Offset(1, 0),
      yAxis: Offset(0, 1),
    );

    test('finds the handles near the pointer', () {
      expect(geometry.handleAt(const Offset(130, 102)), GizmoHandle.x);
      expect(geometry.handleAt(const Offset(98, 130)), GizmoHandle.y);
      expect(geometry.handleAt(const Offset(113, 113)), GizmoHandle.free);
      expect(geometry.handleAt(const Offset(200, 200)), isNull);
      expect(geometry.handleAt(const Offset(150, 100)), isNull);
    });

    test('picks the nearest axis where they meet', () {
      expect(geometry.handleAt(const Offset(104, 101)), GizmoHandle.x);
      expect(geometry.handleAt(const Offset(101, 104)), GizmoHandle.y);
    });
  });

  group('MoveDrag', () {
    testWithFlameGame('converts canvas drags through the camera', (
      game,
    ) async {
      final component = PositionComponent(position: Vector2(10, 20));
      game.world.add(component);
      await game.ready();
      game.camera.viewfinder.zoom = 2;

      final drag = MoveDrag.start(
        component,
        GizmoHandle.free,
        camera: game.camera,
        snapStep: 8,
      )!;
      drag.update(Vector2(20, 10));
      expect(component.position, closeToVector(Vector2(20, 25)));

      drag.update(Vector2(-4, 0));
      expect(component.position, closeToVector(Vector2(8, 20)));

      drag.cancel();
      expect(component.position, closeToVector(Vector2(10, 20)));
    });

    testWithFlameGame('constrains drags to the dragged axis', (game) async {
      final component = PositionComponent(angle: pi / 2);
      game.world.add(component);
      await game.ready();

      // Rotated by 90 degrees, the local x axis points down.
      MoveDrag.start(
        component,
        GizmoHandle.x,
        camera: game.camera,
        snapStep: 8,
      )!.update(Vector2(20, 10));
      expect(component.position, closeToVector(Vector2(0, 10)));

      MoveDrag.start(
        component,
        GizmoHandle.y,
        camera: game.camera,
        snapStep: 8,
      )!.update(Vector2(20, 10));
      expect(component.position, closeToVector(Vector2(20, 10)));
    });

    testWithFlameGame('accounts for the transforms of the parent', (
      game,
    ) async {
      final component = PositionComponent();
      final parent = PositionComponent(
        angle: pi / 2,
        scale: Vector2.all(2),
        children: [component],
      );
      game.world.add(parent);
      await game.ready();

      MoveDrag.start(
        component,
        GizmoHandle.free,
        camera: game.camera,
        snapStep: 8,
      )!.update(Vector2(10, 0));
      // Moving right on the canvas is moving up in the rotated parent, and
      // the parent's scale halves the distance.
      expect(component.position, closeToVector(Vector2(0, -5)));
    });

    testWithFlameGame('snaps the position to a grid', (game) async {
      final component = PositionComponent(position: Vector2(1.5, 2.5));
      game.world.add(component);
      await game.ready();
      final drag = MoveDrag.start(
        component,
        GizmoHandle.free,
        camera: game.camera,
        snapStep: 8,
      )!;

      drag.update(Vector2(10, 3), snap: true);
      expect(component.position, closeToVector(Vector2(8, 8)));

      drag.update(Vector2(10, 3));
      expect(component.position, closeToVector(Vector2(11.5, 5.5)));
    });

    testWithFlameGame('snaps the moved coordinate along a parallel axis', (
      game,
    ) async {
      final component = PositionComponent(position: Vector2(1.5, 2.5));
      game.world.add(component);
      await game.ready();

      MoveDrag.start(
        component,
        GizmoHandle.x,
        camera: game.camera,
        snapStep: 8,
      )!.update(Vector2(13, 3), snap: true);
      expect(component.position, closeToVector(Vector2(16, 2.5)));
    });

    testWithFlameGame('snaps the distance along a rotated axis', (game) async {
      final component = PositionComponent(
        position: Vector2(1.5, 2.5),
        angle: pi / 4,
      );
      game.world.add(component);
      await game.ready();

      MoveDrag.start(
        component,
        GizmoHandle.x,
        camera: game.camera,
        snapStep: 8,
      )!.update(Vector2(10, 10), snap: true);
      // The distance moved along the axis, 14.1, snaps to 16.
      expect(
        component.position,
        closeToVector(Vector2(1.5, 2.5) + Vector2.all(16 / sqrt2)),
      );
    });

    testWithFlameGame('cannot drag components whose parent is degenerate', (
      game,
    ) async {
      final component = PositionComponent();
      game.world.add(
        PositionComponent(scale: Vector2.zero(), children: [component]),
      );
      await game.ready();

      expect(
        MoveDrag.start(
          component,
          GizmoHandle.free,
          camera: game.camera,
          snapStep: 8,
        ),
        isNull,
      );
    });
  });
}
