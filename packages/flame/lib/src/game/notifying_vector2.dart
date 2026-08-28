import 'package:flame/src/game/simple_change_notifier.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

/// Extension of the standard [Vector2] class, implementing the [Listenable]
/// functionality. This allows any interested party to be notified when the
/// value of this vector changes.
///
/// This class can be used as a regular [Vector2] class. However, if you do
/// subscribe to notifications, don't forget to eventually unsubscribe in
/// order to avoid resource leaks.
///
/// Listeners are dispatched through [SimpleChangeNotifier], which is tuned
/// for the common case of a single listener (for example the transform that
/// owns the vector) being notified many times per frame. Note that an
/// exception thrown by a listener propagates to the caller of the mutating
/// method instead of being reported and swallowed like a [ChangeNotifier]
/// would do.
///
/// Direct modification of this vector's [storage] is not allowed.
class NotifyingVector2 extends Vector2 with SimpleChangeNotifier {
  factory NotifyingVector2(double x, double y) =>
      NotifyingVector2.zero()..setValues(x, y);

  NotifyingVector2.zero() : super.zero();

  factory NotifyingVector2.all(double v) => NotifyingVector2.zero()..splat(v);

  factory NotifyingVector2.copy(Vector2 v) =>
      NotifyingVector2.zero()..setFrom(v);

  Float32List? _unmodifiableStorage;
  int _version = 0;

  /// A counter that is incremented every time this vector is modified.
  ///
  /// Comparing the version against a previously seen value is a cheap way to
  /// detect changes without registering a listener, which is what
  /// [Transform2D] does to know when its cached matrix must be recalculated.
  int get version => _version;

  void _changed() {
    _version++;
    notifyListeners();
  }

  @override
  void setValues(double x_, double y_) {
    super.setValues(x_, y_);
    _changed();
  }

  @override
  void setFrom(Vector2 other) {
    super.setFrom(other);
    _changed();
  }

  @override
  void setZero() {
    super.setZero();
    _changed();
  }

  @override
  void splat(double arg) {
    super.splat(arg);
    _changed();
  }

  @override
  void operator []=(int i, double v) {
    super[i] = v;
    _changed();
  }

  @override
  set length(double l) {
    super.length = l;
    _changed();
  }

  @override
  double normalize() {
    final l = super.normalize();
    _changed();
    return l;
  }

  @override
  void postmultiply(Matrix2 arg) {
    super.postmultiply(arg);
    _changed();
  }

  @override
  void add(Vector2 arg) {
    super.add(arg);
    _changed();
  }

  @override
  void addScaled(Vector2 arg, double factor) {
    super.addScaled(arg, factor);
    _changed();
  }

  @override
  void sub(Vector2 arg) {
    super.sub(arg);
    _changed();
  }

  @override
  void multiply(Vector2 arg) {
    super.multiply(arg);
    _changed();
  }

  @override
  void divide(Vector2 arg) {
    super.divide(arg);
    _changed();
  }

  @override
  void scale(double arg) {
    super.scale(arg);
    _changed();
  }

  @override
  void negate() {
    super.negate();
    _changed();
  }

  @override
  void absolute() {
    super.absolute();
    _changed();
  }

  @override
  void clamp(Vector2 min, Vector2 max) {
    super.clamp(min, max);
    _changed();
  }

  @override
  void clampScalar(double min, double max) {
    super.clampScalar(min, max);
    _changed();
  }

  @override
  void floor() {
    super.floor();
    _changed();
  }

  @override
  void ceil() {
    super.ceil();
    _changed();
  }

  @override
  void round() {
    super.round();
    _changed();
  }

  @override
  void roundToZero() {
    super.roundToZero();
    _changed();
  }

  @override
  void copyFromArray(List<double> array, [int offset = 0]) {
    super.copyFromArray(array, offset);
    _changed();
  }

  @override
  set xy(Vector2 arg) {
    super.xy = arg;
    _changed();
  }

  @override
  set yx(Vector2 arg) {
    super.yx = arg;
    _changed();
  }

  @override
  set x(double x) {
    super.x = x;
    _changed();
  }

  @override
  set y(double y) {
    super.y = y;
    _changed();
  }

  /// A read-only view of the underlying storage. The view is created once
  /// and reused, and it always reflects the current values of the vector.
  @override
  Float32List get storage =>
      _unmodifiableStorage ??= super.storage.asUnmodifiableView();
}
