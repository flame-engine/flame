import 'dart:math' as math;

import 'package:flame/geometry.dart' as geometry;
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

/// This class describes a generic 2D transform, which is a combination of
/// translations, rotations, reflections and scaling. These transforms are
/// combined into a single matrix, that can be either applied to a canvas,
/// composed with another transform, or used directly to convert coordinates.
///
/// The transform can be visualized as 2 reference frames: a "global" and
/// a "local". At first, these two reference frames coincide. Then, the
/// following sequence of transforms is applied:
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
class Transform2D extends ChangeNotifier {
  final Matrix4 _transformMatrix;
  bool _recalculate;
  bool _recalculateRotation;
  bool _isBatchUpdating = false;
  double _angle;
  double _cosAngle;
  double _sinAngle;
  final NotifyingVector2 _position;
  final NotifyingVector2 _scale;
  final NotifyingVector2 _offset;

  Transform2D()
    : _transformMatrix = Matrix4.identity(),
      _recalculate = true,
      _recalculateRotation = false,
      _angle = 0,
      _cosAngle = 1,
      _sinAngle = 0,
      _position = NotifyingVector2.zero(),
      _scale = NotifyingVector2.all(1),
      _offset = NotifyingVector2.zero() {
    _position.addListener(_markAsModified);
    _scale.addListener(_markAsModified);
    _offset.addListener(_markAsModified);
  }

  factory Transform2D.copy(Transform2D other) => Transform2D()..setFrom(other);

  /// Clone of this.
  Transform2D clone() => Transform2D.copy(this);

  /// Set this to the values of the [other] [Transform2D].
  void setFrom(Transform2D other) {
    _isBatchUpdating = true;
    _angle = other._angle;
    _cosAngle = other._cosAngle;
    _sinAngle = other._sinAngle;
    _recalculateRotation = other._recalculateRotation;
    _position.setFrom(other._position);
    _scale.setFrom(other._scale);
    _offset.setFrom(other._offset);
    _isBatchUpdating = false;
    _recalculate = true;
    notifyListeners();
  }

  /// Check whether this transform is equal to [other], up to the given
  /// [tolerance]. Setting tolerance to zero will check for exact equality.
  /// Transforms are considered equal if their rotation angles are the same
  /// or differ by a multiple of 2π, and if all other transform parameters:
  /// translation, scale, and offset are the same.
  ///
  /// The [tolerance] parameter is in absolute units, not relative.
  bool closeTo(Transform2D other, {double tolerance = 1e-10}) {
    final deltaAngle = (_angle - other._angle) % geometry.tau;
    assert(deltaAngle >= 0);
    return (deltaAngle <= tolerance ||
            deltaAngle >= geometry.tau - tolerance) &&
        (_position.x - other._position.x).abs() <= tolerance &&
        (_position.y - other._position.y).abs() <= tolerance &&
        (_scale.x - other._scale.x).abs() <= tolerance &&
        (_scale.y - other._scale.y).abs() <= tolerance &&
        (_offset.x - other._offset.x).abs() <= tolerance &&
        (_offset.y - other._offset.y).abs() <= tolerance;
  }

  /// The translation part of the transform. This translation is applied
  /// relative to the global coordinate space.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be propagated back to the transform matrix.
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
    _recalculateRotation = true;
    _markAsModified();
  }

  /// Similar to [angle], but uses degrees instead of radians.
  double get angleDegrees => _angle * (360 / geometry.tau);
  set angleDegrees(double a) => angle = a * (geometry.tau / 360);

  /// The scale part of the transform. The default scale factor is (1, 1),
  /// a scale greater than 1 corresponds to expansion, and less than 1 is
  /// contraction. A negative scale is also allowed, and it corresponds
  /// to a mirror reflection around the corresponding axis.
  /// Scale factors can be different for X and Y directions.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be propagated back to the transform matrix.
  NotifyingVector2 get scale => _scale;
  set scale(Vector2 scale) => _scale.setFrom(scale);

  /// Additional offset applied after all other transforms. Unlike other
  /// transforms, this offset is applied in the local coordinate system.
  /// For example, an [offset] of (1, 0) describes a shift by 1 unit along
  /// the X axis, however, this shift is applied after that axis was
  /// repositioned, rotated and scaled.
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
      if (_recalculateRotation) {
        _cosAngle = math.cos(_angle);
        _sinAngle = math.sin(_angle);
        _recalculateRotation = false;
      }
      final cosA = _cosAngle;
      final sinA = _sinAngle;
      final scaleX = _scale.x;
      final scaleY = _scale.y;
      final offsetX = _offset.x;
      final offsetY = _offset.y;
      final m = _transformMatrix.storage;
      m[0] = cosA * scaleX;
      m[1] = sinA * scaleX;
      m[4] = -sinA * scaleY;
      m[5] = cosA * scaleY;
      m[12] = _position.x + m[0] * offsetX + m[4] * offsetY;
      m[13] = _position.y + m[1] * offsetX + m[5] * offsetY;
      _recalculate = false;
    }
    return _transformMatrix;
  }

  set transformMatrix(Matrix4 value) {
    assert(
      value.storage[2] == 0 &&
          value.storage[3] == 0 &&
          value.storage[6] == 0 &&
          value.storage[7] == 0 &&
          value.storage[8] == 0 &&
          value.storage[9] == 0 &&
          value.storage[10] == 1 &&
          value.storage[11] == 0 &&
          value.storage[14] == 0 &&
          value.storage[15] == 1,
      'The provided matrix is not a valid 2D transformation',
    );
    final m = _transformMatrix.storage;
    m.setAll(0, value.storage);

    final m0 = m[0];
    final m1 = m[1];
    final m4 = m[4];
    final m5 = m[5];
    final double scaleX;
    final double scaleY;
    final double angle;
    final scaleXSquared = m0 * m0 + m1 * m1;
    if (scaleXSquared == 0) {
      scaleX = 0;
      scaleY = math.sqrt(m4 * m4 + m5 * m5);
      angle = math.atan2(-m4, m5);
    } else {
      scaleX = math.sqrt(scaleXSquared);
      scaleY = (m0 * m5 - m1 * m4) / scaleX;
      angle = math.atan2(m1, m0);
    }
    final offsetX = _offset.x;
    final offsetY = _offset.y;

    _isBatchUpdating = true;
    _angle = angle;
    _recalculateRotation = true;
    _scale.setValues(scaleX, scaleY);
    _position.setValues(
      m[12] - (m0 * offsetX + m4 * offsetY),
      m[13] - (m1 * offsetX + m5 * offsetY),
    );
    _isBatchUpdating = false;
    _recalculate = false;
    notifyListeners();
  }

  /// Transform [point] from local coordinates into the parent coordinate space.
  /// Effectively, this function applies the current transform to [point].
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final m = transformMatrix.storage;
    final px = point.x;
    final py = point.y;
    final x = m[0] * px + m[4] * py + m[12];
    final y = m[1] * px + m[5] * py + m[13];
    return (output?..setValues(x, y)) ?? Vector2(x, y);
  }

  /// Transform [point] from the global coordinate space into the local
  /// coordinates. Thus, this method performs the inverse of the current
  /// transform.
  ///
  /// If the current transform is degenerate due to one of the scale
  /// factors being 0, then this method will return a zero vector.
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    // Here we rely on the fact that in the transform matrix only elements
    // `m[0]`, `m[1]`, `m[4]`, `m[5]`, `m[12]`, and `m[13]` are modified.
    // This greatly simplifies computation of the inverse matrix.
    final m = transformMatrix.storage;
    final m0 = m[0];
    final m1 = m[1];
    final m4 = m[4];
    final m5 = m[5];
    var det = m0 * m5 - m1 * m4;
    if (det != 0) {
      det = 1 / det;
    }
    final dx = point.x - m[12];
    final dy = point.y - m[13];
    final x = (dx * m5 - dy * m4) * det;
    final y = (dy * m0 - dx * m1) * det;
    return (output?..setValues(x, y)) ?? Vector2(x, y);
  }

  /// Whether the transform represents a pure translation, i.e. a transform of
  /// the form `(x, y) -> (x + Δx, y + Δy)`.
  bool get isTranslation {
    return _angle == 0 && _scale.x == 1 && _scale.y == 1;
  }

  /// Whether the transform keeps horizontal (vertical) lines as horizontal
  /// (vertical).
  bool get isAxisAligned => _angle == 0;

  /// Whether the transform preserves angles. A conformal transformation may
  /// consist of a translation, rotation, and uniform scaling. A reflection is
  /// not considered conformal.
  bool get isConformal => _scale.x == _scale.y;

  /// Whether the transform includes a reflection, i.e. it flips the orientation
  /// of the coordinate system.
  bool get hasReflection => _scale.x * _scale.y < 0;

  void _markAsModified() {
    _recalculate = true;
    if (!_isBatchUpdating) {
      notifyListeners();
    }
  }
}
