
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import '../game/transform2d.dart';
import 'camera.dart';

class Viewfinder extends Component {

  final Transform2D _transform = Transform2D();

  Vector2 get position => _transform.position;
  set position(Vector2 value) => _transform.position = value;

  double get zoom => _transform.scale.x;
  set zoom(double value) => _transform.scale = Vector2.all(value);

  double get angle => _transform.angle;
  set angle(double value) => _transform.angle;

  double? get visibleGameWidth => _visibleGameWidth;
  double? _visibleGameWidth;
  set visibleGameWidth(double? value) {
    _visibleGameWidth = value;
    _visibleGameHeight = null;
    _initZoom();
  }

  double? get visibleGameHeight => _visibleGameHeight;
  double? _visibleGameHeight;
  set visibleGameHeight(double? value) {
    _visibleGameWidth = null;
    _visibleGameHeight = value;
    _initZoom();
  }

  void _initZoom() {
    if (isMounted) {
      if (_visibleGameWidth != null) {
        zoom = (parent! as Camera2).viewport.size.x / _visibleGameWidth!;
      }
      if (_visibleGameHeight != null) {
        zoom = (parent! as Camera2).viewport.size.y / _visibleGameHeight!;
      }
    }
  }

  @override
  void onMount() {
    _initZoom();
  }

  @override
  void renderTree(Canvas canvas) {}

  void renderFromViewport(Canvas canvas) {
    canvas.transform(_transform.transformMatrix.storage);
  }
}
