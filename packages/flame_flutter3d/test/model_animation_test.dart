/// A model's animations on Flame's clock, and a flipbook of meshes.
library;

import 'dart:typed_data';

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clip that slides node 0 from x = 0 to x = [to] over a second.
AnimationClip _slide(String name, double to) => AnimationClip(
  name: name,
  tracks: <AnimationTrack>[
    AnimationTrack(
      nodeIndex: 0,
      path: AnimationPath.translation,
      interpolation: AnimationInterpolation.linear,
      times: Float32List.fromList(<double>[0.0, 1.0]),
      values: Float32List.fromList(<double>[0.0, 0.0, 0.0, to, 0.0, 0.0]),
      componentCount: 3,
    ),
  ],
);

void main() {
  testWithGame<FlameGame>(
    "a clip plays on Flame's clock, and a change of clip is by name",
    FlameGame.new,
    (game) async {
      // Mutation: tick the player from anywhere but the component's update.
      final body = SceneNode();
      final player = AnimationPlayer(
        clips: <AnimationClip>[_slide('walk', 2.0), _slide('run', 6.0)],
        targets: <AnimationTarget?>[body],
      );
      final animation = ModelAnimationComponent(player, start: 'walk');
      game.add(animation);
      await game.ready();

      game.update(0.5);
      expect(body.readPosition().x, closeTo(1.0, 1e-3));

      // Only by what the game was stepped: nothing else ticks it.
      game.update(0.25);
      expect(body.readPosition().x, closeTo(1.5, 1e-3));

      expect(animation.play('run'), isTrue);
      expect(animation.current, 'run');
      expect(animation.play('fly'), isFalse);
      expect(animation.has('walk'), isTrue);
    },
  );

  testWithGame<FlameGame>(
    'a flipbook shows its frames in turn',
    FlameGame.new,
    (game) async {
      final a = CpuMesh(CuboidShape(size: Vector3.all(1.0)).build());
      final b = CpuMesh(CuboidShape(size: Vector3.all(2.0)).build());
      final node = MeshNode(a, Material());
      final book = MeshFlipbookComponent(
        node: node,
        frames: <MeshGeometry>[a, b],
      );
      game.add(book);
      await game.ready();
      expect(node.mesh, same(a));

      game.update(0.6);
      expect(node.mesh, same(b));
      game.update(0.5);
      expect(node.mesh, same(a));
    },
  );

  testWithGame<FlameGame>(
    'a clip asked for again from its start plays again',
    FlameGame.new,
    (game) async {
      // Asking for the clip playing did nothing, so a jump played once.
      //
      // Mutation: ignore restart.
      final body = SceneNode();
      final player = AnimationPlayer(
        clips: <AnimationClip>[_slide('jump', 2.0)],
        targets: <AnimationTarget?>[body],
      );
      final animation = ModelAnimationComponent(player, start: 'jump');
      game.add(animation);
      await game.ready();
      game.update(0.5);
      expect(body.readPosition().x, closeTo(1.0, 1e-3));

      expect(animation.play('jump', restart: true), isTrue);
      game.update(0.25);
      expect(body.readPosition().x, closeTo(0.5, 1e-3));
    },
  );
}
