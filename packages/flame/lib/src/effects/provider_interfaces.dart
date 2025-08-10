import 'dart:ui';

import 'package:flame/components.dart';

/// Interface for a component that can be affected by move effects.
abstract class PositionProvider implements ReadOnlyPositionProvider {
  set position(Vector2 value);
}

/// Interface for a class that has [position] property which can be read but not
/// modified.
abstract class ReadOnlyPositionProvider {
  Vector2 get position;
}

/// This class allows constructing [PositionProvider]s on the fly, using the
/// callbacks for the position getter and setter. This class doesn't require
/// either the getter or the setter, if you do not intend to use those.
class PositionProviderImpl implements PositionProvider {
  PositionProviderImpl({
    Vector2 Function()? getValue,
    void Function(Vector2)? setValue,
  }) : _getter = getValue,
       _setter = setValue;

  final Vector2 Function()? _getter;
  final void Function(Vector2)? _setter;

  @override
  Vector2 get position => _getter!();

  @override
  set position(Vector2 value) => _setter!(value);
}

/// Interface for a class that has [scale] property which can be read but not
/// modified.
abstract class ReadOnlyScaleProvider {
  Vector2 get scale;
}

/// Interface for a component that can be affected by scale effects.
abstract class ScaleProvider extends ReadOnlyScaleProvider {
  set scale(Vector2 value);
}

/// Interface for a class that has [angle] property which can be read but not
/// modified.
abstract class ReadOnlyAngleProvider {
  double get angle;
}

/// Interface for a component that can be affected by rotation effects.
abstract class AngleProvider extends ReadOnlyAngleProvider {
  set angle(double value);
}

/// Interface for a component that can be affected by anchor effects.
abstract class AnchorProvider {
  Anchor get anchor;
  set anchor(Anchor value);
}

/// Interface for a class that has [size] property which can be read but not
/// modified.
abstract class ReadOnlySizeProvider {
  Vector2 get size;
}

/// Interface for a component that can be affected by size effects.
abstract class SizeProvider extends ReadOnlySizeProvider {
  set size(Vector2 value);
}

/// Interface for a component that can be affected by opacity effects.
/// Value of [opacity] must be in the range of 0-1 (both inclusive).
///
/// It is allowed for implementers of this interface to use an integer for
/// internal representation. In such cases, [opacity] get/set are expected
/// to perform necessary conversions from integer to double and vice versa.
/// As a side effect of this, setting the opacity to some `x` value would not
/// necessarily produce the same `x` when reading it back.
///
/// See [HasPaint] for an example implementation.
abstract class OpacityProvider {
  double get opacity;
  set opacity(double value);
}

/// Interface for a component that can be affected by Paint effects.
///
/// See [HasPaint] for an example implementation.
abstract class PaintProvider {
  Paint get paint;
  set paint(Paint value);
}
