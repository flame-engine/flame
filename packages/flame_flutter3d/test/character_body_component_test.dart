/// A platformer's runner, moved by its own rules and seen by Flame.
library;

import 'package:flame/components.dart' show Component, PositionComponent;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_game_platformer/flutter3d_game_platformer.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Side extends FlameGame with HasFixedStep {}

void main() {
  testWithGame<_Side>(
    'a runner on a ladder climbs it, and Flame sees it go up the screen',
    _Side.new,
    (game) async {
      // Mutation: never call drive; the body stays where it began.
      final world = CollisionWorld();
      world.add(
        Collider(
          shape: CollisionBox(Vector3(20.0, 0.5, 20.0)),
          position: Vector3(0.0, -0.5, 0.0),
        ),
      );
      final body = CharacterController(
        world: world,
        position: Vector3(0.0, 0.9, 0.0),
      );
      final runner = Runner(body: body);
      Climbable(
        collider: world.add(
          // As a level spawns one: a trigger, met by the player.
          Collider(
            shape: CollisionBox(Vector3(0.5, 4.0, 0.5)),
            position: Vector3(0.0, 4.0, 0.0),
            kind: ColliderKind.trigger,
            layer: CollisionLayers.trigger,
            mask: CollisionLayers.player,
          ),
        ),
      );
      final input = InputState()..press(GameAction.moveForward);

      final harry = CharacterBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.backdrop(),
        // What the platformer's own simulation does each step: the runner,
        // then the world it moved in.
        drive: (dt) {
          runner.step(dt, input);
          world.update();
          input.endStep();
        },
      );
      game.add(harry);
      await game.ready();
      final startY = harry.position.y;

      for (var i = 0; i < 60; i++) {
        game.update(1 / 60);
      }
      expect(runner.climbing, isNotNull, reason: 'it took hold');
      expect(body.position.y, greaterThan(2.0));
      expect(harry.position.y, lessThan(startY - 1.0), reason: 'up the screen');
    },
  );

  testWithGame<_Side>(
    'a runner removed from the game leaves the world with removeFrom, and '
    'stays in it when only moved',
    _Side.new,
    (game) async {
      // Mutation: drop the removal from `onRemove`; the despawned runner
      // stays in the world, solid and unseen.
      final world = CollisionWorld();
      final body = CharacterController(
        world: world,
        position: Vector3(0.0, 0.9, 0.0),
      );
      final harry = CharacterBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.backdrop(),
        removeFrom: world,
      );
      final shelf = PositionComponent();
      game.addAll(<Component>[harry, shelf]);
      await game.ready();

      harry.parent = shelf;
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(body.collider.world, same(world), reason: 'moved, not gone');

      harry.removeFromParent();
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(body.collider.world, isNull);
    },
  );
}
