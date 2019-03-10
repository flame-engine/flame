import 'dart:ui';

import 'position.dart';

class Anchor {
  static const Anchor topLeft = Anchor(Offset(0.0, 0.0));
  static const Anchor topCenter = Anchor(Offset(0.5, 0.0));
  static const Anchor topRight = Anchor(Offset(1.0, 0.0));
  static const Anchor centerLeft = Anchor(Offset(0.0, 0.5));
  static const Anchor center = Anchor(Offset(0.5, 0.5));
  static const Anchor centerRight = Anchor(Offset(1.0, 0.5));
  static const Anchor bottomLeft = Anchor(Offset(0.0, 1.0));
  static const Anchor bottomCenter = Anchor(Offset(0.5, 1.0));
  static const Anchor bottomRight = Anchor(Offset(1.0, 1.0));

  final Offset relativePosition;

  const Anchor(this.relativePosition);

  Position translate(Position p, Position size) {
    return p.clone().minus(
        Position(size.x * relativePosition.dx, size.y * relativePosition.dy));
  }
}
