import 'package:flame_3d/game.dart';
import 'package:flutter/foundation.dart';

/// {@template notifying_vector_3}
/// Extension of the standard [Vector3] class, implementing the [ChangeNotifier]
/// functionality. This allows any interested party to be notified when the
/// value of this vector changes.
///
/// This class can be used as a regular [Vector3] class. However, if you do
/// subscribe to notifications, don't forget to eventually unsubscribe in
/// order to avoid resource leaks.
///
/// Direct modification of this vector's [storage] is not allowed.
///
/// Every method of this vector that changes its value notifies. Functions
/// that write into a vector passed to them as an output argument, such as
/// `Matrix4.transform3`, `Vector3.crossInto` or `Matrix4.decompose`, bypass
/// the notification; set the value through this vector's own methods instead.
/// {@endtemplate}
class NotifyingVector3.zero() extends Vector3 with ChangeNotifier {
  /// {@macro notifying_vector_3}
  ///
  /// Constructs a vector using the raw values [x], [y], and [z].
  factory NotifyingVector3(double x, double y, double z) =>
      NotifyingVector3.zero()..setValues(x, y, z);

  /// {@macro notifying_vector_3}
  ///
  /// Create an empty vector.
  this : super.zero();

  /// {@macro notifying_vector_3}
  ///
  /// Create an vector whose values are all [v].
  factory NotifyingVector3.all(double v) => NotifyingVector3.zero()..splat(v);

  /// {@macro notifying_vector_3}
  ///
  /// Create a copy of the [other] vector.
  factory NotifyingVector3.copy(Vector3 other) =>
      NotifyingVector3.zero()..setFrom(other);

  @override
  void setValues(double x, double y, double z) {
    super.setValues(x, y, z);
    notifyListeners();
  }

  @override
  void setFrom(Vector3 other) {
    super.setFrom(other);
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
  void postmultiply(Matrix3 arg) {
    super.postmultiply(arg);
    notifyListeners();
  }

  @override
  void reflect(Vector3 normal) {
    super.reflect(normal);
    notifyListeners();
  }

  @override
  void applyProjection(Matrix4 arg) {
    super.applyProjection(arg);
    notifyListeners();
  }

  // Vector3.applyAxisAngle delegates to applyQuaternion, which notifies.
  @override
  void applyQuaternion(Quaternion arg) {
    super.applyQuaternion(arg);
    notifyListeners();
  }

  @override
  void applyMatrix3(Matrix3 arg) {
    super.applyMatrix3(arg);
    notifyListeners();
  }

  @override
  void applyMatrix4(Matrix4 arg) {
    super.applyMatrix4(arg);
    notifyListeners();
  }

  @override
  void add(Vector3 arg) {
    super.add(arg);
    notifyListeners();
  }

  @override
  void addScaled(Vector3 arg, double factor) {
    super.addScaled(arg, factor);
    notifyListeners();
  }

  @override
  void sub(Vector3 arg) {
    super.sub(arg);
    notifyListeners();
  }

  @override
  void multiply(Vector3 arg) {
    super.multiply(arg);
    notifyListeners();
  }

  @override
  void divide(Vector3 arg) {
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
  void clamp(Vector3 min, Vector3 max) {
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
  set xz(Vector2 arg) {
    super.xz = arg;
    notifyListeners();
  }

  @override
  set yx(Vector2 arg) {
    super.yx = arg;
    notifyListeners();
  }

  @override
  set yz(Vector2 arg) {
    super.yz = arg;
    notifyListeners();
  }

  @override
  set zx(Vector2 arg) {
    super.zx = arg;
    notifyListeners();
  }

  @override
  set zy(Vector2 arg) {
    super.zy = arg;
    notifyListeners();
  }

  @override
  set xyz(Vector3 arg) {
    super.xyz = arg;
    notifyListeners();
  }

  @override
  set xzy(Vector3 arg) {
    super.xzy = arg;
    notifyListeners();
  }

  @override
  set yxz(Vector3 arg) {
    super.yxz = arg;
    notifyListeners();
  }

  @override
  set yzx(Vector3 arg) {
    super.yzx = arg;
    notifyListeners();
  }

  @override
  set zxy(Vector3 arg) {
    super.zxy = arg;
    notifyListeners();
  }

  @override
  set zyx(Vector3 arg) {
    super.zyx = arg;
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
  set z(double z) {
    super.z = z;
    notifyListeners();
  }

  @override
  Float32List get storage => _unmodifiableStorage;
  late final Float32List _unmodifiableStorage = super.storage
      .asUnmodifiableView();
}
