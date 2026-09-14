import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class ZoomExample extends FlameGame
    with ScrollCallbacks, ScaleCallbacks, DragCallbacks {
  static const String description = '''
    On web: use scroll to zoom in and out.\n
    On mobile: use scale gesture to zoom in and out.
  ''';

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('assets/images/flame.png');

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
  void onScroll(ScrollEvent event) {
    camera.viewfinder.zoom += event.scrollDelta.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = startZoom * event.verticalScale;
    clampZoom();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Two-finger pinches emit both drag and scale; skip pan while zooming
    if (isScaling) {
      return;
    }
    final zoom = camera.viewfinder.zoom;
    camera.moveBy((event.localDelta..negate()) / zoom);
  }
}
