import 'vector2.dart';

import 'dart:ui';

export 'dart:ui' show Canvas;

extension CanvasExtension on Canvas {
  void scaleVector(Vector2 vector) {
    scale(vector.x, vector.y);
  }

  void translateVector(Vector2 vector) {
    translate(vector.x, vector.y);
  }
}
