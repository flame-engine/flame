import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  group('PostProcessComponent', () {
    testWithFlameGame('renders post process with explicit size', (game) async {
      final postProcess = PostProcessComponent(
        postProcess: PostProcessGroup(postProcesses: []),
        size: Vector2.all(100),
      );
      await game.ensureAdd(postProcess);

      expect(game.children, contains(postProcess));
      expect(postProcess.size, Vector2.all(100));
    });

    testWithFlameGame(
      'renders post process with the bounding box of the children',
      (game) async {
        final postProcess = PostProcessComponent(
          postProcess: PostProcessGroup(postProcesses: []),
          children: [
            PositionComponent(size: Vector2.all(50)),
            PositionComponent(
              position: Vector2.all(100),
              size: Vector2.all(50),
            ),
          ],
        );
        await game.ensureAdd(postProcess);

        expect(game.children, contains(postProcess));
        expect(postProcess.size, Vector2.all(150));
      },
    );

    testWithFlameGame('changes size when children change', (game) async {
      final componentA = PositionComponent(size: Vector2.all(50));
      final componentB = PositionComponent(
        position: Vector2.all(100),
        size: Vector2.all(50),
      );
      final postProcess = PostProcessComponent(
        postProcess: PostProcessGroup(postProcesses: []),
        children: [componentA, componentB],
      );
      await game.ensureAdd(postProcess);

      expect(game.children, contains(postProcess));
      expect(postProcess.size, Vector2.all(150));
      componentB.removeFromParent();
      game.update(0);
      expect(postProcess.size, Vector2.all(50));
    });

    testWithFlameGame('has zero size when the last child is removed', (
      game,
    ) async {
      final child = PositionComponent(size: Vector2.all(50));
      final postProcess = PostProcessComponent(
        postProcess: PostProcessGroup(postProcesses: []),
        children: [child],
      );
      await game.ensureAdd(postProcess);

      child.removeFromParent();
      await game.ready();

      expect(postProcess.children, isEmpty);
      expect(postProcess.size, Vector2.zero());
    });

    testWithFlameGame(
      'has zero size when no child is a PositionComponent',
      (game) async {
        final postProcess = PostProcessComponent(
          postProcess: PostProcessGroup(postProcesses: []),
          children: [Component()],
        );
        await game.ensureAdd(postProcess);

        expect(postProcess.children, hasLength(1));
        expect(postProcess.size, Vector2.zero());
      },
    );
  });
}
