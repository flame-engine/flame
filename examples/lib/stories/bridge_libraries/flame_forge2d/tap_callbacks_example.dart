import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/balls.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class TapCallbacksExample extends Forge2DGame {
  static const String description = '''
    In this example we show how to use Flame's TapCallbacks mixin to react to
    taps on `BodyComponent`s.
    Tap the ball to give it a random impulse, or the text to add an effect to
    it.
  ''';
  TapCallbacksExample() : super(zoom: 20, gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    world.addAll(boundaries);
    world.add(TappableBall(Vector2.zero()));
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
