import 'package:flame_3d/game.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;

class Transform3D extends ChangeNotifier {
  late final Matrix4 _transformMatrix;
  bool _recalculate;
  final NotifyingQuaternion _rotation;
  final NotifyingVector3 _position;
  final NotifyingVector3 _scale;

  Transform3D()
      : _recalculate = true,
        _rotation = NotifyingQuaternion(0, 0, 0, 0),
        _position = NotifyingVector3.zero(),
        _scale = NotifyingVector3.all(1) {
    _transformMatrix = Matrix4.compose(_position, _rotation, _scale);
    _position.addListener(_markAsModified);
    _scale.addListener(_markAsModified);
    _rotation.addListener(_markAsModified);
  }

  factory Transform3D.copy(Transform3D other) => Transform3D()
    ..rotation = other.rotation
    ..position = other.position
    ..scale = other.scale;

  factory Transform3D.fromMatrix4(Matrix4 matrix) {
    final transform = Transform3D();
    matrix.decompose(transform.position, transform.rotation, transform.scale);
    return transform;
  }

  /// Clone of this.
  Transform3D clone() => Transform3D.copy(this);

  /// Set this to the values of the [other] [Transform3D].
  void setFrom(Transform3D other) {
    rotation = other.rotation;
    position = other.position;
    scale = other.scale;
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
        (rotation.y - other.position.y).abs() <= tolerance &&
        (position.y - other.position.y).abs() <= tolerance &&
        (position.y - other.position.y).abs() <= tolerance &&
        (position.y - other.position.y).abs() <= tolerance &&
        (scale.x - other.scale.x).abs() <= tolerance &&
        (scale.y - other.scale.y).abs() <= tolerance;
  }

  /// The translation part of the transform. This translation is applied
  /// relative to the global coordinate space.
  ///
  /// The returned vector can be modified by the user, and the changes
  /// will be propagated back to the transform matrix.
  NotifyingVector3 get position => _position;
  set position(Vector3 position) => _position.setFrom(position);

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

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation, reflection and scale transforms into a single
  /// entity. The matrix is cached and gets recalculated only as necessary.
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

  void _markAsModified() {
    _recalculate = true;
    notifyListeners();
  }
}
