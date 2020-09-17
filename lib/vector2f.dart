library flame.vector_math;

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class Vector2F implements Vector2 {
  final Vector2 _delegate;

  /// Construct a new Vector2F with the specified values.
  Vector2F(double x, double y) : _delegate = Vector2(x, y);

  /// Initialized with values from [array] starting at [offset].
  Vector2F.array(List<double> array, [int offset = 0])
      : _delegate = Vector2.array(array, offset);

  /// Zero vector.
  Vector2F.zero() : _delegate = Vector2.zero();

  /// Splat [value] into all lanes of the vector. Vector2F.all(double value) : _delegate = Vector2F.all(value);
  Vector2F.all(double value) : _delegate = Vector2.all(value);

  /// Copy of [other].
  Vector2F.copy(Vector2 other) : _delegate = Vector2.copy(other);

  /// Constructs Vector2F with a given [Float64List] as [storage].
  Vector2F.fromFloat64List(Float64List v2storage)
      : _delegate = Vector2.fromFloat64List(v2storage);

  /// Constructs Vector2F with a [storage] that views given [buffer] starting at
  /// [offset]. [offset] has to be multiple of [Float64List.bytesPerElement].
  Vector2F.fromBuffer(ByteBuffer buffer, int offset)
      : _delegate = Vector2.fromBuffer(buffer, offset);

  /// Generate random vector in the range (0, 0) to (1, 1). You can
  /// optionally pass your own random number generator.
  Vector2F.random([Random rng]) : _delegate = Vector2.random(rng);

  /// Creates a [Vector2F] using an [Offset]
  Vector2F.fromOffset(Offset offset)
      : _delegate = Vector2(offset.dx, offset.dy);

  /// Creates a [Vector2F] using an [Size]
  Vector2F.fromSize(Size size) : _delegate = Vector2(size.width, size.height);

  /// Creates a [Vector2F] using a [Point]
  Vector2F fromPoint(Point point) => Vector2F(point.x, point.y);

  /// ==========================================================================
  /// The following block are all the functions that [Vector2F] has but
  /// [Vector2] doesn't have.
  /// ==========================================================================

  /// Creates an [Offset] from the [Vector2F]
  Offset toOffset() => Offset(_delegate.x, _delegate.y);

  /// Creates an [Size] from the [Vector2F]
  Size toSize() => Size(_delegate.x, _delegate.y);

  /// Creates a [Point] from the [Vector2F]
  Point toPoint() => Point(_delegate.x, _delegate.y);

  /// Creates a [Rect] starting in origo and going the [Vector2F]
  Rect toRect() => Rect.fromLTWH(0, 0, _delegate.x, _delegate.y);

  /// Creates a [Rect] from two [Vector2]
  static Rect rectFrom(Vector2F topLeft, Vector2F size) {
    return Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

  /// Creates bounds in from of a [Rect] from a list of [Vector2]
  static Rect bounds(List<Vector2> pts) {
    final double minx = pts.map((e) => e.x).reduce(min);
    final double maxx = pts.map((e) => e.x).reduce(max);
    final double miny = pts.map((e) => e.y).reduce(min);
    final double maxy = pts.map((e) => e.y).reduce(max);
    return Rect.fromPoints(Offset(minx, miny), Offset(maxx, maxy));
  }

  /// Linearly interpolate towards another Vector2
  void lerp(Vector2 to, double t) {
    _delegate.setFrom(_delegate + (to - _delegate) * t);
  }

  /// Rotates the [Vector2F] with [angle] in radians
  void rotate(double angle) {
    _delegate.setValues(
      _delegate.x * cos(angle) - _delegate.y * sin(angle),
      _delegate.x * sin(angle) + _delegate.y * cos(angle),
    );
  }

  /// Changes the [length] of the vector to the length provided, without changing direction.
  ///
  /// If you try to scale the zero (empty) vector, it will remain unchanged, and no error will be thrown.
  void scaleTo(double newLength) {
    final l = _delegate.length;
    if (l != 0) {
      _delegate.setFrom(_delegate * (newLength.abs() / l));
    }
  }

  /// ==========================================================================
  /// The following are all the Vector2 overridden functions that we have to
  /// delegate to [_delegate], since the constructor factories makes the
  /// [Vector2] class impossible to extend.
  /// ==========================================================================

  @override
  double get g => _delegate.g;

  @override
  Vector2F get gr => _delegate.gr;

  @override
  double get length => _delegate.length;

  @override
  double get r => _delegate.r;

  @override
  Vector2F get rg => _delegate.rg;

  @override
  double get s => _delegate.s;

  @override
  Vector2F get st => _delegate.st;

  @override
  double get t => _delegate.t;

  @override
  Vector2F get ts => _delegate.ts;

  @override
  double get x => _delegate.x;

  @override
  Vector2F get xy => _delegate.xy;

  @override
  double get y => _delegate.y;

  @override
  Vector2F get yx => _delegate.yx;

  @override
  Vector2F operator *(double scale) => _delegate * scale;

  @override
  Vector2F operator +(Vector2 other) => _delegate + other;

  @override
  Vector2F operator -(Vector2 other) => _delegate - other;

  @override
  Vector2F operator -() => -_delegate;

  @override
  Vector2F operator /(double scale) => _delegate / scale;

  @override
  double operator [](int i) => _delegate[i];

  @override
  void operator []=(int i, double v) => _delegate[i] = v;

  @override
  void absolute() => _delegate.absolute();

  @override
  double absoluteError(Vector2 correct) => _delegate.absoluteError(correct);

  @override
  void add(Vector2 arg) => _delegate.add(arg);

  @override
  void addScaled(Vector2 arg, double factor) =>
      _delegate.addScaled(arg, factor);

  @override
  double angleTo(Vector2 other) => _delegate.angleTo(other);

  @override
  double angleToSigned(Vector2 other) => _delegate.angleToSigned(other);

  @override
  void ceil() => _delegate.ceil();

  @override
  void clamp(Vector2 min, Vector2 max) => _delegate.clamp(min, max);

  @override
  void clampScalar(double min, double max) => _delegate.clampScalar(min, max);

  @override
  Vector2F clone() => _delegate.clone();

  @override
  void copyFromArray(List<double> array, [int offset = 0]) =>
      _delegate.copyFromArray(array, offset);

  @override
  Vector2F copyInto(Vector2 arg) => _delegate.copyInto(arg);

  @override
  void copyIntoArray(List<double> array, [int offset = 0]) =>
      _delegate.copyIntoArray(array, offset);

  @override
  double cross(Vector2 other) => _delegate.cross(other);

  @override
  double distanceTo(Vector2 arg) => _delegate.distanceTo(arg);

  @override
  double distanceToSquared(Vector2 arg) => _delegate.distanceToSquared(arg);

  @override
  void divide(Vector2 arg) => _delegate.divide(arg);

  @override
  double dot(Vector2 other) => _delegate.dot(other);

  @override
  void floor() => _delegate.floor();

  @override
  Vector2F get gg => _delegate.gg;

  @override
  Vector3 get ggg => _delegate.ggg;

  @override
  Vector4 get gggg => _delegate.gggg;

  @override
  Vector4 get gggr => _delegate.gggr;

  @override
  Vector3 get ggr => _delegate.ggr;

  @override
  Vector4 get ggrg => _delegate.ggrg;

  @override
  Vector4 get ggrr => _delegate.ggrr;

  @override
  Vector3 get grg => _delegate.grg;

  @override
  Vector4 get grgg => _delegate.grgg;

  @override
  Vector4 get grgr => _delegate.grgr;

  @override
  Vector3 get grr => _delegate.grr;

  @override
  Vector4 get grrg => _delegate.grrg;

  @override
  Vector4 get grrr => _delegate.grrr;

  @override
  bool get isInfinite => _delegate.isInfinite;

  @override
  bool get isNaN => _delegate.isNaN;

  @override
  double get length2 => _delegate.length2;

  @override
  void multiply(Vector2 arg) => _delegate.multiply(arg);

  @override
  void negate() => _delegate.negate();

  @override
  double normalize() => _delegate.normalize();

  @override
  Vector2F normalizeInto(Vector2 out) => _delegate.normalizeInto(out);

  /// DEPRECATED: Use [normalize].
  @override
  @deprecated
  double normalizeLength() => _delegate.normalize();

  @override
  Vector2F normalized() => _delegate.normalized();

  @override
  void postmultiply(Matrix2 arg) => _delegate.postmultiply(arg);

  @override
  void reflect(Vector2 normal) => _delegate.reflect(normal);

  @override
  Vector2F reflected(Vector2 normal) => _delegate.reflected(normal);

  @override
  double relativeError(Vector2 correct) => _delegate.relativeError(correct);

  @override
  Vector3 get rgg => _delegate.rgg;

  @override
  Vector4 get rggg => _delegate.rggg;

  @override
  Vector4 get rggr => _delegate.rggr;

  @override
  Vector3 get rgr => _delegate.rgr;

  @override
  Vector4 get rgrg => _delegate.rgrg;

  @override
  Vector4 get rgrr => _delegate.rgrr;

  @override
  void round() => _delegate.round();

  @override
  void roundToZero() => _delegate.roundToZero();

  @override
  Vector2F get rr => _delegate.rr;

  @override
  Vector3 get rrg => _delegate.rrg;

  @override
  Vector4 get rrgg => _delegate.rrgg;

  @override
  Vector4 get rrgr => _delegate.rrgr;

  @override
  Vector3 get rrr => _delegate.rrr;

  @override
  Vector4 get rrrg => _delegate.rrrg;

  @override
  Vector4 get rrrr => _delegate.rrrr;

  @override
  void scale(double arg) => _delegate.scale(arg);

  @override
  Vector2F scaleOrthogonalInto(double scale, Vector2 out) =>
      _delegate.scaleOrthogonalInto(scale, out);

  @override
  Vector2F scaled(double arg) => _delegate.scaled(arg);

  @override
  void setFrom(Vector2 other) => _delegate.setFrom(other);

  @override
  void setValues(double x, double y) => _delegate.setValues(x, y);

  @override
  void setZero() => _delegate.setZero();

  @override
  void splat(double arg) => _delegate.splat(arg);

  @override
  Vector2F get ss => _delegate.ss;

  @override
  Vector3 get sss => _delegate.sss;

  @override
  Vector4 get ssss => _delegate.ssss;

  @override
  Vector4 get ssst => _delegate.ssst;

  @override
  Vector3 get sst => _delegate.sst;

  @override
  Vector4 get ssts => _delegate.ssts;

  @override
  Vector4 get sstt => _delegate.sstt;

  @override
  Float64List get storage => _delegate.storage;

  @override
  Vector3 get sts => _delegate.sts;

  @override
  Vector4 get stss => _delegate.stss;

  @override
  Vector4 get stst => _delegate.stst;

  @override
  Vector3 get stt => _delegate.stt;

  @override
  Vector4 get stts => _delegate.stts;

  @override
  Vector4 get sttt => _delegate.sttt;

  @override
  void sub(Vector2 arg) => _delegate.sub(arg);

  @override
  Vector3 get tss => _delegate.tss;

  @override
  Vector4 get tsss => _delegate.tsss;

  @override
  Vector4 get tsst => _delegate.tsst;

  @override
  Vector3 get tst => _delegate.tst;

  @override
  Vector4 get tsts => _delegate.tsts;

  @override
  Vector4 get tstt => _delegate.tstt;

  @override
  Vector2F get tt => _delegate.tt;

  @override
  Vector3 get tts => _delegate.tts;

  @override
  Vector4 get ttss => _delegate.ttss;

  @override
  Vector4 get ttst => _delegate.ttst;

  @override
  Vector3 get ttt => _delegate.ttt;

  @override
  Vector4 get ttts => _delegate.ttts;

  @override
  Vector4 get tttt => _delegate.tttt;

  @override
  Vector2F get xx => _delegate.xx;

  @override
  Vector3 get xxx => _delegate.xxx;

  @override
  Vector4 get xxxx => _delegate.xxxx;

  @override
  Vector4 get xxxy => _delegate.xxxy;

  @override
  Vector3 get xxy => _delegate.xxy;

  @override
  Vector4 get xxyx => _delegate.xxyx;

  @override
  Vector4 get xxyy => _delegate.xxyy;

  @override
  Vector3 get xyx => _delegate.xyx;

  @override
  Vector4 get xyxx => _delegate.xyxx;

  @override
  Vector4 get xyxy => _delegate.xyxy;

  @override
  Vector3 get xyy => _delegate.xyy;

  @override
  Vector4 get xyyx => _delegate.xyyx;

  @override
  Vector4 get xyyy => _delegate.xyyy;

  @override
  Vector3 get yxx => _delegate.yxx;

  @override
  Vector4 get yxxx => _delegate.yxxx;

  @override
  Vector4 get yxxy => _delegate.yxxy;

  @override
  Vector3 get yxy => _delegate.yxy;

  @override
  Vector4 get yxyx => _delegate.yxyx;

  @override
  Vector4 get yxyy => _delegate.yxyy;

  @override
  Vector2F get yy => _delegate.yy;

  @override
  Vector3 get yyx => _delegate.yyx;

  @override
  Vector4 get yyxx => _delegate.yyxx;

  @override
  Vector4 get yyxy => _delegate.yyxy;

  @override
  Vector3 get yyy => _delegate.yyy;

  @override
  Vector4 get yyyx => _delegate.yyyx;

  @override
  Vector4 get yyyy => _delegate.yyyy;

  @override
  set g(double arg) => _delegate.g = arg;

  @override
  set gr(Vector2 arg) => _delegate.gr = arg;

  @override
  set length(double value) => _delegate.length = value;

  @override
  set r(double arg) => _delegate.r = arg;

  @override
  set rg(Vector2 arg) => _delegate.rg = arg;

  @override
  set s(double arg) => _delegate.s = arg;

  @override
  set st(Vector2 arg) => _delegate.st = arg;

  @override
  set t(double arg) => _delegate.t = arg;

  @override
  set ts(Vector2 arg) => _delegate.ts = arg;

  @override
  set x(double arg) => _delegate.x = arg;

  @override
  set xy(Vector2 arg) => _delegate.xy = arg;

  @override
  set y(double arg) => _delegate.y = arg;

  @override
  set yx(Vector2 arg) => _delegate.yx = arg;
}
