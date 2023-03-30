import 'package:examples/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class TappableExample extends Forge2DGame {
  static const String description = '''
    In this example we show how to use Flame's TapCallbacks mixin to react to
    taps on `BodyComponent`s.
    Tap the ball to give it a random impulse, or the text to add an effect to
    it.
  ''';
  TappableExample() : super(zoom: 20, gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    add(TappableBall(center));
  }
}

class TappableBall extends Ball with TapCallbacks {
  TappableBall(super.position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  void onTapDown(_) {
    body.applyLinearImpulse(Vector2.random() * 1000);
    paint = randomPaint();
  }
}
