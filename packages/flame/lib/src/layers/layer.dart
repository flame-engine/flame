import 'dart:ui';

import 'package:meta/meta.dart';

import 'processors.dart';

abstract class Layer {
  List<LayerProcessor> preProcessors = [];
  List<LayerProcessor> postProcessors = [];

  Picture? _picture;

  PictureRecorder? _recorder;
  Canvas? _canvas;

  @mustCallSuper
  void render(Canvas canvas, {double x = 0.0, double y = 0.0}) {
    if (_picture == null) {
      return;
    }

    canvas.save();
    canvas.translate(x, y);

    preProcessors.forEach((p) => p.process(_picture!, canvas));
    canvas.drawPicture(_picture!);
    postProcessors.forEach((p) => p.process(_picture!, canvas));
    canvas.restore();
  }

  Canvas get canvas {
    assert(
      _canvas != null,
      'Layer is not ready for rendering, call beginRendering first',
    );
    return _canvas!;
  }

  void beginRendering() {
    _recorder = PictureRecorder();
    _canvas = Canvas(_recorder!);
  }

  void finishRendering() {
    _picture = _recorder?.endRecording();

    _recorder = null;
    _canvas = null;
  }

  void drawLayer();
}

abstract class PreRenderedLayer extends Layer {
  PreRenderedLayer() {
    reRender();
  }

  void reRender() {
    beginRendering();
    drawLayer();
    finishRendering();
  }
}

abstract class DynamicLayer extends Layer {
  @override
  void render(Canvas canvas, {double x = 0.0, double y = 0.0}) {
    beginRendering();
    drawLayer();
    finishRendering();

    super.render(canvas, x: x, y: y);
  }
}
