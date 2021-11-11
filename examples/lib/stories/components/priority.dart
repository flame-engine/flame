import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

const priorityInfo = '''
On this example, click on the square to bring them to the front by changing the
priority.
''';

class Square extends PositionComponent with HasGameRef<Priority>, Tappable {
  late final Paint paint;

  Square(Vector2 position) {
    this.position.setFrom(position);
    size.setValues(100, 100);
    paint = PaintExtension.random(withAlpha: 0.9, base: 100);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final topComponent = gameRef.children.last;
    if (topComponent != this) {
      gameRef.children.changePriority(this, topComponent.priority + 1);
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), paint);
  }
}

class Priority extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final squares = [
      Square(Vector2(100, 100)),
      Square(Vector2(160, 100)),
      Square(Vector2(170, 150)),
      Square(Vector2(110, 150)),
    ];
    addAll(squares);
  }
}
