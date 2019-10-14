import 'package:flame/position.dart';

///
/// This is equivalent to the [Position] class but for Integers.
///
/// Both it's 2D coordinates (x, y) are ints.
class IntPosition {
  static final RegExp _matcher =
      RegExp('IntPosition\\(x\\: (\\-?\\d*), y\\: (\\-?\\d*)\\)');

  final int x, y;

  const IntPosition(this.x, this.y);

  const IntPosition.empty() : this(0, 0);

  IntPosition.fromIntPosition(IntPosition p) : this(p.x, p.y);

  IntPosition.fromPosition(Position p) : this(p.x.toInt(), p.y.toInt());

  IntPosition.fromString(String str)
      : this._fromMatch(_matcher.allMatches(str).first);

  IntPosition._fromMatch(Match match)
      : this(int.parse(match.group(1)), int.parse(match.group(2)));

  Position toPosition() => Position(x.toDouble(), y.toDouble());

  IntPosition add(int x, int y) => IntPosition(this.x + x, this.y + y);

  IntPosition minus(int x, int y) => add(-x, -y);

  IntPosition times(int m) => IntPosition(m * x, m * y);

  IntPosition addIntPosition(IntPosition other) => add(other.x, other.y);

  IntPosition minusIntPosition(IntPosition other) => minus(other.x, other.y);

  IntPosition opposite() => const IntPosition.empty().minusIntPosition(this);

  @override
  String toString() => 'IntPosition(x: $x, y: $y)';

  IntPosition clone() => IntPosition.fromIntPosition(this);

  bool equals(IntPosition p) => p.x == x && p.y == y;

  @override
  bool operator ==(other) {
    return other is IntPosition && equals(other);
  }

  @override
  int get hashCode => toString().hashCode;

  factory IntPosition.fromJson(Map<String, dynamic> json) =>
      IntPosition(json['x'] as int, json['y'] as int);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}
