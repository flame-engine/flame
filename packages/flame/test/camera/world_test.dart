import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('World', () {
    testWithFlameGame(
      'by default it has a negative max 32bit int priority',
      (game) async {
        final world = World()..addToParent(game);
        final camera = CameraComponent(world: world)..addToParent(game);
        await game.ready();

        expect(world.priority, equals(-0x7fffffff));
        expect(game.children, equals([world, camera]));
      },
    );

    testWithFlameGame(
      'with a custom priority putting it in front of the camera in the tree',
      (game) async {
        final world = World(priority: 4);
        final camera = CameraComponent(world: world)..priority = 0;
        game.addAll([world, camera]);
        await game.ready();

        expect(world.priority, equals(4));
        expect(game.children, equals([camera, world]));
      },
    );
  });
}
