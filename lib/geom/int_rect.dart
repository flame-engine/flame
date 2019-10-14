import 'dart:math' as math;
import 'dart:ui';

import '../position.dart';
import 'int_bounds.dart';
import 'int_position.dart';
import 'overlapable.dart';
import 'rectangle.dart';

///
/// This is equivalent to the [Rectangle] class, but with Integers.
/// 
/// All of its coordinates (x, y, width and height) are ints.
class IntRect with Overlapable {

  int x, y, w, h;

  IntRect.fromLTWH(this.x, this.y, this.w, this.h);

  IntRect.fromDouble(double x, double y, double w, double h) : this.fromLTWH(x.toInt(), y.toInt(), w.toInt(), h.toInt());

  IntRect.fromRect(Rect other) {
    x = other.left.toInt();
    y = other.top.toInt();
    w = other.width.toInt();
    h = other.height.toInt();
  }

  IntRect.fromIntRect(IntRect other) {
    x = other.x;
    y = other.y;
    w = other.w;
    h = other.h;
  }

  IntRect.fromPositions(Position p, Position size) {
    x = p.x.toInt();
    y = p.y.toInt();
    w = size.x.toInt();
    h = size.y.toInt();
  }

  static IntRect empty() => IntRect.fromLTWH(0, 0, 0, 0);

  bool get isEmpty => w == 0 || h == 0;
  bool get isNotEmpty => !isEmpty;

  int get left => x;
  int get right => x + w;
  int get top => y;
  int get bottom => y + h;
  int get width => w;
  int get height => h;

  @override
  bool overlaps(Overlapable other) {
    if (other is IntRect) {
      return intersection(other).isNotEmpty;
    } else if (other is IntBounds) {
      return other.overlaps(this);
    } else if (other is CertainOverlap) {
      return true;
    } else {
      throw 'unknown Overlapable: ${other.runtimeType}';
    }
  }

  IntRect union(IntRect other) {
    if (other.isEmpty) {
      return this;
    }
    if (isEmpty) {
      return other;
    }

    final int rxi = math.min(left, other.left);
    final int ryi = math.min(top, other.top);

    final int rxf = math.max(right, other.right);
    final int ryf = math.max(bottom, other.bottom);

    return IntRect.fromLTWH(rxi, ryi, rxf - rxi, ryf - ryi);
  }

  IntRect intersection(IntRect other) {
    if (isEmpty || other.isEmpty) {
      return empty();
    }

    final int rxi = math.max(left, other.left);
    final int ryi = math.max(top, other.top);

    final int rxf = math.min(right, other.right);
    final int ryf = math.min(bottom, other.bottom);

    if (rxi >= rxf || ryi >= ryf) {
      return empty();
    }

    return IntRect.fromLTWH(rxi, ryi, rxf - rxi, ryf - ryi);
  }

  Rect asRect() {
    if (isEmpty) {
      return const Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    }
    return Rect.fromLTWH(left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());
  }

  Position toLT() {
    return Position(x.toDouble(), y.toDouble());
  }

  Position toSize() {
    return Position(width.toDouble(), height.toDouble());
  }

  Position toCenter() {
    return Position(x + w / 2, y + h / 2);
  }

  IntRect expand(int delta) {
    return expandLR(delta).expandTB(delta);
  }

  IntRect expandTB(int delta) {
    y -= delta;
    h += 2 * delta;
    return this;
  }

  IntRect expandLR(int delta) {
    return expandLeft(delta).expandRight(delta);
  }

  IntRect expandLeft(int delta) {
    x -= delta;
    w += delta;
    return this;
  }

  IntRect expandRight(int delta) {
    w += delta;
    return this;
  }

  bool contains(IntPosition p) {
    return (p.x >= x && p.x <= x + width) && (p.y >= y && p.y <= y + height);
  }

  Rectangle toRectangle() => Rectangle.fromIntRect(this);

  @override
  String toString() => 'IntRect(x: $x, y: $y, w: $w, h: $h)';
}