import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockParticle extends Mock implements Particle {}

void main() {
  group('ParticleSystem', () {
    test('returns the progress of its particle', () {
      final particle = MockParticle();
      when(() => particle.progress).thenReturn(0.2);

      final progress = ParticleSystemComponent(particle: particle).progress;
      expect(progress, equals(0.2));
    });

    test('returns the progress of its particle', () {
      final particle = MockParticle();

      final canvas = MockCanvas();
      ParticleSystemComponent(particle: particle).render(canvas);

      verify(() => particle.render(canvas)).called(1);
    });

    test('updates its particle', () {
      final particle = MockParticle();
      when(() => particle.shouldRemove).thenReturn(false);

      ParticleSystemComponent(particle: particle).update(0.1);
      verify(() => particle.update(0.1)).called(1);
    });

    testWithFlameGame(
      'is removed when its particle is finished',
      (FlameGame game) async {
        final particle = MockParticle();
        when(() => particle.shouldRemove).thenReturn(true);

        final component = ParticleSystemComponent(particle: particle);
        await game.ensureAdd(component);

        game.update(1);

        expect(component.shouldRemove, isTrue);
      },
    );
  });
}
