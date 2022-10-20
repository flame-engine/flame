import 'package:flame/extensions.dart';
import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame/src/particles/circle_particle.dart';
import 'package:flame/src/particles/moving_particle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovingParticle', () {
    testWithFlameGame(
        'Particle which is moving from one predefined position to another one',
        (game) async {
      final childParticle = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 2,
      );

      final particle = MovingParticle(
        from: Vector2(-20, -20),
        to: Vector2(20, 20),
        child: childParticle,
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);
      expect(particle.progress, 1.0);
    });
  });
}
