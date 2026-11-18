import 'dart:math' as math;

import 'package:flame/components.dart' show Component;
import 'package:flame/extensions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/scenarios/game_scenario.dart';

/// Particle systems among pillars they pass behind and in front of: a sparks
/// fountain, a smoke column, coin and confetti bursts, and a trail of dust
/// behind a moving emitter.
class ParticlesScenario() implements GameScenario {
  @override
  Future<void> onLoad() async {}

  @override
  void setup(ExampleGame3D game) {
    final sparks = ParticlePresets3D.sparks(capacity: 1024, rate: 160)
      ..position = Vector3(0, 0.3, 0);
    final smoke = ParticlePresets3D.smoke(rate: 8)
      ..position = Vector3(-4, 0.2, 0)
      ..prewarm(3);
    final coins = ParticlePresets3D.coinBurst()..position = Vector3(4, 0.3, 0);
    final confetti = ParticlePresets3D.confetti()
      ..position = Vector3(0, 0.3, 4);
    final dust = ParticlePresets3D.dustPuff();
    dust.emitters[0] = ParticleEmitter3D(
      ratePerDistance: 6,
      shape: const DiscEmitterShape3D(0.15, radial: true),
      speed: (0.3, 0.8),
      velocity: Vector3(0, 0.2, 0),
      lifespan: (0.6, 1),
      size: (0.25, 0.4),
      rotation: (0, 2 * math.pi),
      colors: const [Color(0xFFC8B48C)],
    );

    game.world.addAll([
      for (final (x, z) in const [
        (-2.0, -1.5),
        (2.0, -1.5),
        (-2.0, 1.5),
        (2.0, 1.5),
      ])
        MeshComponent(
          position: Vector3(x, 1.5, z),
          mesh: CuboidMesh(
            size: Vector3(0.8, 3, 0.8),
            material: SpatialMaterial(
              albedoColor: const Color(0xFF8C7A6B),
              metallic: 0.1,
              roughness: 0.8,
            ),
          ),
        ),
      sparks,
      smoke,
      coins,
      confetti,
      dust,
      _Every(1.5, () => coins.burst(16)),
      _Every(3, () => confetti.burst(80)),
      _Circling(dust, radius: 5, speed: 0.6),
    ]);
  }
}

/// Calls [action] every [period] seconds.
class _Every(final double period, final void Function() action)
    extends Component {
  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    while (_time >= period) {
      _time -= period;
      action();
    }
  }
}

/// Moves [target] along a circle on the ground.
class _Circling(
  final Component3D target, {
  required final double radius,
  required final double speed,
}) extends Component {
  double _angle = 0;

  @override
  void update(double dt) {
    _angle += speed * dt;
    target.position.setValues(
      math.cos(_angle) * radius,
      0.05,
      math.sin(_angle) * radius,
    );
  }
}
