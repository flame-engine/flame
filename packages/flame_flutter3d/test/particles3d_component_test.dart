/// A particle system on Flame's clock: bursts placed from Flame points,
/// advanced with the game, drawn through the renderer once there is one and
/// taken out of it with the component.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter3d_particles/flutter3d_particles.dart';
import 'package:flutter_test/flutter_test.dart';

final ParticleEffect _spark = ParticleEffect(
  count: 5,
  emitter: const SphereEmitter(speed: Range.exact(0.0)),
  lifetime: const Range.exact(0.5),
  size: const Range.exact(0.2),
  color: Vector4.all(1.0),
);

void main() {
  testWithGame<FlameGame>(
    "a burst starts where the Flame point is, and lives on the game's clock",
    FlameGame.new,
    (game) async {
      final particles = Particles3dComponent(
        system: ParticleSystem(capacity: 16, seed: 1),
        plane: BridgePlane.ground(),
      );
      game.add(particles);
      await game.ready();

      expect(particles.burstAt(_spark, Vector2(3.0, -4.0), elevation: 2.0), 5);
      // Still, all five: the middle of their bounds is where they started.
      final at = Vector3.zero();
      particles.system.boundsInto(at);
      expect(at.x, closeTo(3.0, 1e-6));
      expect(at.y, closeTo(2.0, 1e-6));
      expect(at.z, closeTo(-4.0, 1e-6));

      // Frame by frame: the system caps its catch-up after a stall, so one
      // update of a third of a second is not a third of a second of life.
      for (var i = 0; i < 18; i++) {
        game.update(1 / 60);
      }
      expect(particles.system.aliveCount, 5);
      for (var i = 0; i < 18; i++) {
        game.update(1 / 60);
      }
      expect(particles.system.aliveCount, 0, reason: 'half a second of life');
    },
  );

  testWithGame<FlameGame>(
    'it draws through the renderer it is given, and leaves it with the game',
    FlameGame.new,
    (game) async {
      final cpu = cpuTestDevice(width: 8, height: 8);
      final renderer = Renderer.create(
        device: cpu.device,
        fallbackAlbedo: cpu.albedo,
        fallbackNormal: cpu.normal,
      );
      final shard = DeviceMesh.upload(
        cpu.device,
        CuboidShape(size: Vector3.all(0.2)).build(),
      );
      final particles = Particles3dComponent(
        system: ParticleSystem(capacity: 16, seed: 1),
        plane: BridgePlane.ground(),
      );
      game.add(particles);
      await game.ready();

      particles.drawWith(renderer, shard);
      expect(
        renderer.contributors.all.whereType<MeshParticleContributor>(),
        hasLength(1),
      );
      // Handed the renderer again: moved, not doubled, and with the blend
      // it was given this time.
      particles.drawWith(
        renderer,
        shard,
        blend: MeshParticleContributor.darkening,
      );
      expect(renderer.contributors.all, hasLength(1));
      expect(
        (renderer.contributors.all.single as MeshParticleContributor).blend,
        MeshParticleContributor.darkening,
      );

      particles.removeFromParent();
      await game.ready();
      expect(
        renderer.contributors.all.whereType<MeshParticleContributor>(),
        isEmpty,
      );

      // Added back, it is drawn again as it was.
      //
      // Mutation: forget the drawing when it is removed.
      game.add(particles);
      await game.ready();
      expect(renderer.contributors.all, hasLength(1));
      expect(
        (renderer.contributors.all.single as MeshParticleContributor).blend,
        MeshParticleContributor.darkening,
      );
    },
  );
}
