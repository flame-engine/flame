import 'package:flame_spine/flame_spine.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpineComponent', () {
    testWithFlameGame('Can Add to FlameGame', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: MockAnimation()),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      expect(spineComponent.parent, game);
    });

    testWithFlameGame('Can play animation', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: MockAnimation()),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      spineComponent.renderer.playState = PlayState.playing;

      expect(spineComponent.renderer.playState, PlayState.playing);
    });
    testWithFlameGame('Can pause animation', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: MockAnimation()),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      spineComponent.renderer.playState = PlayState.paused;

      expect(spineComponent.renderer.playState, PlayState.paused);
    });
  });
}

class MockAnimation extends Mock implements SkeletonAnimation {}
