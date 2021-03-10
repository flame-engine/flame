import 'dart:collection';
import 'dart:math';

import '../../../extensions.dart';
import '../../geometry/shape.dart';
import '../position_component.dart';

mixin Hitbox on PositionComponent {
  final List<HitboxShape> _shapes = <HitboxShape>[];

  UnmodifiableListView<HitboxShape> get shapes => UnmodifiableListView(_shapes);

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
    return possiblyContainsPoint(point) &&
        _shapes.any((shape) => shape.containsPoint(point));
  }

  void renderShapes(Canvas canvas) {
    _shapes.forEach((shape) => shape.render(canvas, debugPaint));
  }

  final _cachedBoundingRect = ShapeCache<Rect>();
  /// Returns the absolute [Rect] that contains all the corners of the rotated
  /// [toAbsoluteRect] rect.
  Rect toBoundingRect() {
    if (!_cachedBoundingRect.isCacheValid([position, size])) {
      final maxRadius = size.length/2;
      _cachedBoundingRect.updateCache(
        Rect.fromCenter(center: position.toOffset(), width: maxRadius, height: maxRadius,),
        [position.clone(), size.clone()],
      );
    }
    return _cachedBoundingRect.value!;
  }

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  bool possiblyOverlapping(Hitbox other) {
    return toBoundingRect().overlaps(other.toBoundingRect());
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool possiblyContainsPoint(Vector2 point) {
    return toBoundingRect().containsPoint(point);
  }
}
