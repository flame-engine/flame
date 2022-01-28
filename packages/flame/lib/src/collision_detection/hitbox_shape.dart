import 'package:flutter/cupertino.dart';

import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';
import '../geometry/shape_intersections.dart' as intersection_system;

mixin HitboxShape on Shape implements HasHitboxes {
  @override
  bool isLeafHitbox = true;

  @override
  bool get renderShape => _renderShape || debugMode;
  @override
  set renderShape(bool shouldRender) => _renderShape = shouldRender;
  bool _renderShape = false;

  @protected
  late PositionComponent hitboxParent;
  void Function()? _parentSizeListener;
  @protected
  bool shouldFillParent = false;

  @override
  void onMount() {
    super.onMount();
    if (shouldFillParent) {
      hitboxParent = ancestors().firstWhere(
        (c) => c is PositionComponent,
        orElse: () {
          throw StateError('A HitboxShape needs a PositionComponent ancestor');
        },
      ) as PositionComponent;
      _parentSizeListener = () {
        size = hitboxParent.size;
        fillParent();
      };
      _parentSizeListener?.call();
      hitboxParent.size.addListener(_parentSizeListener!);
    }
  }

  @override
  void onRemove() {
    if (_parentSizeListener != null) {
      hitboxParent.size.removeListener(_parentSizeListener!);
    }
    super.onRemove();
  }

  /// Checks whether the [HitboxShape] contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return super.containsPoint(point);
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

  void fillParent();
}
