import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// This is just a pair of [int, int].
///
/// Represents a position in a 2d-matrix or tilemap.
@immutable
class Block {
  /// x coordinate in the matrix.
  final int x;

  /// y coordinate in the matrix.
  final int y;

  const Block(this.x, this.y);

  const Block.zero() : this(0, 0);

  Block.roundFromVector2(Vector2 position)
    : this(position.x.round(), position.y.round());

  Block.floorFromVector2(Vector2 position)
    : this(position.x.floor(), position.y.floor());

  Block.ceilFromVector2(Vector2 position)
    : this(position.x.ceil(), position.y.ceil());

  Block operator +(Block direction) {
    return Block(x + direction.x, y + direction.y);
  }

  Block operator -(Block other) {
    return Block(x - other.x, y - other.y);
  }

  Vector2 operator *(double scalar) {
    return Vector2(x * scalar, y * scalar);
  }

  @override
  String toString() => '($x, $y)';

  Vector2 toVector2() => Vector2Extension.fromInts(x, y);

  @override
  bool operator ==(Object other) {
    if (other is! Block) {
      return false;
    }
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
