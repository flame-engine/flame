import 'package:flame_3d/game.dart';
import 'package:flutter/foundation.dart';

/// {@template unmodifiable_vector_3}
/// Extension of the standard [Vector3] class, but fully unmodifiable.
///
/// This class can be used as a regular [Vector3] class. However, if you do
/// try to write values the calls will throw.
///
/// Direct modification of this vector's [storage] is not allowed.
/// {@endtemplate}
class UnmodifiableVector3 extends Vector3 {
  /// {@macro unmodifiable_vector_3}
  ///
  /// Constructs a vector using the raw values [x], [y], and [z].
  factory UnmodifiableVector3(double x, double y, double z) =>
      UnmodifiableVector3.zero().._setValues(x, y, z);

  /// {@macro unmodifiable_vector_3}
  ///
  /// Create an empty vector.
  UnmodifiableVector3.zero() : super.zero();

  /// {@macro unmodifiable_vector_3}
  ///
  /// Create an vector whose values are all [v].
  factory UnmodifiableVector3.all(double v) =>
      UnmodifiableVector3.zero().._setValues(v, v, v);

  /// {@macro unmodifiable_vector_3}
  ///
  /// Create a copy of the [other] vector.
  factory UnmodifiableVector3.copy(Vector3 other) =>
      UnmodifiableVector3.zero().._setValues(other.x, other.y, other.z);

  void _setValues(double x, double y, double z) => super.setValues(x, y, z);

  @override
  void setValues(double x, double y, double z) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void setFrom(Vector3 other) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void setZero() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void splat(double arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void operator []=(int i, double v) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set length(double l) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  double normalize() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void postmultiply(Matrix3 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void add(Vector3 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void addScaled(Vector3 arg, double factor) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void sub(Vector3 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void multiply(Vector3 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void divide(Vector3 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void scale(double arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void negate() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void absolute() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void clamp(Vector3 min, Vector3 max) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void clampScalar(double min, double max) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void floor() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void ceil() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void round() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void roundToZero() {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  void copyFromArray(List<double> array, [int offset = 0]) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set xy(Vector2 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set yx(Vector2 arg) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set x(double x) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set y(double y) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  set z(double z) {
    throw UnsupportedError('Cannot modify an unmodifiable Vector3');
  }

  @override
  Float32List get storage => super.storage.asUnmodifiableView();
}

extension UnmodifiableVector3Extension on Vector3 {
  Vector3 asUnmodifiableView() => UnmodifiableVector3(x, y, z);
}
