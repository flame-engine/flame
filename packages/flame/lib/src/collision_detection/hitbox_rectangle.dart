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
    print(vertices);
    refreshVertices(newVertices: Rectangle.sizeToVertices(size));
    print(vertices);
    print(position);
    print(anchor);
    print(size);
  }
}
