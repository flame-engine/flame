import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';

/// [PaintDecorator] applies a paint filter to a group of drawing operations.
///
/// Specifically, the following filters are available:
/// - [PaintDecorator.blur] adds Gaussian blur to the image, as if your vision
///   became blurry and out of focus;
/// - [PaintDecorator.tint] tints the picture with the specified color, as if
///   looking through a colored glass;
/// - [PaintDecorator.grayscale] removes all color from the picture, as if it
///   was a black-and-white photo.
class PaintDecorator extends Decorator {
  PaintDecorator.blur(double amount, [double? amountY]) {
    addBlur(amount, amountY ?? amount);
  }

  PaintDecorator.tint(Color color) {
    _paint.colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
  }

  PaintDecorator.grayscale({double opacity = 1.0}) {
    _paint.color = Color.fromARGB((255 * opacity).toInt(), 0, 0, 0);
    _paint.blendMode = BlendMode.luminosity;
  }

  final _paint = Paint();

  void addBlur(double amount, [double? amountY]) {
    _paint.imageFilter =
        ImageFilter.blur(sigmaX: amount, sigmaY: amountY ?? amount);
  }

  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    canvas.saveLayer(null, _paint);
    draw(canvas);
    canvas.restore();
  }
}
