import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Object3D', () {
    // Looking down +z from z = -6, so everything behind z = -6 is out of view.
    Future<CameraComponent3D> addCamera(FlameGame game) async {
      final camera = CameraComponent3D(
        position: Vector3(0, 2, -6),
        target: Vector3(0, 1, 0),
      );
      await game.ensureAdd(camera);
      return camera;
    }

    testWithFlameGame(
      'is visible when only part of it is in view',
      (game) async {
        final camera = await addCamera(game);
        // A wall from z = -30 to z = 0, whose center is behind the camera.
        final wall = _Box(
          size: Vector3(1, 2, 30),
          position: Vector3(0, 1, -15),
        );
        await game.world.ensureAdd(wall);

        expect(camera.frustum.containsVector3(wall.position), isFalse);
        expect(wall.isVisible(camera), isTrue);
      },
    );

    testWithFlameGame(
      'is not visible when it is out of view',
      (game) async {
        final camera = await addCamera(game);
        final box = _Box(size: Vector3.all(1), position: Vector3(0, 1, -20));
        await game.world.ensureAdd(box);

        expect(box.isVisible(camera), isFalse);
      },
    );

    testWithFlameGame(
      'is visible based on its world position when nested',
      (game) async {
        final camera = await addCamera(game);
        final inView = _Box(
          size: Vector3.all(1),
          position: Vector3(0, 1, -20),
        );
        final outOfView = _Box(
          size: Vector3.all(1),
          position: Vector3(0, 1, 0),
        );
        await game.world.ensureAddAll([
          _Group(position: Vector3(0, 0, 20), children: [inView]),
          _Group(position: Vector3(0, 0, -20), children: [outOfView]),
        ]);

        // Their local positions are the other way around.
        expect(inView.isVisible(camera), isTrue);
        expect(outOfView.isVisible(camera), isFalse);
      },
    );
  });
}

class _Group({super.position, super.children}) extends Component3D;

class _Box({required this.size, super.position}) extends Object3D {
  final Vector3 size;

  @override
  Aabb3? computeLocalAabb() =>
      Aabb3.centerAndHalfExtents(Vector3.zero(), size / 2);

  @override
  void draw(RenderContext context) {}
}
