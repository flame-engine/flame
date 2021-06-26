import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

class ZoomGame extends BaseGame with ScrollDetector, ScaleDetector {
  final Vector2 viewportResolution;
  late SpriteComponent flame;

  Vector2? lastScale;

  ZoomGame({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');

    viewport = FixedResolutionViewport(viewportResolution);
    camera.setRelativeOffset(Anchor.center);
    camera.cameraSpeed = 1;

    final flameSize = Vector2(149, 211);
    add(
      flame = SpriteComponent(
        sprite: flameSprite,
        size: flameSize,
      )..anchor = Anchor.center,
    );
  }

  static const zoomPerScrollUnit = 0.001;
  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y * zoomPerScrollUnit;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = lastScale;
    if (scale != null) {
      final delta = info.scale.game - scale;
      camera.zoom += delta.y;
    }

    lastScale = info.scale.game;
  }
}
