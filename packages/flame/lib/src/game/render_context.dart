import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// Helper class that assists the rendering pipeline in Flame.
///
/// This class keeps track of all canvas transformations applied thus far,
/// allowing downstream components to query this information.
@experimental
class RenderContext {
  Canvas get canvas => _canvas!;
  Canvas? _canvas;

  @protected
  final List<CanvasOperation> operations = [];

  void startPipeline(Canvas canvas) {
    _canvas = canvas;
    operations.clear();
  }

  void finishPipeline() {
    _canvas = null;
  }

  void transformCanvas(Matrix4 transform) {
    operations.add(CanvasTransform(transform));
    canvas.save();
    canvas.transform(transform.storage);
  }

  void translateCanvas(double dx, double dy) {
    operations.add(CanvasTranslation(dx, dy));
    canvas.save();
    canvas.translate(dx, dy);
  }

  void restore() {
    operations.removeLast();
    canvas.restore();
  }
}

class CanvasOperation {}

class CanvasTransform extends CanvasOperation {
  CanvasTransform(this.matrix);
  final Matrix4 matrix;
}

class CanvasTranslation extends CanvasOperation {
  CanvasTranslation(this.dx, this.dy);
  final double dx, dy;
}
