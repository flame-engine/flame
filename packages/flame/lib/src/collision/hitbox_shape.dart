import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';
import '../geometry/shape_intersections.dart' as intersection_system;

mixin HitboxShape on Shape implements HasHitboxes {
  /// The position of your shape in relation to its parent's size from
  /// (-1,-1) to (1,1), where (0,0) is the center (default).
  Vector2 relativeOffset = Vector2.zero();
  late PositionComponent _hitboxParent;
  late void Function() _parentSizeListener;

  @override
  Anchor anchor = Anchor.center;

  @override
  void onMount() {
    super.onMount();
    _hitboxParent = ancestors().firstWhere(
      (c) => c is PositionComponent,
      orElse: () {
        throw StateError('A HitboxShape needs a PositionComponent ancestor');
      },
    ) as PositionComponent;
    _parentSizeListener = () {
      size = _hitboxParent.size;
      // TODO: Check that the size listener has been called here and that halfSize is correct
      position = (halfSize + halfSize.clone()
            ..multiply(relativeOffset)) +
          initialPosition;
    };
    _parentSizeListener();
    _hitboxParent.size.addListener(_parentSizeListener);
  }

  @override
  void render(_) {}

  @override
  void renderDebugMode(Canvas c) {
    super.render(c);
  }

  @override
  void onRemove() {
    _hitboxParent.size.removeListener(_parentSizeListener);
    super.onRemove();
  }

  /// Checks whether the [HitboxShape] contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return possiblyContainsPoint(point) && super.containsPoint(point);
  }

  /// Where this [Shape] has intersection points with another shape
  @override
  Set<Vector2> intersections(HasHitboxes other) {
    assert(
      other is Shape,
      'The intersection can only be performed between shapes',
    );
    return intersection_system.intersections(this, other as Shape);
  }
}
