import 'package:examples/commons/ember.dart';
import 'package:flame/game.dart';

class FlipSpriteExample extends FlameGame {
  static const String description = '''
    In this example we show how you can flip components horizontally and
    vertically.
  ''';

  @override
  Future<void> onLoad() async {
    final regular = Ember(position: Vector2(size.x / 2 - 100, 200));
    add(regular);

    final flipX = Ember(position: Vector2(size.x / 2 - 100, 400));
    flipX.flipHorizontally();
    add(flipX);

    final flipY = Ember(position: Vector2(size.x / 2 + 100, 200));
    flipY.flipVertically();
    add(flipY);

    final flipWithRotation = Ember(position: Vector2(size.x / 2 + 100, 400))
      ..angle = 2;
    flipWithRotation.flipVertically();
    add(flipWithRotation);
  }
}
