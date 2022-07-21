import 'dart:ui';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';

class DecoratorShadowGame extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() => const Color(0xFFAAAAAA);

  @override
  Future<void> onLoad() async {
    var step = 0;
    add(Grid());
    add(
      MyRect(
        size: Vector2(100, 150),
        position: Vector2(300, 150),
        onTap: (flower) {
          step++;
          if (step == 1) {
            flower.decorator = Shadow3DDecorator(
              base: Vector2(350, 300),
            );
          } else if (step == 2) {
          } else if (step == 3) {
          } else {
            flower.decorator = null;
            step = 0;
          }
        },
      )..onTapUp(),
    );
  }
}

class MyRect extends RectangleComponent with HasDecorator, TapCallbacks {
  MyRect({super.size, super.position, this.onTap})
      : pos0 = position!,
        super(paint: Paint()..color = const Color(0xcc6eb5ff));

  Vector2 pos0;
  void Function(MyRect)? onTap;

  @override
  void onTapUp([TapUpEvent? event]) {
    onTap?.call(this);
  }

  double timer = 0.0;

  @override
  void update(double dt) {
    timer += dt * 0;
    position.y = pos0.y - timer;
    (decorator! as Shadow3DDecorator).ascent = timer;
  }
}

class Grid extends Component {
  final paint = Paint()
    ..color = const Color(0xffa3d5ff)
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
