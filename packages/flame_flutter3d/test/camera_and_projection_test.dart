/// A chase camera behind a bridged component, the projection between the 3D
/// camera and Flame's screen, and the input a phone's stick and button
/// feed.
library;

import 'package:flame/components.dart';
import 'package:flame/input.dart' show HudButtonComponent;
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

Object3dComponent _jet(Vector2 at) {
  final jet = Object3dComponent(
    node: SceneNode(),
    scene: Scene(),
    plane: BridgePlane.ground(),
    direction: SyncDirection.flameToScene,
    elevation: 1.7,
    position: at,
  )..onMount();
  return jet..updateTree(0.0);
}

void main() {
  group('ChaseCamera', () {
    test('sits at the offset and looks at the look offset', () {
      final camera = CameraNode();
      final jet = _jet(Vector2(4.0, -20.0));
      ChaseCamera(
        camera: camera,
        target: jet,
        offset: Vector3(0.0, 11.0, 11.0),
        lookOffset: Vector3(0.0, -1.7, -9.0),
        followAcross: 0.35,
        lookAcross: 0.5,
      ).advance(1 / 60);

      final eye = camera.readPosition();
      expect(eye.x, closeTo(4.0 * 0.35, 1e-6));
      expect(eye.y, closeTo(1.7 + 11.0, 1e-6));
      expect(eye.z, closeTo(-20.0 + 11.0, 1e-6));
      // Looking at (2, 0, -29): the forward axis points there from the eye.
      // Through the rotation matrix, the one a node is drawn with: `rotated`
      // turns the other way (see `BridgePlane.rotationFor`).
      final forward = camera.readRotation().asRotationMatrix().transform(
        Vector3(0.0, 0.0, -1.0),
      );
      final wanted = (Vector3(2.0, 0.0, -29.0) - eye)..normalize();
      expect(forward.dot(wanted), closeTo(1.0, 1e-5));
    });

    test('stiff, it keeps up with the target frame by frame', () {
      final camera = CameraNode();
      final jet = _jet(Vector2.zero());
      final chase = ChaseCamera(
        camera: camera,
        target: jet,
        offset: Vector3(0.0, 10.0, 10.0),
        lookOffset: Vector3.zero(),
      )..advance(1 / 60);
      jet
        ..position.y = -3.0
        ..updateTree(0.0);
      chase.advance(1 / 60);
      expect(camera.readPosition().z, closeTo(7.0, 1e-4));
    });

    test('a shake moves the camera off its place, and dies away', () {
      final camera = CameraNode();
      final chase = ChaseCamera(
        camera: camera,
        target: _jet(Vector2.zero()),
        offset: Vector3(0.0, 10.0, 10.0),
        lookOffset: Vector3.zero(),
      )..advance(1 / 60);
      chase.rig.shake(0.5);
      chase.advance(1 / 60);
      final shaken = camera.readPosition()..sub(Vector3(0.0, 11.7, 10.0));
      expect(shaken.length, greaterThan(1e-3));
      for (var i = 0; i < 180; i++) {
        chase.advance(1 / 60);
      }
      final settled = camera.readPosition()..sub(Vector3(0.0, 11.7, 10.0));
      expect(settled.length, lessThan(1e-3));
    });

    test('with stiffness it closes on the place instead of jumping', () {
      final camera = CameraNode();
      final jet = _jet(Vector2.zero());
      final chase = ChaseCamera(
        camera: camera,
        target: jet,
        offset: Vector3(0.0, 10.0, 10.0),
        lookOffset: Vector3.zero(),
        stiffness: 4.0,
      )..advance(1 / 60);
      expect(camera.readPosition().z, closeTo(10.0, 1e-6), reason: 'placed');

      jet
        ..position.y = -10.0
        ..updateTree(0.0);
      chase.advance(0.1);
      final z = camera.readPosition().z;
      expect(z, lessThan(10.0));
      expect(z, greaterThan(0.0), reason: 'not there in one tenth of a second');
    });
  });

  group('BridgeProjector', () {
    late CameraNode camera;
    late BridgeProjector projector;

    setUp(() {
      camera = CameraNode()
        ..setPosition(0.0, 12.0, 10.0)
        ..lookAt(Vector3(0.0, 0.0, -5.0));
      projector = BridgeProjector(
        camera: camera,
        viewSize: () => Vector2(800.0, 600.0),
      );
    });

    test('a point on the plane goes to the screen and comes back', () {
      final plane = BridgePlane.ground();
      final point = Vector2(3.0, -8.0);
      final screen = projector.toScreen(plane.to3d(point))!;
      expect(screen.x, greaterThan(400.0), reason: 'right of centre');
      final back = projector.onPlane(screen, plane)!;
      expect(back.x, closeTo(point.x, 1e-3));
      expect(back.y, closeTo(point.y, 1e-3));
    });

    test('the point looked at is the middle of the screen', () {
      final screen = projector.toScreen(Vector3(0.0, 0.0, -5.0))!;
      expect(screen.x, closeTo(400.0, 1e-3));
      expect(screen.y, closeTo(300.0, 1e-3));
    });

    test('behind the camera, and the sky, have no answer', () {
      expect(projector.toScreen(Vector3(0.0, 12.0, 30.0)), isNull);
      // The top edge of a camera looking down at 45 degrees or so still
      // meets the ground; the top of one looking at the horizon does not.
      final level = CameraNode()
        ..setPosition(0.0, 2.0, 0.0)
        ..lookAt(Vector3(0.0, 2.0, -10.0));
      final sky = BridgeProjector(
        camera: level,
        viewSize: () => Vector2(800.0, 600.0),
      ).onPlane(Vector2(400.0, 10.0), BridgePlane.ground());
      expect(sky, isNull);
    });
  });

  group('phone input', () {
    FlameInputBridge bridge() => FlameInputBridge(
      bindings: Bindings(<InputSource, GameAction>{}),
      inputState: InputState(),
    );

    test("the stick's deflection is the move axis, screen-up forward", () {
      final input = bridge();
      final stick = JoystickComponent(
        knob: CircleComponent(radius: 10.0),
        background: CircleComponent(radius: 40.0),
      );
      final feed = input.followJoystick(stick);
      stick.delta.setValues(stick.knobRadius, -stick.knobRadius);
      feed.update(1 / 60);
      // Right and up the screen at once: a diagonal, which the axis normalises.
      expect(input.inputState.moveAxis.x, closeTo(0.7071, 1e-3));
      expect(input.inputState.moveAxis.y, greaterThan(0.0));
    });

    test('a bound button holds its action while pressed', () {
      final input = bridge();
      const fire = GameAction('fire');
      final button = HudButtonComponent(button: CircleComponent(radius: 10.0));
      input.bindButton(button, fire);

      button.onPressed!();
      expect(input.inputState.held(fire), isTrue);
      button.onReleased!();
      expect(input.inputState.held(fire), isFalse);
      button.onPressed!();
      button.onCancelled!();
      expect(input.inputState.held(fire), isFalse);
    });
  });

  test('a point behind an orthographic camera is drawn nowhere', () {
    // An orthographic projection does not divide by depth, and a point
    // behind the camera came back drawn as if it were in front.
    //
    // Mutation: ask only the projection.
    final eye = CameraNode(projection: const OrthographicProjection(height: 20))
      ..setPosition(0.0, 10.0, 0.0)
      ..lookAt(Vector3(0.0, 0.0, 0.0001));
    final projector = BridgeProjector(
      camera: eye,
      viewSize: () => Vector2(200.0, 200.0),
    );
    expect(projector.toScreen(Vector3(1.0, 0.0, 1.0)), isNotNull);
    expect(projector.toScreen(Vector3(1.0, 20.0, 1.0)), isNull);
  });
}
