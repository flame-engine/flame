import 'dart:typed_data' show Float32List;
import 'dart:ui';

import 'package:flame/palette.dart';
import 'package:flame/src/cache/matrix_pool.dart' show canvasTransform;
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/transform2d.dart';

export 'dart:ui' show Canvas;

extension CanvasExtension on Canvas {
  void scaleVector(Vector2 vector) {
    scale(vector.x, vector.y);
  }

  void translateVector(Vector2 vector) {
    translate(vector.x, vector.y);
  }

  /// Renders a point as a square of size [size] (default 1 logical pixel) using
  /// the provided [paint] (default solid magenta).
  ///
  /// This is mostly useful for debugging.
  void renderPoint(
    Vector2 point, {
    double size = 1.0,
    Paint? paint,
  }) {
    final rect = (point - Vector2.all(size / 2)) & Vector2.all(size);
    drawRect(rect, paint ?? BasicPalette.magenta.paint());
  }

  /// Renders a line between [p1] and [p2] using the provided [paint].
  ///
  /// Equivalent to [drawLine] but using [Vector2] instead of [Offset].
  void renderLine(Vector2 p1, Vector2 p2, Paint paint) {
    drawLine(p1.toOffset(), p2.toOffset(), paint);
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
    translateVector(rotationCenter);
    rotate(angle);
    translateVector(-rotationCenter);
    fn(this);
    restore();
  }

  /// Use the [Transform2D] object to [transform] the canvas.
  void transform2D(Transform2D transform2D) {
    transform32(transform2D.transformMatrix.storage);
  }

  void transform32(Float32List matrix4) {
    canvasTransform(this, matrix4);
  }
}
