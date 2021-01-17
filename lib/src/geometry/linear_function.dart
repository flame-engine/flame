import '../../extensions.dart';

/// This represents a linear function on the ax + by = c form
class LinearFunction {
  final double a;
  final double b;
  final double c;

  const LinearFunction(this.a, this.b, this.c);

  static LinearFunction fromPoints(Vector2 p1, Vector2 p2) {
    final a = p2.y - p1.y;
    final b = p1.x - p2.x;
    final c = p2.y * p1.x - p1.y * p2.x;
    return LinearFunction(a, b, c);
  }

  /// Returns an empty list if there is no intersection
  List<Vector2> intersections(LinearFunction otherLine) {
    final determinant = a * otherLine.b - otherLine.a * b;
    if (determinant == 0) {
      //The lines are parallel and have no intersection
      return [];
    }
    return [
      Vector2(
        (otherLine.b * c - b * otherLine.c) / determinant,
        (a * otherLine.c - otherLine.a * c) / determinant,
      )
    ];
  }

  @override
  String toString() {
    final a0 = "${a}x";
    final b0 = b.isNegative ? "${b}y" : "+${b}y";
    return "$a0$b0=$c";
  }
}
