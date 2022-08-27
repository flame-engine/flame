import 'dart:ui';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorShadowGame extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() => const Color(0xFFC7C7C7);

  @override
  Future<void> onLoad() async {
    final decorator = Shadow3DDecorator(base: Vector2(0, 100));
    var step = 0;
    add(Grid());
    add(
      Flower(
        size: 100,
        position: canvasSize / 2,
        decorator: decorator,
        onTap: (flower) {
          step++;
          if (step == 1) {
            decorator.xShift = 200;
            decorator.opacity = 0.5;
          } else if (step == 2) {
            decorator.xShift = 400;
            decorator.yScale = 3;
            decorator.blur = 1;
          } else if (step == 3) {
            decorator.angle = 1.7;
            decorator.blur = 2;
          } else if (step == 4) {
            decorator.ascent = 20;
            decorator.angle = 1.7;
            decorator.blur = 2;
            flower.y -= 20;
          } else {
            decorator.ascent = 0;
            decorator.xShift = 0;
            decorator.yScale = 1;
            decorator.angle = -1.4;
            decorator.opacity = 0.8;
            decorator.blur = 0;
            flower.y += 20;
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}

class Grid extends Component {
  final paint = Paint()
    ..color = const Color(0xffa9a9a9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  @override
  void render(Canvas canvas) {
    for (var i = 0; i < 50; i++) {
      canvas.drawLine(Offset(0, i * 25), Offset(500, i * 25), paint);
      canvas.drawLine(Offset(i * 25, 0), Offset(i * 25, 500), paint);
    }
  }
}
