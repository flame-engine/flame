import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('ViewportAwareBoundsBehavior', () {
    testWithFlameGame('setBounds wrt Rectangle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Rectangle.fromLTRB(0, 0, 640, 480);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as Rectangle?)?.toRect(),
        Rectangle.fromLTRB(0, 0, 640, 480).toRect(),
        reason: 'Camera bounds at unexpected location',
      );

      expect(camera.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (_getBounds(camera) as Rectangle?)?.toRect(),
        Rectangle.fromLTRB(160, 120, 480, 360).toRect(),
        reason: 'Camera bounds did not consider viewport',
      );

      expect(camera.considerViewport, true);
    });

    testWithFlameGame('setBounds wrt RoundedRectangle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = RoundedRectangle.fromLTRBR(0, 0, 640, 480, 32);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as RoundedRectangle?)?.asRRect(),
        RoundedRectangle.fromLTRBR(0, 0, 640, 480, 32).asRRect(),
        reason: 'Camera bounds at unexpected location',
      );

      expect(camera.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      // Note that floating point drift occurs, so we account for
      // this error threshold epsilon `E`.
      const E = 0.03; // +/-3%
      final camRRect = (_getBounds(camera) as RoundedRectangle?)?.asRRect();
      final expectedRRect = RoundedRectangle.fromLTRBR(
        163.2,
        126.4,
        476.8,
        353.6,
        32,
      ).asRRect();
      expect(
        _epsilonRRectEqualityCheck(camRRect!, expectedRRect, E),
        true,
        reason: 'Camera bounds did not consider viewport',
      );

      expect(camera.considerViewport, true);
    });

    testWithFlameGame('setBounds wrt Circle', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Circle(Vector2(320, 240), 320);

      // With considerViewport = false
      camera.setBounds(bounds);
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds at unexpected location',
      );

      expect(camera.considerViewport, false);

      // With considerViewport = true
      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds did not consider viewport',
      );

      // Check bounds after moving away from the center
      // while considerViewport = true
      camera
        ..setBounds(bounds, considerViewport: true)
        ..moveBy(Vector2(-320, 0));
      game.update(0);
      expect(
        (_getBounds(camera) as Circle?)?.center,
        Vector2(320, 240),
        reason: 'Camera bounds did not consider viewport after move',
      );

      expect(camera.considerViewport, true);
    });

    testWithFlameGame('setBounds explicit null Shape request', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent.withFixedResolution(
        width: 320,
        height: 240,
        world: world,
      )..addToParent(game);
      await game.ready();
      final bounds = Circle(Vector2(320, 240), 320);

      camera.setBounds(bounds);
      game.update(0);
      expect(
        _getBounds(camera) as Circle?,
        isNotNull,
        reason: 'Camera bounds was null but expected a non-null Circle',
      );

      camera.setBounds(null);
      game.update(0);
      expect(
        _getBounds(camera) as Circle?,
        isNull,
        reason:
            'Camera bounds expected to be null from side-effect of removing it',
      );
    });
  });
}

Shape? _getBounds(CameraComponent camera) =>
    camera.viewfinder.firstChild<BoundedPositionBehavior>()?.bounds;

bool _epsilonRRectEqualityCheck(RRect a, RRect b, double epsilon) {
  return (a.left - b.left).abs() <= epsilon &&
      (a.top - b.top).abs() <= epsilon &&
      (a.right - b.right).abs() <= epsilon &&
      (a.bottom - b.bottom).abs() <= epsilon &&
      (a.tlRadiusX - b.tlRadiusX) == 0 &&
      (a.tlRadiusY - b.tlRadiusY) == 0 &&
      (a.trRadiusX - b.trRadiusX) == 0 &&
      (a.trRadiusY - b.trRadiusY) == 0 &&
      (a.blRadiusX - b.blRadiusX) == 0 &&
      (a.blRadiusY - b.blRadiusY) == 0 &&
      (a.brRadiusX - b.brRadiusX) == 0 &&
      (a.brRadiusY - b.brRadiusY) == 0;
}
