/// A body of Flame's own 2D physics, drawn in 3D: a pinball and a flipper
/// moved by `flame_forge2d`, followed by bridged components.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' show SceneNode;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Table extends Forge2DGame with HasFlutter3d {
  _Table() : super(gravity: Vector2(0.0, 10.0));
}

final class _Ball extends BodyComponent {
  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.dynamic, position: Vector2(2.0, 0.0)),
    );
    body.createShape(Circle(radius: 0.3));
    return body;
  }
}

final class _Flipper extends BodyComponent {
  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(
        type: BodyType.kinematic,
        position: Vector2(-2.0, 5.0),
        angularVelocity: 3.0,
      ),
    );
    body.createShape(Polygon.box(1.0, 0.1));
    return body;
  }
}

void main() {
  testWithGame<_Table>(
    'a bridged component stands where a forge2d body is, and turns as it '
    'turns',
    _Table.new,
    (game) async {
      // A body of flame_forge2d is not a PositionComponent, and nothing of
      // the bridge could hang under it.
      //
      // Mutation: ignore follows.
      game.open3d(FakeBackend());
      final ball = _Ball();
      final flipper = _Flipper();
      game.world.addAll(<Component>[ball, flipper]);
      await game.ready();
      final plane = BridgePlane.ground();
      final drawnBall = Object3dComponent(
        node: SceneNode(),
        scene: game.scene,
        plane: plane,
        direction: SyncDirection.flameToScene,
        follows: ball,
      );
      final drawnFlipper = Object3dComponent(
        node: SceneNode(),
        scene: game.scene,
        plane: plane,
        direction: SyncDirection.flameToScene,
        follows: flipper,
      );
      game.addAll(<Component>[drawnBall, drawnFlipper]);
      await game.ready();

      for (var i = 0; i < 30; i++) {
        game.update(1 / 60);
      }
      expect(ball.body.position.y, greaterThan(1.0), reason: 'it fell');
      final at = drawnBall.node.readPosition();
      expect(at.x, closeTo(ball.body.position.x, 1e-5));
      expect(at.z, closeTo(ball.body.position.y, 1e-5));
      expect(flipper.body.angle, greaterThan(1.0));
      expect(
        plane.angleFor(drawnFlipper.node.readRotation()),
        closeTo(flipper.body.angle, 1e-4),
      );
    },
  );
}
