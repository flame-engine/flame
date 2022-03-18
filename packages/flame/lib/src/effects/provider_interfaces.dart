import 'package:vector_math/vector_math_64.dart';

/// Interface for a component that can be affected by move effects.
abstract class PositionProvider {
  Vector2 get effectPosition;
  set effectPosition(Vector2 value);
}
