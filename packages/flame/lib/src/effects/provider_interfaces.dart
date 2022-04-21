import 'package:vector_math/vector_math_64.dart';

/// Interface for a component that can be affected by move effects.
abstract class PositionProvider {
  Vector2 get position;
  set position(Vector2 value);
}

class ValuePositionProvider implements PositionProvider {
  ValuePositionProvider([Vector2? position])
      : _position = position?.clone() ?? Vector2.zero();

  @override
  Vector2 get position => _position;
  final Vector2 _position;
  @override
  set position(Vector2 value) => _position.setFrom(value);
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
