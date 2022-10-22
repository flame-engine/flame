import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockParticle extends Mock implements CircleParticle {}

void main() {
  group('CircleParticle', () {
    test('Should render this Particle to given Canvas', () {
      final particle = MockParticle();

      final canvas = MockCanvas();
      ParticleSystemComponent(particle: particle).render(canvas);

      verify(() => particle.render(canvas)).called(1);
    });

    testWithFlameGame(
        'Consider composing this with other Particle to achieve needed effects',
        (game) async {
      final childParticle = CircleParticle(
        paint: Paint()..color = Colors.red,
        lifespan: 2,
      );

      final component = ParticleSystemComponent(
        particle: childParticle,
      );

      game.add(component);
      await game.ready();
      game.update(1);

      expect(childParticle.progress, 0.5);
    });
  });
}
