import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class ZoomExample extends FlameGame with ScrollDetector, ScaleDetector {
  static const String description = '''
    On web: use scroll to zoom in and out.\n
    On mobile: use scale gesture to zoom in and out.
  ''';

  ZoomExample({
    required this.viewportResolution,
  });

  final Vector2 viewportResolution;
  late SpriteComponent flame;

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');

    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: viewportResolution.x,
      height: viewportResolution.y,
    );

    world.add(
      flame = SpriteComponent(
        sprite: flameSprite,
        size: Vector2(149, 211),
      )..anchor = Anchor.center,
    );
  }

  void clampZoom() {
    cameraComponent.viewfinder.zoom =
        cameraComponent.viewfinder.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = 0.02;

  @override
  void onScroll(PointerScrollInfo info) {
    cameraComponent.viewfinder.zoom +=
        info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = cameraComponent.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      cameraComponent.viewfinder.zoom = startZoom * currentScale.y;
      clampZoom();
    } else {
      final delta = info.delta.game;
      cameraComponent.viewfinder.position.translate(-delta.x, -delta.y);
    }
  }
}
