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

    testWithFlameGame('follow with snap', (game) async {
      final world = World()..addToParent(game);
      final player = PositionComponent()
        ..position = Vector2(100, 100)
        ..addToParent(world);
      final camera = CameraComponent(world: world)
        ..follow(player, maxSpeed: 1, snap: true)
        ..addToParent(game);
      await game.ready();

      expect(camera.viewfinder.position, Vector2(100, 100));
    });

    testWithFlameGame('moveTo', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      final point = Vector2(1000, 2000);
      camera.moveTo(point);
      game.update(0);
      expect(camera.viewfinder.position, Vector2(1000, 2000));
      // updating [point] doesn't affect the camera's target
      point.x = 0;
      game.update(1);
      expect(camera.viewfinder.position, Vector2(1000, 2000));
    });

    testWithFlameGame('moveTo x 2', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      camera.moveTo(Vector2(100, 0), speed: 5);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(0.5 * i, 0));
        game.update(0.1);
      }
      camera.moveTo(Vector2(5, 200), speed: 10);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(5, 1.0 * i));
        game.update(0.1);
      }
      expect(camera.viewfinder.children.length, 1);
    });

    testWithFlameGame('setBound', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      camera.setBounds(Rectangle.fromLTRB(0, 0, 400, 50));
      camera.viewfinder.position = Vector2(10, 10);
      game.update(0);
      expect(camera.viewfinder.position, Vector2(10, 10));
      camera.viewfinder.position = Vector2(-10, 10);
      game.update(0);
      expect(camera.viewfinder.position, closeToVector(0, 10, epsilon: 0.5));

      camera.moveTo(Vector2(-20, 0), speed: 10);
      for (var i = 0; i < 20; i++) {
        expect(camera.viewfinder.position, closeToVector(0, 10, epsilon: 0.5));
        game.update(0.5);
      }

      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>(),
        isNotNull,
      );
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>()!.bounds,
        isA<Rectangle>(),
      );
      camera.setBounds(Circle(Vector2.zero(), 100));
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>()!.bounds,
        isA<Circle>(),
      );
      camera.setBounds(null);
      game.update(0);
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>(),
        isNull,
      );
    });
  });
}
