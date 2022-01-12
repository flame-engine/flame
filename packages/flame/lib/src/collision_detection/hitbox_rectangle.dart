import '../../components.dart';
import '../../flame.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxRectangle extends Rectangle with HasHitboxes, HitboxShape {
  HitboxRectangle({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    shouldFillParent = position == null && size == null;
  }

  @override
  void fillParent() {
    const topLeft = Anchor.topLeft;
    vertices.clear();
    vertices
      ..add(topLeft.toOtherAnchorPosition(Vector2.zero(), anchor, size))
      ..add(topLeft.toOtherAnchorPosition(Vector2(0, size.y), anchor, size))
      ..add(topLeft.toOtherAnchorPosition(size, anchor, size))
      ..add(topLeft.toOtherAnchorPosition(Vector2(size.x, 0), anchor, size));
  }
}
