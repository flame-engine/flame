import 'dart:collection';

import '../position_component.dart';
import '../../../extensions.dart';
import '../../collision_detection/collision_detection.dart'
    as collision_detection;
import '../../geometry/shape.dart';

mixin Hitbox on PositionComponent {
  final List<HitboxShape> _shapes = <HitboxShape>[];

  UnmodifiableListView<HitboxShape> get shapes => UnmodifiableListView(_shapes);

  // TODO: Maybe change these names
  void addShape(HitboxShape shape) {
    shape.component = this;
    _shapes.add(shape);
  }

  void removeShape(HitboxShape shape) {
    _shapes.remove(shape);
  }

  /// Checks whether the hitbox represented by the list of [HitboxShape]
  /// contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return _shapes.any((shape) => shape.containsPoint(point));
  }

  void renderShapes(Canvas canvas) {
    _shapes.forEach((shape) => shape.render(canvas, debugPaint));
  }
}
