import 'package:flame/particles.dart';
import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComputedParticle', () {
    testWithFlameGame(
        'Particle container which delegates rendering particle on each frame',
        (game) async {
      final cellSize = game.size / 5.0;
      final halfCellSize = cellSize / 2;

      final particle = ComputedParticle(
        renderer: (canvas, particle) {
          canvas.drawCircle(
            Offset.zero,
            particle.progress * halfCellSize.x,
            Paint()
              ..color = Color.lerp(
                Colors.red,
                Colors.blue,
                particle.progress,
              )!,
          );
        },
        lifespan: 2,
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);
      expect(particle.progress, 0.5);

      game.update(1);
      expect(particle.progress, 1);
    });

    testWithFlameGame('Particle to use custom tweening', (game) async {
      final cellSize = game.size / 5.0;
      final halfCellSize = cellSize / 2;
      final steppedTween = StepTween(begin: 0, end: 5);

      final particle = ComputedParticle(
        lifespan: 2,
        renderer: (canvas, particle) {
          const steps = 5;
          final steppedProgress =
              steppedTween.transform(particle.progress) / steps;

          canvas.drawCircle(
            Offset.zero,
            (1 - steppedProgress) * halfCellSize.x,
            Paint()
              ..color = Color.lerp(
                Colors.red,
                Colors.blue,
                steppedProgress,
              )!,
          );
        },
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);
      expect(particle.progress, 0.5);

      game.update(1);
      expect(particle.progress, 1);
    });
  });
}
