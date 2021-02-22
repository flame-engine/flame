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

  /// Utility method to render stuff on a specific place in an isolated way.
  ///
  /// Some render methods don't allow to pass a vector.
  /// This method translate the canvas before rendering your fn.
  /// The changes are reset after the fn is run.
  void renderAt(Vector2 p, void Function(Canvas) fn) {
    save();
    translateVector(p);
    fn(this);
    restore();
  }

  /// Utility method to render stuff rotated at specific angle.
  ///
  /// It rotates the canvas around the center of rotation.
  /// The changes are reset after the fn is run.
  void renderRotated(
    double angle,
    Vector2 rotationCenter,
    void Function(Canvas) fn,
  ) {
    save();
    translateVector(-rotationCenter);
    rotate(angle);
    translateVector(rotationCenter);
    fn(this);
    restore();
  }
}
