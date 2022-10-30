import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class OverlappingTappablesExample extends FlameGame with HasTappables {
  static const String description = '''
    In this example we show how you can stop event propagation to the components
    by returning `false` in the overridden event handler method. In this case we
    use `onTapUp`, `onTapDown` and `onTapCancel` from the `Tappable mixin.
  ''';

  @override
  Future<void> onLoad() async {
    add(TappableSquare(position: Vector2(100, 100)));
    add(TappableSquare(position: Vector2(150, 150)));
    add(TappableSquare(position: Vector2(100, 200)));
  }
}

class TappableSquare extends RectangleComponent with Tappable {
  TappableSquare({Vector2? position})
      : super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
          paint: PaintExtension.random(withAlpha: 0.9, base: 100),
        );

  @override
  bool onTapUp(_) {
    return false;
  }

  @override
  bool onTapDown(_) {
    angle += 1.0;
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }
}
