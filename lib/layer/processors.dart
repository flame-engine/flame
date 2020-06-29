import 'dart:ui';

abstract class LayerProcessor {
  void process(Picture pic, Canvas canvas);
}

class ShadowProcessor extends LayerProcessor {
  Paint _shadowPaint;

  final Offset offset;

  ShadowProcessor({
    this.offset = const Offset(10, 10),
    double opacity = 0.9,
    Color color = const Color(0xFF000000),
  }) {
    _shadowPaint = Paint()
      ..colorFilter =
          ColorFilter.mode(color.withOpacity(opacity), BlendMode.srcATop);
  }

  @override
  void process(Picture pic, Canvas canvas) {
    canvas.saveLayer(Rect.largest, _shadowPaint);
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPicture(pic);
    canvas.restore();
  }
}
