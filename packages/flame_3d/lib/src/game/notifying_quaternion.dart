import 'dart:math';
import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flutter/widgets.dart';

class NotifyingQuaternion extends Quaternion with ChangeNotifier {
  /// Constructs a quaternion using the raw values [x], [y], [z], and [w].
  factory NotifyingQuaternion(double x, double y, double z, double w) =>
      NotifyingQuaternion._()..setValues(x, y, z, w);
  NotifyingQuaternion._() : super.fromFloat32List(Float32List(4));

  /// Constructs a quaternion from a rotation matrix [rotationMatrix].
  factory NotifyingQuaternion.fromRotation(Matrix3 rotationMatrix) =>
      NotifyingQuaternion._()..setFromRotation(rotationMatrix);

  /// Constructs a quaternion from a rotation of [angle] around [axis].
  factory NotifyingQuaternion.axisAngle(Vector3 axis, double angle) =>
      NotifyingQuaternion._()..setAxisAngle(axis, angle);

  /// Constructs a quaternion as a copy of [original].
  factory NotifyingQuaternion.copy(Quaternion original) =>
      NotifyingQuaternion._()..setFrom(original);

  /// Constructs a quaternion from time derivative of [q] with angular
  /// velocity [omega].
  factory NotifyingQuaternion.dq(Quaternion q, Vector3 omega) =>
      NotifyingQuaternion._()..setDQ(q, omega);

  /// Constructs a quaternion from [yaw], [pitch] and [roll].
  factory NotifyingQuaternion.euler(double yaw, double pitch, double roll) =>
      NotifyingQuaternion._()..setEuler(yaw, pitch, roll);

  @override
  void setValues(double x, double y, double z, double w) {
    super.setValues(x, y, z, w);
    notifyListeners();
  }

  @override
  void setAxisAngle(Vector3 axis, double radians) {
    super.setAxisAngle(axis, radians);
    notifyListeners();
  }

  @override
  void setDQ(Quaternion q, Vector3 omega) {
    super.setDQ(q, omega);
    notifyListeners();
  }

  @override
  void setEuler(double yaw, double pitch, double roll) {
    super.setEuler(yaw, pitch, roll);
    notifyListeners();
  }

  @override
  void setFromRotation(Matrix3 rotationMatrix) {
    super.setFromRotation(rotationMatrix);
    notifyListeners();
  }

  @override
  void setFromTwoVectors(Vector3 a, Vector3 b) {
    super.setFromTwoVectors(a, b);
    notifyListeners();
  }

  @override
  void setRandom(Random rn) {
    super.setRandom(rn);
    notifyListeners();
  }

  @override
  void setFrom(Quaternion source) {
    super.setFrom(source);
    notifyListeners();
  }

  @override
  void operator []=(int i, double arg) {
    super[i] = arg;
    notifyListeners();
  }

  @override
  double normalize() {
    final l = super.normalize();
    notifyListeners();
    return l;
  }

  @override
  void add(Quaternion arg) {
    super.add(arg);
    notifyListeners();
  }

  @override
  void sub(Quaternion arg) {
    super.sub(arg);
    notifyListeners();
  }

  @override
  void scale(double scale) {
    super.scale(scale);
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
  set w(double w) {
    super.w = w;
    notifyListeners();
  }

  @override
  Float32List get storage => UnmodifiableFloat32ListView(super.storage);

  @override
  void conjugate() {
    super.conjugate();
    notifyListeners();
  }

  @override
  void inverse() {
    super.inverse();
    notifyListeners();
  }
}
