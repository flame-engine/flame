import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ZoomExample extends FlameGame with ScrollDetector, ScaleDetector {
  static const String description = '''
    On web: use scroll to zoom in and out.\n
    On mobile: use scale gesture to zoom in and out.
  ''';

  final Vector2 viewportResolution;
  late SpriteComponent flame;

  ZoomExample({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');

    camera.viewport = FixedResolutionViewport(viewportResolution);
    camera.setRelativeOffset(Anchor.center);
    camera.speed = 100;

    final flameSize = Vector2(149, 211);
    add(
      flame = SpriteComponent(
        sprite: flameSprite,
        size: flameSize,
      )..anchor = Anchor.center,
    );
  }

  void clampZoom() {
    camera.zoom = camera.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = 0.02;

  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.zoom = startZoom * currentScale.y;
      clampZoom();
    } else {
      camera.translateBy(-info.delta.game);
      camera.snap();
    }
  }
}
