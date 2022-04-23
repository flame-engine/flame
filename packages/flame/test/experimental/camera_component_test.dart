
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraComponent', () {
    testWithFlameGame('simple camera follow', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      final player = PositionComponent()..addToParent(world);
      camera.follow(player);
      await game.ready();

      expect(camera.viewfinder.children.length, 1);
      expect(camera.viewfinder.children.first, isA<FollowBehavior>());
      for (var i = 0; i < 20; i++) {
        player.position.add(Vector2(i * 5.0, 20.0 - i));
        game.update(0.01);
        expect(camera.viewfinder.position, closeToVector(player.x, player.y));
      }
    });
  });
}
