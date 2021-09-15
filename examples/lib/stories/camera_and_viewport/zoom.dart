import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ZoomGame extends FlameGame with ScrollDetector, ScaleDetector {
  final Vector2 viewportResolution;
  late SpriteComponent flame;

  Vector2? lastScale;

  ZoomGame({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final flameSprite = await loadSprite('flame.png');

    camera.viewport = FixedResolutionViewport(viewportResolution);
    camera.setRelativeOffset(Anchor.center);
    camera.speed = 1;

    final flameSize = Vector2(149, 211);
    add(
      flame = SpriteComponent(
        sprite: flameSprite,
        size: flameSize,
      )..anchor = Anchor.center,
    );
  }

  void resetIfZero() {
    if (camera.zoom < 0) {
      camera.zoom = 1.0;
    }
  }

  static const zoomPerScrollUnit = 0.01;
  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    resetIfZero();
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = lastScale;
    if (scale != null) {
      final delta = info.scale.game - scale;
      camera.zoom += delta.y;
      resetIfZero();
    }

    lastScale = info.scale.game;
  }
}
