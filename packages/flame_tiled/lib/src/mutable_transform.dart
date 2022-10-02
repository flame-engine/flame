import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// A mutable version of [RSTransform] for custom batch manipulation.
class MutableRSTransform implements RSTransform, PositionProvider {
  final _values = Float32List(4);

  /// This is a cache of `-scos * anchorX + ssin * anchorY`
  final double _anchorX;

  /// This is a cache of `-ssin * anchorX - scos * anchorY`
  final double _anchorY;

  final Vector2 _position;

  MutableRSTransform(
    double scos,
    double ssin,
    double tx,
    double ty,
    this._anchorX,
    this._anchorY,
  ) : _position = Vector2(tx, ty) {
    _values[0] = scos;
    _values[1] = ssin;
    _values[2] = tx + _anchorX;
    _values[3] = ty + _anchorY;
  }

  /// The cosine of the rotation multiplied by the scale factor.
  @override
  double get scos => _values[0];
  set scos(double scos) => _values[0] = scos;

  /// The sine of the rotation multiplied by that same scale factor.
  @override
  double get ssin => _values[1];
  set ssin(double ssin) => _values[1] = ssin;

  /// The x coordinate of the translation, minus [scos] multiplied by the
  /// x-coordinate of the rotation point, plus [ssin] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get tx => _values[2];
  set tx(double tx) => _values[2] = tx;

  /// The y coordinate of the translation, minus [ssin] multiplied by the
  /// x-coordinate of the rotation point, minus [scos] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get ty => _values[3];
  set ty(double ty) => _values[3] = ty;

  @override
  set position(Vector2 value) {
    _values[2] = value.x + _anchorX;
    _values[3] = value.y + _anchorY;
    _position.x = value.x;
    _position.y = value.y;
  }

  @override
  Vector2 get position => _position;
}
