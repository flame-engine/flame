import 'dart:ui';

import 'package:flame/src/decorator.dart';

class PaintDecorator extends Decorator {
  final _paint = Paint();

  void addBlur(double amount, [double? amountY]) {
    _paint.imageFilter =
        ImageFilter.blur(sigmaX: amount, sigmaY: amountY ?? amount);
  }

  void addTint(Color color) {
    _paint.colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
  }

  void addDesaturation({double opacity = 1.0}) {
    _paint.blendMode = BlendMode.luminosity;
    _paint.color = Color.fromARGB((255 * opacity).toInt(), 0, 0, 0);
  }

  @override
  Canvas preprocessCanvas(Canvas canvas) {
    canvas.saveLayer(null, _paint);
    return canvas;
  }

  @override
  void postprocessCanvas(Canvas canvas) {
    canvas.restore();
  }
}
