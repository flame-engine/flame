import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

const priorityInfo = '''
On this example, click on the square to bring them to the front by changing the
priority.
''';

class Square extends PositionComponent with HasGameRef<Priority>, Tappable {
  late final Paint paint;

  Square(Vector2 position) {
    this.position.setFrom(position);
    size.setValues(100, 100);
    paint = _randomPaint();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final topComponent = gameRef.children.last;
    if (topComponent != this) {
      gameRef.changePriority(this, topComponent.priority + 1);
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }

  static Paint _randomPaint() {
    final rng = Random();
    final color = Color.fromRGBO(
      rng.nextInt(256),
      rng.nextInt(256),
      rng.nextInt(256),
      0.9,
    );
    return PaletteEntry(color).paint();
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
