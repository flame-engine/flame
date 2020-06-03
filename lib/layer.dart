import 'dart:ui';

class Layer {
  List<LayerProcessor> preProcessors = [];
  List<LayerProcessor> postProcessors = [];

  Picture _picture;

  PictureRecorder _recorder;
  Canvas _canvas;

  void render(Canvas canvas, {double x = 0.0, double y = 0.0}) {
    if (_picture == null) {
      return;
    }

    canvas.save();
    canvas.translate(x, y);

    preProcessors.forEach((p) => p.process(_picture, canvas));
    canvas.drawPicture(_picture);
    postProcessors.forEach((p) => p.process(_picture, canvas));
    canvas.restore();
  }

  Canvas get canvas {
    assert(_canvas != null,
        'Layer is not ready for rendering, call beginRendering first');
    return _canvas;
  }

  void beginRendering() {
    _recorder = PictureRecorder();
    _canvas = Canvas(_recorder);
  }

  void finishRendering() {
    _picture = _recorder.endRecording();

    _recorder = null;
    _canvas = null;
  }
}

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
