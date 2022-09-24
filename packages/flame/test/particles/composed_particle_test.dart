import 'package:flame/particles.dart';
import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComposedParticle', () {
    testWithFlameGame('particles with parent lifespan applied to children',
        (game) async {
      final childParticle1 = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 1,
      );
      final childParticle2 = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 3,
      );

      final particle = ComposedParticle(
        children: [
          childParticle1,
          childParticle2,
        ],
        lifespan: 2,
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(particle.progress, 0.5);
      expect(childParticle1.progress, 0.5);
      expect(childParticle2.progress, 0.5);
      expect(particle.children.length, 2);

      game.update(1);

      expect(particle.progress, 1);
      expect(childParticle1.progress, 1);
      expect(childParticle2.progress, 1);
      expect(particle.children.length, 2);
    });

    testWithFlameGame('particles without parent lifespan applied to children',
        (game) async {
      final childParticle1 = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 1,
      );
      final childParticle2 = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 4,
      );

      final particle = ComposedParticle(
        children: [
          childParticle1,
          childParticle2,
        ],
        lifespan: 2,
        applyLifespanToChildren: false,
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(particle.progress, 0.5);
      expect(childParticle1.progress, 1);
      expect(childParticle2.progress, 0.25);
      expect(particle.children.length, 2);

      game.update(1);

      expect(particle.progress, 1);
      expect(childParticle1.progress, 1);
      expect(childParticle2.progress, 0.5);
      expect(particle.children.length, 1);
    });

    testWithFlameGame(
      'generate particles without parent lifespan applied to children',
      (game) async {
        const particlesCount = 15;
        final component = ParticleSystemComponent(
          particle: Particle.generate(
            count: particlesCount,
            generator: (i) {
              return CircleParticle(
                paint: Paint()..color = Colors.red,
                lifespan: 5,
              );
            },
            applyLifespanToChildren: false,
            lifespan: 10,
          ),
        );

        game.add(component);
        await game.ready();
        game.update(1);

        expect(component.particle!.progress, 0.1);
        final children1 = (component.particle! as ComposedParticle).children;
        expect(children1.length, particlesCount);
        for (final child in children1) {
          expect(child.progress, 0.2);
        }

        game.update(1);

        expect(component.particle!.progress, 0.2);
        final children2 = (component.particle! as ComposedParticle).children;
        expect(children2.length, particlesCount);
        for (final child in children2) {
          expect(child.progress, 0.4);
        }
      },
    );
  });
}
