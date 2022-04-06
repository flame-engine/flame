import 'package:vector_math/vector_math_64.dart';

abstract class CoordinateTransform {
  Vector2? parentToLocal(Vector2 point);

  Vector2? localToParent(Vector2 point);
}
