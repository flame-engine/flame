import 'dart:math';

import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame/src/particles/computed_particle.dart';
import 'package:flame/src/particles/rotating_particle.dart';
import 'package:flame/src/particles/scaled_particle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScaledParticle', () {
    testWithFlameGame(
        'A particle which rotates its child over the lifespan between two '
        'given bounds in radians', (game) async {
      final paint = Paint()..color = Colors.red;
      final rect = ComputedParticle(
        renderer: (canvas, _) => canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 10, height: 10),
          paint,
        ),
      );

      final particle = ScaledParticle(
        lifespan: 2,
        child: rect.rotating(to: pi / 2),
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(particle.scale, 1.0);
      expect(particle.child, isInstanceOf<RotatingParticle>());
      expect(particle.child.progress, 0.5);
    });
  });
}
