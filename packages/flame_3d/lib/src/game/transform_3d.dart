import 'package:flame_3d/game.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

/// {@template transform_3d}
/// This class describes a generic 3D transform, which is a combination of
/// translations, rotations and scaling. These transforms are combined into a
/// single matrix, that can be either applied to a graphical device like the
/// canvas, composed with another transform, or used directly to convert
/// coordinates.
///
/// The transform can be visualized as 2 reference frames: a "global" and
/// a "local". At first, these two reference frames coincide. Then, the
/// following sequence of transforms is applied:
///   - translation to point [position];
///   - rotate using the [rotation];
///   - scaling in X, Y and Z directions by [scale] factors.
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
/// change: [position], [scale], and [rotation].
/// {@endtemplate}
class Transform3D extends ChangeNotifier {
  /// {@macro transform_3d}
  Transform3D()
    : _recalculate = true,
      _position = NotifyingVector3.zero(),
      _rotation = NotifyingQuaternion(0, 0, 0, 0),
      _scale = NotifyingVector3.all(1),
      _transformMatrix = Matrix4.zero() {
    _position.addListener(_markAsModified);
    _scale.addListener(_markAsModified);
    _rotation.addListener(_markAsModified);
  }

  /// {@macro transform_3d}
  ///
  /// Create a copy of the [other] transform.
  factory Transform3D.copy(Transform3D other) => Transform3D()..setFrom(other);

  /// {@macro transform_3d}
  ///
  /// Create an instance of [Transform3D] and apply the [matrix] on it.
  factory Transform3D.fromMatrix4(Matrix4 matrix) {
    return Transform3D()..setFromMatrix4(matrix);
  }

  /// Creates a [Transform3D] from the given broken down
  /// parameters and sensible defaults:
  /// - [position] defaults to no translation;
  /// - [rotation] defaults to no rotation;
  /// - [scale] defaults to no scaling.
  factory Transform3D.compose({
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
  }) {
    final matrix = matrix4(
      position: position,
      rotation: rotation,
      scale: scale,
    );
    return Transform3D.fromMatrix4(matrix);
  }

  /// Creates a transform-3d-type [Matrix4] from the given broken down
  /// parameters and sensible defaults:
  /// - [position] defaults to no translation;
  /// - [rotation] defaults to no rotation;
  /// - [scale] defaults to no scaling.
  static Matrix4 matrix4({
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
  }) {
    return Matrix4.compose(
      position ?? Vector3.zero(),
      rotation ?? Quaternion.identity(),
      scale ?? Vector3.all(1),
    );
  }

  /// Clone of this.
  Transform3D clone() => Transform3D.copy(this);

  /// The translation part of the transform. This translation is applied
  /// relative to the global coordinate space.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be propagated back to the transform matrix.
  NotifyingVector3 get position => _position;
  set position(Vector3 position) => _position.setFrom(position);
  final NotifyingVector3 _position;

  /// X coordinate of the translation transform.
  double get x => _position.x;
  set x(double x) => _position.x = x;

  /// Y coordinate of the translation transform.
  double get y => _position.y;
  set y(double y) => _position.y = y;

  /// Z coordinate of the translation transform.
  double get z => _position.z;
  set z(double y) => _position.z = z;

  NotifyingQuaternion get rotation => _rotation;
  set rotation(Quaternion rotation) => _rotation.setFrom(rotation);
  final NotifyingQuaternion _rotation;

  /// The scale part of the transform. The default scale factor is (1, 1, 1),
  /// a scale greater than 1 corresponds to expansion, and less than 1 is
  /// contraction. A negative scale is also allowed, and it corresponds
  /// to a mirror reflection around the corresponding axis.
  /// Scale factors can be different for X, Y and Z directions.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be propagated back to the transform matrix.
  NotifyingVector3 get scale => _scale;
  set scale(Vector3 scale) => _scale.setFrom(scale);
  final NotifyingVector3 _scale;

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only when necessary.
  ///
  /// The returned matrix must not be modified by the user.
  Matrix4 get transformMatrix {
    if (_recalculate) {
      _transformMatrix.setFromTranslationRotationScale(
        _position,
        _rotation,
        _scale,
      );
      _recalculate = false;
    }
    return _transformMatrix;
  }

  final Matrix4 _transformMatrix;
  bool _recalculate;

  /// Set this to the values of the [other] [Transform3D].
  void setFrom(Transform3D other) {
    rotation.setFrom(other.rotation);
    position.setFrom(other.position);
    scale.setFrom(other.scale);
  }

  void setFromMatrix4(Matrix4 matrix) {
    matrix.decompose(position, rotation, scale);
  }

  /// Check whether this transform is equal to [other], up to the given
  /// [tolerance]. Setting tolerance to zero will check for exact equality.
  /// Transforms are considered equal if their rotation angles are the same
  /// or differ by a multiple of 2π, and if all other transform parameters:
  /// translation, scale, and offset are the same.
  ///
  /// The [tolerance] parameter is in absolute units, not relative.
  bool closeTo(Transform3D other, {double tolerance = 1e-10}) {
    return (position.x - other.position.x).abs() <= tolerance &&
        (position.y - other.position.y).abs() <= tolerance &&
        (position.z - other.position.z).abs() <= tolerance &&
        (rotation.x - other.rotation.x).abs() <= tolerance &&
        (rotation.y - other.rotation.y).abs() <= tolerance &&
        (rotation.z - other.rotation.z).abs() <= tolerance &&
        (rotation.w - other.rotation.w).abs() <= tolerance &&
        (scale.x - other.scale.x).abs() <= tolerance &&
        (scale.y - other.scale.y).abs() <= tolerance &&
        (scale.z - other.scale.z).abs() <= tolerance;
  }

  void _markAsModified() {
    _recalculate = true;
    notifyListeners();
  }
}
