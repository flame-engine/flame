import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopPostProcess() extends PostProcess {
  @override
  void postProcess(Vector2 size, Canvas canvas) {
    renderSubtree(canvas);
  }
}

/// Records what [findPostProcessFromContext] returns on every render.
class _ProbeComponent() extends PositionComponent {
  final seen = <PostProcess?>[];

  @override
  void render(Canvas canvas) {
    seen.add(findPostProcessFromContext());
    super.render(canvas);
  }
}

void main() {
  group('findPostProcessFromContext', () {
    testWithFlameGame(
      'finds the post process of the camera rendering the world',
      (game) async {
        final postProcess = _NoopPostProcess();
        final probe = _ProbeComponent();
        final world = World(children: [probe]);
        final camera = CameraComponent(world: world)..postProcess = postProcess;
        await game.ensureAddAll([world, camera]);

        game.render(Canvas(PictureRecorder()));

        expect(probe.seen, isNotEmpty);
        expect(probe.seen.last, same(postProcess));
      },
    );

    testWithFlameGame(
      'finds the post process of the camera rendering the viewfinder',
      (game) async {
        final postProcess = _NoopPostProcess();
        final probe = _ProbeComponent();
        final world = World();
        final camera = CameraComponent(world: world)..postProcess = postProcess;
        camera.viewfinder.add(probe);
        await game.ensureAddAll([world, camera]);

        game.render(Canvas(PictureRecorder()));

        expect(probe.seen, isNotEmpty);
        expect(probe.seen.last, same(postProcess));
      },
    );

    testWithFlameGame('is null when the camera has no post process', (
      game,
    ) async {
      final probe = _ProbeComponent();
      final world = World(children: [probe]);
      final camera = CameraComponent(world: world);
      await game.ensureAddAll([world, camera]);

      game.render(Canvas(PictureRecorder()));

      expect(probe.seen, isNotEmpty);
      expect(probe.seen.last, isNull);
    });
  });
}
