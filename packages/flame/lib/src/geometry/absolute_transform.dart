import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// The 2D affine transform from the local coordinates of a [PositionComponent]
/// to the global coordinates, composed from the transforms of the component and
/// all of its ancestors.
///
/// A point maps to `(a * x + c * y + tx, b * x + d * y + ty)`.
@internal
class AbsoluteTransform {
  double _a = 1;
  double _b = 0;
  double _c = 0;
  double _d = 1;
  double _tx = 0;
  double _ty = 0;

  /// Whether the transform mirrors the shapes that it is applied to, which
  /// flips the winding order of their vertices.
  bool get isMirrored => _a * _d - _b * _c < 0;

  /// Composes the transform of [component] by walking its ancestors once, and
  /// returns whether the transform differs from the last one that was composed.
  bool update(PositionComponent component) {
    final own = component.transform.transformMatrix.storage;
    var a = own[0];
    var b = own[1];
    var c = own[4];
    var d = own[5];
    var tx = own[12];
    var ty = own[13];
    var ancestor = component.parent;
    while (ancestor != null) {
      if (ancestor is PositionComponent) {
        final outer = ancestor.transform.transformMatrix.storage;
        final outerA = outer[0];
        final outerB = outer[1];
        final outerC = outer[4];
        final outerD = outer[5];
        final newA = outerA * a + outerC * b;
        final newB = outerB * a + outerD * b;
        final newC = outerA * c + outerC * d;
        final newD = outerB * c + outerD * d;
        final newTx = outerA * tx + outerC * ty + outer[12];
        final newTy = outerB * tx + outerD * ty + outer[13];
        a = newA;
        b = newB;
        c = newC;
        d = newD;
        tx = newTx;
        ty = newTy;
      }
      ancestor = ancestor.parent;
    }
    final hasChanged =
        a != _a || b != _b || c != _c || d != _d || tx != _tx || ty != _ty;
    _a = a;
    _b = b;
    _c = c;
    _d = d;
    _tx = tx;
    _ty = ty;
    return hasChanged;
  }

  /// Transforms the local [point] to global coordinates and stores the result
  /// in [output].
  void apply(Vector2 point, {required Vector2 output}) {
    final x = point.x;
    final y = point.y;
    output.setValues(_a * x + _c * y + _tx, _b * x + _d * y + _ty);
  }
}
