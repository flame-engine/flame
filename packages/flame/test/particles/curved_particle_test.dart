import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurvedParticle', () {
    test('A Particle which applies certain Curve', () async {
      final particle = CurvedParticle();

      expect(particle.curve, Curves.linear);
    });

    test('A Particle which applies certain Curve', () async {
      final particle = CurvedParticle(curve: Curves.decelerate);

      expect(particle.curve, Curves.decelerate);
    });

    testWithFlameGame(
        'A Particle which applies certain Curve for easing or other purposes'
        ' to its progress getter.', (game) async {
      final particle = CurvedParticle(lifespan: 2);
      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(particle.curve, Curves.linear);
      expect(particle.progress, 0.5);
    });
  });
}
