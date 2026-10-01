/// A [CameraSyncController] keeps a flutter3d [CameraNode] and a Flame
/// [Viewfinder] describing the same view, on whichever side [SyncDirection]
/// names as authoritative.
library;

import 'package:flame/camera.dart' show Viewfinder;
import 'package:flame_flutter3d/src/camera/camera_sync_controller.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart'
    show SyncDirection;
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' hide Plane;

void main() {
  test('sceneToFlame moves the viewfinder position to the camera, through the '
      'plane', () {
    final camera = CameraNode()..setPosition(3.0, 0.0, 4.0);
    final viewfinder = Viewfinder();
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
    );

    controller.advance(1 / 60);

    expect(viewfinder.position, Vector2(3.0, 4.0));
  });

  test('sceneToFlame moves the viewfinder zoom to the orthographic height, '
      'reciprocally', () {
    final camera = CameraNode(
      projection: const OrthographicProjection(height: 4.0),
    );
    final viewfinder = Viewfinder();
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
    );

    controller.advance(1 / 60);

    expect(viewfinder.zoom, 0.25);
  });

  test(
    'sceneToFlame leaves the viewfinder zoom alone for a perspective camera',
    () {
      final camera = CameraNode(projection: const PerspectiveProjection());
      final viewfinder = Viewfinder()..zoom = 2.0;
      final controller = CameraSyncController(
        camera: camera,
        viewfinder: viewfinder,
        plane: BridgePlane.ground(),
      );

      controller.advance(1 / 60);

      expect(viewfinder.zoom, 2.0);
    },
  );

  test('flameToScene moves the camera position to the viewfinder, through the '
      'plane', () {
    final camera = CameraNode();
    final viewfinder = Viewfinder()..position = Vector2(5.0, 6.0);
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(height: 1.5),
      direction: SyncDirection.flameToScene,
    );

    controller.advance(1 / 60);

    final read = camera.readPosition();
    expect(read.x, 5.0);
    expect(read.y, 1.5);
    expect(read.z, 6.0);
  });

  test('flameToScene moves the orthographic height to the viewfinder zoom, '
      'reciprocally', () {
    final camera = CameraNode(
      projection: const OrthographicProjection(height: 4.0),
    );
    final viewfinder = Viewfinder()..zoom = 0.5;
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
    );

    controller.advance(1 / 60);

    final projection = camera.projection;
    expect(projection, isA<OrthographicProjection>());
    expect((projection as OrthographicProjection).height, 2.0);
  });

  test('flameToScene leaves a perspective projection alone', () {
    const projection = PerspectiveProjection();
    final camera = CameraNode(projection: projection);
    final viewfinder = Viewfinder()..zoom = 2.0;
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
    );

    controller.advance(1 / 60);

    expect(camera.projection, same(projection));
  });

  test("with the viewport's height, the two lenses agree to the pixel", () {
    // A 256-unit-tall field in a 512-pixel viewport is two pixels a unit in
    // both engines, and a Flame zoom of 4 is a 128-unit-tall view.
    //
    // Mutation: keep the reciprocal convention when a height is given.
    final camera = CameraNode(
      projection: const OrthographicProjection(height: 256.0),
    );
    final viewfinder = Viewfinder();
    CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      viewportHeight: () => 512.0,
    ).advance(0.0);
    expect(viewfinder.zoom, closeTo(2.0, 1e-9));

    viewfinder.zoom = 4.0;
    CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
      viewportHeight: () => 512.0,
    ).advance(0.0);
    expect(
      (camera.projection as OrthographicProjection).height,
      closeTo(128.0, 1e-9),
    );
  });

  test("a rolling screen rolls the camera about the plane's normal, and "
      'reads back', () {
    // Mutation: leave the camera's rotation alone when the angle moves.
    final camera = CameraNode()..lookAt(Vector3(0.0, -1.0, -0.001));
    final reader = CameraSyncController(
      camera: camera,
      viewfinder: Viewfinder(),
      plane: BridgePlane.ground(),
      syncAngle: true,
    );
    CameraSyncController(
      camera: camera,
      viewfinder: Viewfinder()..angle = 0.4,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
      syncAngle: true,
    ).advance(0.0);

    reader.advance(0.0);
    expect(reader.viewfinder.angle, closeTo(0.4, 1e-5));
  });

  test("with an eye offset, a perspective camera looks at the viewfinder's "
      'point from there, nearer as it zooms and round as it turns', () {
    // Put at the viewfinder's point, on the plane, a perspective camera
    // looked at nothing Flame's camera did.
    //
    // Mutation: ignore the offset.
    final camera = CameraNode(
      projection: const PerspectiveProjection(fovYRadians: 0.9),
    );
    final viewfinder = Viewfinder()
      ..position = Vector2(3.0, -4.0)
      ..zoom = 2.0;
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
      eyeOffset: Vector3(0.0, 12.0, 10.0),
      syncAngle: true,
    )..advance(0.0);

    final eye = camera.readPosition();
    expect(eye.x, closeTo(3.0, 1e-5));
    expect(eye.y, closeTo(6.0, 1e-5));
    expect(eye.z, closeTo(1.0, 1e-5));
    final forward = camera.readRotation().asRotationMatrix().transform(
      Vector3(0.0, 0.0, -1.0),
    );
    final toTarget = (Vector3(3.0, 0.0, -4.0) - eye)..normalize();
    expect(forward.dot(toTarget), closeTo(1.0, 1e-5));

    // A quarter turn of the viewfinder takes the eye round the point.
    viewfinder.angle = 1.5707963267948966;
    controller.advance(0.0);
    final turned = camera.readPosition();
    expect(turned.distanceTo(Vector3(3.0, 0.0, -4.0)), closeTo(7.8102, 1e-3));
    expect((turned.x - 3.0).abs(), closeTo(5.0, 1e-4));
  });

  test('an orthographic camera given an offset looks along it, and zooms by '
      'its height', () {
    // An isometric board: the camera from a corner, the zoom the lens.
    //
    // Mutation: ignore the offset under an orthographic lens.
    final camera = CameraNode(
      projection: const OrthographicProjection(height: 10.0),
    );
    final viewfinder = Viewfinder()
      ..position = Vector2(2.0, -2.0)
      ..zoom = 0.5;
    CameraSyncController(
      camera: camera,
      viewfinder: viewfinder,
      plane: BridgePlane.ground(),
      direction: SyncDirection.flameToScene,
      eyeOffset: Vector3(10.0, 10.0, 10.0),
    ).advance(0.0);

    final eye = camera.readPosition();
    expect(eye.x, closeTo(12.0, 1e-5), reason: 'not nearer for the zoom');
    expect(eye.y, closeTo(10.0, 1e-5));
    expect(eye.z, closeTo(8.0, 1e-5));
    final forward = camera.readRotation().asRotationMatrix().transform(
      Vector3(0.0, 0.0, -1.0),
    );
    expect(forward.x, closeTo(forward.y, 1e-5), reason: 'down the diagonal');
    expect(forward.y, closeTo(forward.z, 1e-5));
    expect(
      (camera.projection as OrthographicProjection).height,
      closeTo(2.0, 1e-9),
    );
  });

  test('a camera aimed after the controller was made rests where it was '
      'aimed, once told', () {
    // The rest was the rotation at construction, and a camera pointed with
    // lookAt afterwards read as rolled by the difference.
    //
    // Mutation: make takeRest do nothing.
    final camera = CameraNode()..setPosition(0.0, 10.0, 0.0);
    final controller = CameraSyncController(
      camera: camera,
      viewfinder: Viewfinder(),
      plane: BridgePlane.ground(),
      syncAngle: true,
    );
    camera.lookAt(Vector3(-5.0, 10.0, -5.0));
    controller
      ..takeRest()
      ..advance(0.0);
    expect(controller.viewfinder.angle, closeTo(0.0, 1e-5));
  });
}
