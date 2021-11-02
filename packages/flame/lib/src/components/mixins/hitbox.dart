import 'dart:collection';
import 'dart:ui';

import '../../../extensions.dart';
import '../../geometry/shape.dart';
import '../position_component.dart';

mixin HasHitboxes on PositionComponent {
  final List<HitboxShape> _hitboxes = <HitboxShape>[];

  UnmodifiableListView<HitboxShape> get hitboxes {
    return UnmodifiableListView(_hitboxes);
  }

  void addHitbox(HitboxShape shape) {
    shape.component = this;
    _hitboxes.add(shape);
  }

  void removeHitbox(HitboxShape shape) {
    _hitboxes.remove(shape);
  }

  /// Checks whether the hitbox represented by the list of [HitboxShape]
  /// contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return possiblyContainsPoint(point) &&
        _hitboxes.any((shape) => shape.containsPoint(point));
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    renderHitboxes(canvas);
  }

  void renderHitboxes(Canvas canvas, {Paint? paint}) {
    _hitboxes.forEach((shape) => shape.render(canvas, paint ?? debugPaint));
  }

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  bool possiblyOverlapping(HasHitboxes other) {
    final maxDistance = other.scaledSize.length + scaledSize.length;
    return other.absoluteCenter.distanceToSquared(absoluteCenter) <=
        maxDistance * maxDistance;
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool possiblyContainsPoint(Vector2 point) {
    return absoluteCenter.distanceToSquared(point) <= scaledSize.length2;
  }
}
