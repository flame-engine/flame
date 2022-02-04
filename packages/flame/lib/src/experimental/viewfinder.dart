
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import '../game/transform2d.dart';

class Viewfinder extends Component {

  final Transform2D _transform = Transform2D();

  Vector2 get position => _transform.position;
  set position(Vector2 value) => _transform.position = value;

  double get zoom => _transform.scale.x;
  set zoom(double value) => _transform.scale = Vector2.all(value);

  double get angle => _transform.angle;
  set angle(double value) => _transform.angle;

  @override
  void renderTree(Canvas canvas) {}

  void renderFromViewport(Canvas canvas) {

  }
}
