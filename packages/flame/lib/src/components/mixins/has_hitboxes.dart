import 'dart:collection';
import 'dart:ui';

import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../extensions.dart';
import '../../../geometry.dart';

mixin HasHitboxes on PositionComponent {
  final List<HitboxShape> _hitboxes = <HitboxShape>[];
  final Aabb2 _aabb = Aabb2();
  bool _validAabb = false;
  Aabb2 get aabb => _validAabb ? _aabb : _recalculateAabb();
  final Vector2 _halfExtents = Vector2.zero();
  final Matrix3 _rotationMatrix = Matrix3.zero();

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    ancestors(includeSelf: true)
        .whereType<PositionComponent>()
        .forEach((c) => c.transform.addListener(() => _validAabb = false));
  }

  Aabb2 _recalculateAabb() {
    final size = scaledSize;
    // This has +1 since a point on the edge of the bounding box is currently
    // counted as inside.
    _halfExtents.setValues(size.x + 1, size.y + 1);
    _rotationMatrix.setRotationZ(absoluteAngle);
    _validAabb = true;
    return _aabb
      ..setCenterAndHalfExtents(absoluteCenter, _halfExtents)
      ..rotate(_rotationMatrix);
  }

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
    final test = aabb.intersectsWithAabb2(other.aabb);
    return test;
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool possiblyContainsPoint(Vector2 point) {
    return aabb.containsVector2(point);
  }
}
