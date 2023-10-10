import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ZoomExample extends FlameGame with ScrollDetector, ScaleDetector {
  static const String description = '''
    On web: use scroll to zoom in and out.\n
    On mobile: use scale gesture to zoom in and out.
  ''';

  ZoomExample({
    required Vector2 viewportResolution,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
        );

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');

    world.add(
      SpriteComponent(
        sprite: flameSprite,
        size: Vector2(149, 211),
      )..anchor = Anchor.center,
    );
  }

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = 0.02;

  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom +=
        info.scrollDelta.global.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.viewfinder.zoom = startZoom * currentScale.y;
      clampZoom();
    } else {
      final delta = info.delta.global;
      camera.viewfinder.position.translate(-delta.x, -delta.y);
    }
  }
}
