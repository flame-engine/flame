import 'dart:math';

import 'package:flame/extensions.dart';

/// This represents a line on the ax + by = c form
/// If you just want to represent a part of a line, look into LineSegment.
class Line {
  final double a;
  final double b;
  final double c;

  const Line(this.a, this.b, this.c);

  Line.fromPoints(Vector2 p1, Vector2 p2)
      : this(
          p2.y - p1.y,
          p1.x - p2.x,
          p2.y * p1.x - p1.y * p2.x,
        );

  /// Returns an empty list if there is no intersection
  /// If the lines are concurrent it returns one point in the list.
  /// If they coincide it returns an empty list as well
  List<Vector2> intersections(Line otherLine) {
    final determinant = a * otherLine.b - otherLine.a * b;
    if (determinant == 0) {
      //The lines are parallel (potentially coincides) and have no intersection
      return [];
    }
    return [
      Vector2(
        (otherLine.b * c - b * otherLine.c) / determinant,
        (a * otherLine.c - otherLine.a * c) / determinant,
      ),
    ];
  }

  /// The angle of this line in relation to the x-axis
  double get angle => atan2(-a, b);

  @override
  String toString() {
    final ax = '${a}x';
    final by = b.isNegative ? '${b}y' : '+${b}y';
    return '$ax$by=$c';
  }
}
