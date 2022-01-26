import '../../components.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxRectangle extends Rectangle with HasHitboxes, HitboxShape {
  @override
  final bool shouldFillParent;

  HitboxRectangle({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : shouldFillParent = size == null && position == null,
        super(
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  void fillParent() {
    final newVertices = [
      Rectangle.toCorner(position, size, anchor, Anchor.topLeft),
      Rectangle.toCorner(position, size, anchor, Anchor.bottomLeft),
      Rectangle.toCorner(position, size, anchor, Anchor.bottomRight),
      Rectangle.toCorner(position, size, anchor, Anchor.topRight),
    ];
    print(vertices);
    refreshVertices(newVertices: newVertices);
    print(position);
    print(anchor);
    print(size);
  }
}
