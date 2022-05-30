import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

class RenderContext {
  Canvas get canvas => _canvas!;
  Canvas? _canvas;

  final List<_CanvasOperation> _operations = [];

  void startPipeline(Canvas canvas) {
    _canvas = canvas;
    _operations.clear();
  }

  void finishPipeline() {
    _canvas = null;
  }

  void transformCanvas(Matrix4 transform) {
    _operations.add(_CanvasTransform(transform));
    _canvas!.save();
    _canvas!.transform(transform.storage);
  }

  void translateCanvas(double dx, double dy) {
    _operations.add(_CanvasTranslation(dx, dy));
    _canvas!.save();
    _canvas!.translate(dx, dy);
  }

  void restore() {
    _operations.removeLast();
    _canvas!.restore();
  }
}

class _CanvasOperation {}

class _CanvasTransform extends _CanvasOperation {
  _CanvasTransform(this.matrix);
  final Matrix4 matrix;
}

class _CanvasTranslation extends _CanvasOperation {
  _CanvasTranslation(this.dx, this.dy);
  final double dx, dy;
}
