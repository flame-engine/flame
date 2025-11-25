import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame/src/particles/computed_particle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScalingParticle', () {
    testWithFlameGame('A particle which scale its child over the lifespan '
        'between 1 and a provided scale', (game) async {
      final paint = Paint()..color = Colors.red;
      final rect = ComputedParticle(
        lifespan: 2,
        renderer: (canvas, _) => canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 10, height: 10),
          paint,
        ),
      );

      final particle = rect.scaling(to: 0.5, curve: Curves.easeIn);

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(particle.scale, 0.841796875);
      expect(particle.curve, Curves.easeIn);
      expect(particle.progress, 0.31640625);
      expect(particle.child, isInstanceOf<ComputedParticle>());
      expect(particle.child.progress, 0.5);
    });
  });
}
