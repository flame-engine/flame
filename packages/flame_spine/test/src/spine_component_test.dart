import 'package:flame_spine/flame_spine.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SkeletonAnimation skeleton;
  late List<String> animations;

  setUpAll(() async {
    skeleton = await loadSkeleton('spineboy');
    animations = await loadAnimations('spineboy');
  });

  group('SpineComponent', () {
    testWithFlameGame('Can Add to FlameGame', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: skeleton),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      expect(spineComponent.parent, game);
    });

    testWithFlameGame('Can play animation', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: skeleton),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      spineComponent.renderer.playState = PlayState.playing;

      expect(spineComponent.renderer.playState, PlayState.playing);
    });

    testWithFlameGame('Can pause animation', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: skeleton),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      spineComponent.renderer.playState = PlayState.paused;

      expect(spineComponent.renderer.playState, PlayState.paused);
    });

    testWithFlameGame('Can change animation', (game) async {
      final spineComponent = SpineComponent(
        renderer: SkeletonRender(skeleton: skeleton),
        size: game.size / 2,
      );

      game.add(spineComponent);
      await game.ready();

      spineComponent.renderer.animation = animations[1];

      expect(spineComponent.renderer.animation, animations[1]);
    });
  });
}
