import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

/// Extension of the standard [Vector2] class, implementing the [ChangeNotifier]
/// functionality. This allows any interested party to be notified when the
/// value of this vector changes.
///
/// This class can be used as a regular [Vector2] class. However, if you do
/// subscribe to notifications, don't forget to eventually unsubscribe in
/// order to avoid resource leaks.
///
/// Direct modification of this vector's [storage] is not allowed.
class NotifyingVector2 extends Vector2 with ChangeNotifier {
  factory NotifyingVector2(double x, double y) =>
      NotifyingVector2.zero()..setValues(x, y);

  NotifyingVector2.zero() : super.zero();

  factory NotifyingVector2.all(double v) => NotifyingVector2.zero()..splat(v);

  factory NotifyingVector2.copy(Vector2 v) =>
      NotifyingVector2.zero()..setFrom(v);

  @override
  void setValues(double x, double y) {
    super.setValues(x, y);
    notifyListeners();
  }

  @override
  void setFrom(Vector2 v) {
    super.setFrom(v);
    notifyListeners();
  }

  @override
  void setZero() {
    super.setZero();
    notifyListeners();
  }

  @override
  void splat(double arg) {
    super.splat(arg);
    notifyListeners();
  }

  @override
  void operator []=(int i, double v) {
    super[i] = v;
    notifyListeners();
  }

  @override
  set length(double l) {
    super.length = l;
    notifyListeners();
  }

  @override
  double normalize() {
    final l = super.normalize();
    notifyListeners();
    return l;
  }

  @override
  void postmultiply(Matrix2 arg) {
    super.postmultiply(arg);
    notifyListeners();
  }

  @override
  void add(Vector2 arg) {
    super.add(arg);
    notifyListeners();
  }

  @override
  void addScaled(Vector2 arg, double factor) {
    super.addScaled(arg, factor);
    notifyListeners();
  }

  @override
  void sub(Vector2 arg) {
    super.sub(arg);
    notifyListeners();
  }

  @override
  void multiply(Vector2 arg) {
    super.multiply(arg);
    notifyListeners();
  }

  @override
  void divide(Vector2 arg) {
    super.divide(arg);
    notifyListeners();
  }

  @override
  void scale(double arg) {
    super.scale(arg);
    notifyListeners();
  }

  @override
  void negate() {
    super.negate();
    notifyListeners();
  }

  @override
  void absolute() {
    super.absolute();
    notifyListeners();
  }

  @override
  void clamp(Vector2 min, Vector2 max) {
    super.clamp(min, max);
    notifyListeners();
  }

  @override
  void clampScalar(double min, double max) {
    super.clampScalar(min, max);
    notifyListeners();
  }

  @override
  void floor() {
    super.floor();
    notifyListeners();
  }

  @override
  void ceil() {
    super.ceil();
    notifyListeners();
  }

  @override
  void round() {
    super.round();
    notifyListeners();
  }

  @override
  void roundToZero() {
    super.roundToZero();
    notifyListeners();
  }

  @override
  void copyFromArray(List<double> array, [int offset = 0]) {
    super.copyFromArray(array, offset);
    notifyListeners();
  }

  @override
  set xy(Vector2 arg) {
    super.xy = arg;
    notifyListeners();
  }

  @override
  set yx(Vector2 arg) {
    super.yx = arg;
    notifyListeners();
  }

  @override
  set x(double x) {
    super.x = x;
    notifyListeners();
  }

  @override
  set y(double y) {
    super.y = y;
    notifyListeners();
  }

  @override
  Float64List get storage => UnmodifiableFloat64ListView(super.storage);
}
