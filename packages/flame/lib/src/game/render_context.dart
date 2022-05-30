import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

class RenderContext {
  RenderContext(this.canvas);

  final Canvas canvas;

  final List<_CanvasOperation> _operations = [];

  void transformCanvas(Matrix4 transform) {
    _operations.add(_CanvasTransform(transform));
    canvas.save();
    canvas.transform(transform.storage);
  }

  void translateCanvas(double dx, double dy) {
    _operations.add(_CanvasTranslation(dx, dy));
    canvas.save();
    canvas.translate(dx, dy);
  }

  void restore() {
    _operations.removeLast();
    canvas.restore();
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
