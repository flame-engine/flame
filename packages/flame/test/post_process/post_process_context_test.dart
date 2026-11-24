import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('findPostProcessFromContext with CameraComponent.postProcess', () {
    testWithFlameGame('is found by components in the world', (game) async {
      final postProcess = _TwoPassPostProcess();
      final probe = _ContextProbe();
      final nestedProbe = _ContextProbe();
      game.camera.postProcess = postProcess;
      game.world.addAll([
        probe,
        PositionComponent(children: [nestedProbe]),
      ]);
      await game.ready();

      game.render(Canvas(PictureRecorder()));

      expect(probe.seen, [postProcess, postProcess]);
      expect(nestedProbe.seen, [postProcess, postProcess]);
    });

    testWithFlameGame('is found by components in the viewfinder', (
      game,
    ) async {
      final postProcess = _TwoPassPostProcess();
      final probe = _ContextProbe();
      game.camera.postProcess = postProcess;
      game.camera.viewfinder.add(probe);
      await game.ready();

      game.render(Canvas(PictureRecorder()));

      expect(probe.seen, [postProcess, postProcess]);
    });

    testWithFlameGame(
      'is found from within a PostProcessComponent in the world',
      (game) async {
        final postProcess = _TwoPassPostProcess();
        final probe = _CameraPassProbe();
        game.camera.postProcess = postProcess;
        game.world.add(
          PostProcessComponent(
            postProcess: _OtherPostProcess(),
            size: Vector2.all(10),
            children: [probe],
          ),
        );
        await game.ready();

        game.render(Canvas(PictureRecorder()));

        expect(probe.seen, [postProcess, postProcess]);
      },
    );

    testWithFlameGame(
      'is not found by another camera rendering the same world',
      (game) async {
        final postProcess = _TwoPassPostProcess();
        final probe = _ContextProbe();
        game.camera.postProcess = postProcess;
        game.world.add(probe);
        final otherCamera = CameraComponent(world: game.world);
        game.add(otherCamera);
        await game.ready();

        game.render(Canvas(PictureRecorder()));

        // Rendered twice by the camera with the post process, then once by
        // the camera without it.
        expect(probe.seen, [postProcess, postProcess, null]);
      },
    );

    testWithFlameGame(
      'is found through a camera nested in the world',
      (game) async {
        final postProcess = _TwoPassPostProcess();
        final probe = _ContextProbe();
        final innerWorld = World(children: [probe]);
        game.camera.postProcess = postProcess;
        game.add(innerWorld);
        game.world.add(
          CameraComponent(
            world: innerWorld,
            viewport: FixedSizeViewport(100, 100),
          ),
        );
        await game.ready();

        game.render(Canvas(PictureRecorder()));

        expect(probe.seen, [postProcess, postProcess]);
      },
    );
  });
}

/// Renders its subtree twice.
class _TwoPassPostProcess() extends PostProcess {
  @override
  void postProcess(Vector2 size, Canvas canvas) {
    renderSubtree(canvas);
    renderSubtree(canvas);
  }
}

/// Renders its subtree once, like any [PostProcess] by default.
class _OtherPostProcess() extends PostProcess;

/// Records the post process it finds in its render context on every render.
class _ContextProbe() extends Component {
  final seen = <PostProcess?>[];

  @override
  void render(Canvas canvas) {
    seen.add(findPostProcessFromContext<PostProcess>());
  }
}

/// Records the [_TwoPassPostProcess] it finds in its render context on every
/// render.
class _CameraPassProbe() extends Component {
  final seen = <PostProcess?>[];

  @override
  void render(Canvas canvas) {
    seen.add(findPostProcessFromContext<_TwoPassPostProcess>());
  }
}
