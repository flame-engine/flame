/// A lift Flame moves with its own effects, and a runner carried on it.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_physics/flutter3d_physics.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Side extends FlameGame with HasFixedStep {}

void main() {
  testWithGame<_Side>(
    'a lift moved by a Flame effect carries whoever stands on it, once for '
    'each move',
    _Side.new,
    (game) async {
      // Written into the collider by hand, the lift rose and its passenger
      // stayed; carried on every step, the passenger rose twice as fast.
      //
      // Mutation: move the collider without recording the motion, or leave
      // the motion recorded for the steps after.
      final world = CollisionWorld();
      final deck = world.add(
        Collider(
          shape: CollisionBox(Vector3(2.0, 0.25, 2.0)),
          position: Vector3(0.0, -0.25, 0.0),
          kind: ColliderKind.kinematic,
        ),
      );
      final body = CharacterController(
        world: world,
        position: Vector3(0.0, 0.9, 0.0),
      );
      final plane = BridgePlane.backdrop();
      final lift = KinematicBodyComponent(
        collider: deck,
        node: SceneNode(),
        scene: Scene(),
        plane: plane,
        position: plane.to2d(deck.position),
      );
      final rider = CharacterBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: plane,
        drive: (dt) {
          body.step(dt, wishDirection: Vector3.zero());
          world.update();
        },
      );
      game.addAll(<Component>[lift, rider]);
      await game.ready();
      for (var i = 0; i < 30; i++) {
        game.update(1 / 60);
      }
      final standing = body.position.x;

      // Sideways, where nothing but the recorded motion moves a passenger:
      // a metre and a half over a second, at two steps a frame.
      lift.add(
        MoveEffect.by(Vector2(1.5, 0.0), EffectController(duration: 1.0)),
      );
      for (var i = 0; i < 40; i++) {
        game.update(1 / 30);
      }
      expect(deck.position.x, closeTo(1.5, 1e-3));
      expect(body.position.x - standing, closeTo(1.5, 0.05));
    },
  );

  testWithGame<_Side>(
    'a lift removed from the game leaves the world with removeFrom',
    _Side.new,
    (game) async {
      // Mutation: drop the removal from `onRemove`; nothing is drawn where
      // the lift was, and a passenger still stands on it.
      final world = CollisionWorld();
      final deck = world.add(
        Collider(
          shape: CollisionBox(Vector3(2.0, 0.25, 2.0)),
          kind: ColliderKind.kinematic,
        ),
      );
      final lift = KinematicBodyComponent(
        collider: deck,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.backdrop(),
        removeFrom: world,
      );
      game.add(lift);
      await game.ready();

      lift.removeFromParent();
      await game.ready();
      await Future<void>.delayed(Duration.zero);
      expect(deck.world, isNull);
    },
  );
}
