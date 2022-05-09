import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('FPSComponent', () {
    testWithFlameGame('reports correct FPS for 1 frames', (game) async {
      final fpsComponent = FPSComponent();
      await game.ensureAdd(fpsComponent);
      expect(fpsComponent.fps, 0);
      game.update(1 / 60);

      expect(fpsComponent.fps, 60.0);
    });

    testWithFlameGame('reports correct FPS with full window', (game) async {
      const windowSize = 30;
      final fpsComponent = FPSComponent(windowSize: windowSize);
      await game.ensureAdd(fpsComponent);
      for (var i = 0; i < windowSize; i++) {
        game.update(1 / 60);
      }

      expect(fpsComponent.fps, 60.0);
    });

    testWithFlameGame('reports correct FPS with slided window', (game) async {
      const windowSize = 30;
      final fpsComponent = FPSComponent(windowSize: windowSize);
      await game.ensureAdd(fpsComponent);
      for (var i = 0; i < 2 * windowSize; i++) {
        game.update(1 / 60);
      }

      expect(fpsComponent.fps, 60.0);
    });

    testWithFlameGame('reports correct FPS with varying dt', (game) async {
      final fpsComponent = FPSComponent();
      await game.ensureAdd(fpsComponent);
      for (var i = 0; i < fpsComponent.windowSize; i++) {
        // Alternating between 50 and 100 FPS
        final dt = i.isEven ? 1 / 100 : 1 / 50;
        game.update(dt);
      }

      expect(fpsComponent.fps, closeTo(100 / 1.5, 0.00000000001));
    });
  });
}
