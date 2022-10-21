import 'package:canvas_test/canvas_test.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/components/particle_system_component.dart';
import 'package:flame/src/particles/sprite_particle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockParticle extends Mock implements SpriteParticle {}

Future<void> main() async {
  // Generate an image
  final image = await generateImage();

  group('SpriteParticle', () {
    test('Should render this Particle to given Canvas', () {
      final particle = MockParticle();

      final canvas = MockCanvas();
      ParticleSystemComponent(particle: particle).render(canvas);

      verify(() => particle.render(canvas)).called(1);
    });

    final sprite = Sprite(image);
    testWithFlameGame(
        'SpriteParticle allows easily embed Flames Sprite into the effect',
        (game) async {
      final particle = SpriteParticle(
        sprite: sprite,
        size: Vector2(50, 50),
        lifespan: 2,
      );

      final component = ParticleSystemComponent(
        particle: particle,
      );

      game.add(component);
      await game.ready();
      game.update(1);
      expect(particle.progress, 0.5);
    });
  });
}
