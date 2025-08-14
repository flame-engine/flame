import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedResolutionViewport.virtualSize', () {
    testWithFlameGame('remains the same after resize', (game) async {
      final fixedResolution = Vector2(800, 600);
      final viewport = FixedResolutionViewport(resolution: fixedResolution);
      game.camera.viewport = viewport;

      await game.ready();

      final resize = Vector2(400, 300);
      game.onGameResize(resize);

      expect(viewport.size, resize);
      expect(viewport.virtualSize, fixedResolution);
    });

    testWithFlameGame(
      'children components receive virtualSize in onParentResize',
      (game) async {
        final fixedResolution = Vector2(800, 600);
        final viewport = FixedResolutionViewport(resolution: fixedResolution);
        game.camera.viewport = viewport;

        final child = _OnParentResizeTesterComponent();
        await child.addToParent(viewport);

        await game.ready();

        expect(child._parentSize, fixedResolution);

        game.onGameResize(Vector2(400, 300));
        expect(child._parentSize, fixedResolution);
      },
    );
  });
}

class _OnParentResizeTesterComponent extends PositionComponent {
  _OnParentResizeTesterComponent();

  Vector2? _parentSize;

  @override
  void onParentResize(Vector2 size) {
    _parentSize = size;
  }
}
