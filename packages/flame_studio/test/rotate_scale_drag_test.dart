import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/gizmo/rotate_drag.dart';
import 'package:flame_studio/src/core/gizmo/scale_drag.dart';
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

    test('only finds the ring when rotating', () {
      expect(
        geometry.handleAt(const Offset(150, 102), ring: true),
        GizmoHandle.ring,
      );
      expect(
        geometry.handleAt(const Offset(100, 47), ring: true),
        GizmoHandle.ring,
      );
      expect(geometry.handleAt(const Offset(130, 100), ring: true), isNull);
      expect(geometry.handleAt(const Offset(150, 100)), isNull);
    });
  });

  group('RotateDrag', () {
    late PositionComponent component;
    late GizmoGeometry geometry;

    Future<void> setUpComponent(FlameGame game, {Vector2? parentScale}) async {
      component = PositionComponent(anchor: Anchor.center);
      game.world.add(
        PositionComponent(scale: parentScale, children: [component]),
      );
      await game.ready();
      geometry = GizmoGeometry.of(component).single;
    }

    testWithFlameGame('rotates by the angle swept around the anchor', (
      game,
    ) async {
      await setUpComponent(game);
      final drag = RotateDrag.start(
        component,
        geometry,
        geometry.anchor + const Offset(50, 0),
        snapStep: pi / 12,
      )!;

      drag.update(Vector2(-50, 50));
      expect(component.angle, closeTo(pi / 2, 1e-9));

      drag.update(Vector2(-50, -50));
      expect(component.angle, closeTo(-pi / 2, 1e-9));

      drag.cancel();
      expect(component.angle, 0);
    });

    testWithFlameGame('snaps to multiples of 15 degrees', (game) async {
      await setUpComponent(game);
      final drag = RotateDrag.start(
        component,
        geometry,
        geometry.anchor + const Offset(50, 0),
        snapStep: pi / 12,
      )!;

      // Sweeps about 21.8 degrees.
      drag.update(Vector2(0, 20), snap: true);
      expect(component.angle, closeTo(pi / 12, 1e-9));
    });

    testWithFlameGame('rotates the other way in a mirrored parent', (
      game,
    ) async {
      await setUpComponent(game, parentScale: Vector2(-1, 1));
      RotateDrag.start(
        component,
        geometry,
        geometry.anchor + const Offset(50, 0),
        snapStep: pi / 12,
      )!.update(Vector2(-50, 50));
      expect(component.angle, closeTo(-pi / 2, 1e-9));
    });
  });

  group('ScaleDrag', () {
    late PositionComponent component;
    late GizmoGeometry geometry;

    Future<void> setUpComponent(FlameGame game) async {
      component = PositionComponent(size: Vector2.all(10));
      game.world.add(component);
      await game.ready();
      geometry = GizmoGeometry.of(component).single;
    }

    testWithFlameGame('scales along the dragged axis', (game) async {
      await setUpComponent(game);

      ScaleDrag.start(
        component,
        GizmoHandle.x,
        geometry,
        snapStep: 0.1,
      )!.update(Vector2(40, 30));
      expect(component.scale, closeToVector(Vector2(2, 1)));

      ScaleDrag.start(
        component,
        GizmoHandle.y,
        geometry,
        snapStep: 0.1,
      )!.update(Vector2(40, -20));
      expect(component.scale, closeToVector(Vector2(2, 0.5)));
    });

    testWithFlameGame('scales uniformly with the square handle', (game) async {
      await setUpComponent(game);
      final drag = ScaleDrag.start(
        component,
        GizmoHandle.free,
        geometry,
        snapStep: 0.1,
      )!;

      drag.update(Vector2.all(20 * sqrt2));
      expect(component.scale, closeToVector(Vector2.all(2)));

      drag.cancel();
      expect(component.scale, closeToVector(Vector2.all(1)));
    });

    testWithFlameGame('snaps to multiples of 0.1', (game) async {
      await setUpComponent(game);
      ScaleDrag.start(
        component,
        GizmoHandle.x,
        geometry,
        snapStep: 0.1,
      )!.update(Vector2(5, 0), snap: true);
      expect(component.scale, closeToVector(Vector2(1.1, 1)));
    });

    testWithFlameGame('only snaps the dragged axes', (game) async {
      await setUpComponent(game);
      component.scale = Vector2(1.23, 1.37);
      ScaleDrag.start(
        component,
        GizmoHandle.x,
        geometry,
        snapStep: 0.1,
      )!.update(Vector2.zero(), snap: true);
      expect(component.scale, closeToVector(Vector2(1.2, 1.37)));
    });

    testWithFlameGame('does not scale with the ring', (game) async {
      await setUpComponent(game);
      expect(
        ScaleDrag.start(
          component,
          GizmoHandle.ring,
          geometry,
          snapStep: 0.1,
        ),
        isNull,
      );
    });
  });
}
