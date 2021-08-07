import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import 'notifying_vector2.dart';

class Transform2D extends ChangeNotifier {
  /// The matrix that combines all the transforms into a single entity.
  /// This matrix is cached and automatically recalculated when the position/
  /// rotation/scale of the component changes.
  final Matrix4 _transformMatrix;

  /// This variable keeps track whether the transform matrix is "dirty" and
  /// needs to be recalculated. It ensures that if the user updates multiple
  /// properties at once, such as [x], [y] and [angle], then the transform
  /// matrix will be recalculated only once, usually during the rendering stage.
  bool _recalculate;
  bool get isDirty => _recalculate;

  /// The position of this component's anchor on the screen.
  final NotifyingVector2 _position;
  NotifyingVector2 get position => _position;
  set position(Vector2 position) => _position.setFrom(position);

  /// X position of this component's anchor on the screen.
  double get x => _position.x;
  set x(double x) {
    _position.x = x;
    _recalculate = true;
  }

  /// Y position of this component's anchor on the screen.
  double get y => _position.y;
  set y(double y) {
    _position.y = y;
    _recalculate = true;
  }

  /// Rotation angle (in radians) of the component. The component will be
  /// rotated around its anchor point in the clockwise direction if the
  /// angle is positive, or counterclockwise if the angle is negative.
  double _angle;
  double get angle => _angle;
  set angle(double a) {
    _angle = a;
    _recalculate = true;
  }

  /// The scale factor of this component
  final NotifyingVector2 _scale;
  NotifyingVector2 get scale => _scale;
  set scale(Vector2 scale) => _scale.setFrom(scale);

  /// Additional offset applied after all other transforms
  final NotifyingVector2 _offset;
  NotifyingVector2 get offset => _offset;
  set offset(Vector2 offset) => _offset.setFrom(offset);

  Transform2D()
      : _transformMatrix = Matrix4.identity(),
        _recalculate = true,
        _position = NotifyingVector2(),
        _angle = 0,
        _scale = NotifyingVector2()..setValues(1, 1),
        _offset = NotifyingVector2() {
    _position.addListener(_notify);
    _scale.addListener(_notify);
    _offset.addListener(_notify);
  }

  /// Flip the component horizontally around its anchor point.
  void flipHorizontally() {
    _scale.x = -_scale.x;
  }

  /// Flip the component vertically around its anchor point.
  void flipVertically() {
    _scale.y = -_scale.y;
  }

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
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

  /// Transform `point` from local coordinates into the parent coordinate space.
  Vector2 localToGlobal(Vector2 point) {
    final m = transformMatrix.storage;
    return Vector2(
      m[0] * point.x + m[4] * point.y + m[12],
      m[1] * point.x + m[5] * point.y + m[13],
    );
  }

  /// Transform `point` from the parent's coordinate space into the local
  /// coordinates.
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
