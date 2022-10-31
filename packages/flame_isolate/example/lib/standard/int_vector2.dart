import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';

@immutable
class IntVector2 {
  final int x;
  final int y;

  const IntVector2(this.x, this.y);

  /// Manhattan distance on a square grid
  int distanceTo(IntVector2 b) {
    return (x - b.x).abs() + (y - b.y).abs();
  }

  @override
  bool operator ==(Object o) => o is IntVector2 && x == o.x && y == o.y;

  @override
  int get hashCode => hash2(x, y);

  @override
  String toString() {
    return '$x : $y';
  }

  IntVector2 add({int x = 0, int y = 0}) => IntVector2(this.x + x, this.y + y);

  Vector2 toPosition() => Vector2(x.toDouble(), y.toDouble());
}
