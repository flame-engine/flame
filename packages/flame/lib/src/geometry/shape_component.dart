import 'dart:ui';

import '../../components.dart';

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class ShapeComponent extends PositionComponent with HasPaint {
  // TODO(spydon): is this needed
  final Vector2 initialPosition;
  // TODO(spydon): is this needed
  final Vector2 halfSize;
  late void Function() _sizeListener;
  bool renderShape = true;

  ShapeComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  })  : initialPosition = position ?? Vector2.zero(),
        halfSize = (size ?? Vector2.zero()) / 2,
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    this.paint = paint ?? this.paint;
  }

  @override
  void onMount() {
    super.onMount();
    _sizeListener = () {
      halfSize
        ..setFrom(size)
        ..scale(0.5);
    };
    _sizeListener();
    size.addListener(_sizeListener);
  }

  @override
  void onRemove() {
    size.removeListener(_sizeListener);
    super.onRemove();
  }
}
