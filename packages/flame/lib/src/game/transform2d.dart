
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';
import 'notifying_vector2.dart';

/// This class describes a generic 2D transform, which is a combination of
/// translations, rotations and scaling. These transforms are combined into
/// a single matrix, that can be either applied to a canvas, or used directly
/// to compute coordinate transforms.
///
/// The transform can be visualized as 2 reference frames: a "global" and
/// a "local". Originally, the two reference frames coincide. Then, the
/// following sequence of transforms are applied:
///   - translation to point [position];
///   - rotation by [angle] radians clockwise;
///   - scaling in X and Y directions by [scale] factors;
///   - final translation by [offset], in local coordinates.
///
/// The class is optimized for repeated use: the transform matrix is cached
/// and then recalculated only when the underlying properties change. Moreover,
/// recalculation of the transform is postponed until the matrix is actually
/// requested by the user. Thus, modifying multiple properties at once does
/// not incur the penalty of unnecessary recalculations.
///
/// This class implements the [ChangeNotifier] API, allowing you to subscribe
/// for notifications whenever the transform matrix changes. In addition, you
/// can subscribe to get notified when individual components of the transform
/// change: [position], [scale], and [offset] (but not [angle]).
///
class Transform2D extends ChangeNotifier {
  final Matrix4 _transformMatrix;
  bool _recalculate;
  double _angle;
  final NotifyingVector2 _position;
  final NotifyingVector2 _scale;
  final NotifyingVector2 _offset;

  Transform2D()
      : _transformMatrix = Matrix4.identity(),
        _recalculate = true,
        _angle = 0,
        _position = NotifyingVector2(),
        _scale = NotifyingVector2()..setValues(1, 1),
        _offset = NotifyingVector2() {
    _position.addListener(_notify);
    _scale.addListener(_notify);
    _offset.addListener(_notify);
  }

  factory Transform2D.copy(Transform2D other) => Transform2D()
    ..angle = other.angle
    ..position = other.position
    ..scale = other.scale
    ..offset = other.offset;

  /// Check whether this transform is equal to other, up to the given
  /// [tolerance]. Setting tolerance to zero will check for exact equality.
  /// Transforms are considered equal if their rotation angles are the same
  /// or differ by a multiple of 2π, and if all other transform parameters:
  /// translation, scale, and offset are the same.
  ///
  /// The [tolerance] parameter is in absolute units, not relative.
  bool closeTo(Transform2D other, {double tolerance = 1e-10}) {
    const tau = 2 * math.pi;
    final deltaAngle = (angle - other.angle) % tau;
    assert(deltaAngle >= 0);
    return (deltaAngle <= tolerance || deltaAngle >= tau - tolerance) &&
        (position.x - other.position.x).abs() <= tolerance &&
        (position.y - other.position.y).abs() <= tolerance &&
        (scale.x - other.scale.x).abs() <= tolerance &&
        (scale.y - other.scale.y).abs() <= tolerance &&
        (offset.x - other.offset.x).abs() <= tolerance &&
        (offset.y - other.offset.y).abs() <= tolerance;
  }

  /// The translation part of the transform. This translation is applied
  /// relative to the global coordinate space.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be properly applied to the transform matrix.
  NotifyingVector2 get position => _position;
  set position(Vector2 position) => _position.setFrom(position);

  /// X coordinate of the translation transform.
  double get x => _position.x;
  set x(double x) => _position.x = x;

  /// Y coordinate of the translation transform.
  double get y => _position.y;
  set y(double y) => _position.y = y;

  /// The rotation part of the transform. This represents rotation around
  /// the [position] point in clockwise direction by [angle] radians. If
  /// the angle is negative then the rotation is counterclockwise.
  double get angle => _angle;
  set angle(double a) {
    _angle = a;
    _notify();
  }

  /// The scale part of the transform. The default scale factor is (1, 1),
  /// a scale greater than 1 corresponds to expansion, and less than 1 is
  /// contraction. A negative scale is also allowed, and it corresponds
  /// to a mirror reflection around the corresponding axis.
  /// Scale factors can be different for X and Y directions.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be properly applied to the transform matrix.
  NotifyingVector2 get scale => _scale;
  set scale(Vector2 scale) => _scale.setFrom(scale);

  /// Additional offset applied after all other transforms. Unlike other
  /// transforms, this offset is applied in the local coordinate system.
  /// For example, an [offset] of (1, 0) describes a shift by 1 unit along
  /// the X axis, but after that axis was repositioned, rotated and scaled.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be properly applied to the transform matrix.
  NotifyingVector2 get offset => _offset;
  set offset(Vector2 offset) => _offset.setFrom(offset);

  /// Flip the coordinate system horizontally.
  void flipHorizontally() {
    _scale.x = -_scale.x;
  }

  /// Flip the coordinate system vertically.
  void flipVertically() {
    _scale.y = -_scale.y;
  }

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation, reflection and scale transforms into a single
  /// entity. The matrix is cached and gets recalculated only as necessary.
  ///
  /// The returned matrix must not be modified by the user.
  Matrix4 get transformMatrix {
    if (_recalculate) {
      // The transforms below are equivalent to:
      //   _transformMatrix = Matrix4.identity()
      //       .. translate(_position.x, _position.y)
      //       .. rotateZ(_angle)
      //       .. scale(_scale.x, _scale.y, 1)
      //       .. translate(_offset.x, _offset.y);
      final m = _transformMatrix.storage;
      final cosA = math.cos(_angle);
      final sinA = math.sin(_angle);
      m[0] = cosA * _scale.x;
      m[1] = sinA * _scale.x;
      m[4] = -sinA * _scale.y;
      m[5] = cosA * _scale.y;
      m[12] = _position.x + m[0] * _offset.x + m[4] * _offset.y;
      m[13] = _position.y + m[1] * _offset.x + m[5] * _offset.y;
      _recalculate = false;
    }
    return _transformMatrix;
  }

  /// Transform [point] from local coordinates into the parent coordinate space.
  /// Effectively, this function applies the current transform to [point].
  Vector2 localToGlobal(Vector2 point) {
    final m = transformMatrix.storage;
    return Vector2(
      m[0] * point.x + m[4] * point.y + m[12],
      m[1] * point.x + m[5] * point.y + m[13],
    );
  }

  /// Transform [point] from the global coordinate space into the local
  /// coordinates.
  /// Thus, this method performs the inverse of the current transform.
  Vector2 globalToLocal(Vector2 point) {
    // Here we rely on the fact that in the transform matrix only elements
    // `m[0]`, `m[1]`, `m[4]`, `m[5]`, `m[12]`, and `m[13]` are modified.
    // This greatly simplifies computation of the inverse matrix.
    final m = transformMatrix.storage;
    final det = m[0] * m[5] - m[1] * m[4];
    return Vector2(
      ((point.x - m[12]) * m[5] - (point.y - m[13]) * m[4]) / det,
      ((point.y - m[13]) * m[0] - (point.x - m[12]) * m[1]) / det,
    );
  }

  void _notify() {
    _recalculate = true;
    notifyListeners();
  }
}
