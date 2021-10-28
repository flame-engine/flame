
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class RotateEffect2Game extends FlameGame {

  @override
  void onMount() {
    camera.viewport = FixedResolutionViewport(Vector2(400, 600));
    add(Compass(200) ..position=Vector2(200, 300));
  }
}

class Compass extends PositionComponent {
  Compass(double size)
    : _radius = size/2,
      super(
        size: Vector2.all(size),
        anchor: Anchor.center,
      );

  final double _radius;
  late Paint _bgPaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _bgPaint = Paint() ..color=const Color(0xFFC9B342);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(_radius, _radius), _radius, _bgPaint);
  }
}
