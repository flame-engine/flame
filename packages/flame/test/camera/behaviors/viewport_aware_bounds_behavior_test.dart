import 'package:flame/camera.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewportAwareBoundsBehavior', () {
    testWithFlameGame('setBounds considering viewport', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();
      final bounds = Rectangle.fromLTRB(0, 0, 400, 50);

      camera.setBounds(bounds);
      game.update(0);
      expect((getBounds(camera) as Rectangle).toRect(), bounds.toRect());

      camera.setBounds(bounds, considerViewport: true);
      game.update(0);
      expect(
        (getBounds(camera) as Rectangle).toRect(),
        Rectangle.fromLTRB(200.0, -100.0, 200.0, 150.0).toRect(),
      );
    });
  });
}

Shape getBounds(CameraComponent camera) =>
    camera.viewfinder.firstChild<BoundedPositionBehavior>()!.bounds;
