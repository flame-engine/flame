import 'package:flame/src/anchor.dart';
import 'package:vector_math/vector_math_64.dart';

/// Interface for a component that can be affected by move effects.
abstract class PositionProvider {
  Vector2 get position;
  set position(Vector2 value);
}

/// This class allows constructing [PositionProvider]s on the fly, using the
/// callbacks for the position getter and setter. This class doesn't require
/// either the getter or the setter, if you do not intend to use those.
class PositionProviderImpl implements PositionProvider {
  PositionProviderImpl({
    Vector2 Function()? getValue,
    void Function(Vector2)? setValue,
  })  : _getter = getValue,
        _setter = setValue;

  final Vector2 Function()? _getter;
  final void Function(Vector2)? _setter;

  @override
  Vector2 get position => _getter!();

  @override
  set position(Vector2 value) => _setter!(value);
}

/// Interface for a component that can be affected by scale effects.
abstract class ScaleProvider {
  Vector2 get scale;
  set scale(Vector2 value);
}

/// Interface for a component that can be affected by rotation effects.
abstract class AngleProvider {
  double get angle;
  set angle(double value);
}

/// Interface for a component that can be affected by anchor effects.
abstract class AnchorProvider {
  Anchor get anchor;
  set anchor(Anchor value);
}

/// Interface for a component that can be affected by size effects.
abstract class SizeProvider {
  Vector2 get size;
  set size(Vector2 value);
}
