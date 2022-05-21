import 'package:flame/src/extensions/vector2.dart';
import 'package:meta/meta.dart';

/// Represents a relative position inside some 2D object with a rectangular
/// size or bounding box.
///
/// Think of it as the place where you "grab" or "hold" the object.
/// In Components, the Anchor is where the component position is measured from.
/// For example, if a component position is (100, 100) the anchor reflects what
/// exact point of the component that is positioned at (100, 100), as a relative
/// fraction of the size of the object.
///
/// The "default" anchor in most cases is topLeft.
///
/// The Anchor is represented by a fraction of the size (in each axis),
/// where 0 in x-axis means left, 0 in y-axis means top, 1 in x-axis means right
/// and 1 in y-axis means bottom.
@immutable
class Anchor {
  static const Anchor topLeft = Anchor(0.0, 0.0);
  static const Anchor topCenter = Anchor(0.5, 0.0);
  static const Anchor topRight = Anchor(1.0, 0.0);
  static const Anchor centerLeft = Anchor(0.0, 0.5);
  static const Anchor center = Anchor(0.5, 0.5);
  static const Anchor centerRight = Anchor(1.0, 0.5);
  static const Anchor bottomLeft = Anchor(0.0, 1.0);
  static const Anchor bottomCenter = Anchor(0.5, 1.0);
  static const Anchor bottomRight = Anchor(1.0, 1.0);

  /// The relative x position with respect to the object's width;
  /// 0 means totally to the left (beginning) and 1 means totally to the
  /// right (end).
  final double x;

  /// The relative y position with respect to the object's height;
  /// 0 means totally to the top (beginning) and 1 means totally to the
  /// bottom (end).
  final double y;

  /// Returns [x] and [y] as a Vector2. Note that this is still a relative
  /// fractional representation.
  Vector2 toVector2() => Vector2(x, y);

  const Anchor(this.x, this.y);

  Vector2 translate(Vector2 p, Vector2 size) {
    return p - (toVector2()..multiply(size));
  }

  /// Take your position [position] that is on this anchor and give back what
  /// that position it would be on in anchor [otherAnchor] with a size of
  /// [size].
  Vector2 toOtherAnchorPosition(
    Vector2 position,
    Anchor otherAnchor,
    Vector2 size,
  ) {
    if (this == otherAnchor) {
      return position;
    } else {
      return position +
          ((otherAnchor.toVector2() - toVector2())..multiply(size));
    }
  }

  /// Returns a string representation of this Anchor.
  ///
  /// This should only be used for serialization purposes.
  String get name {
    return _valueNames[this] ?? 'Anchor($x, $y)';
  }

  /// Returns a string representation of this Anchor.
  ///
  /// This is the same as `name` and should be used only for debugging or
  /// serialization.
  @override
  String toString() => name;

  static final Map<Anchor, String> _valueNames = {
    topLeft: 'topLeft',
    topCenter: 'topCenter',
    topRight: 'topRight',
    centerLeft: 'centerLeft',
    center: 'center',
    centerRight: 'centerRight',
    bottomLeft: 'bottomLeft',
    bottomCenter: 'bottomCenter',
    bottomRight: 'bottomRight',
  };

  /// List of all predefined anchor values.
  static final List<Anchor> values = _valueNames.keys.toList();

  /// This should only be used for de-serialization purposes.
  ///
  /// If you need to convert anchors to serializable data (like JSON),
  /// use the `toString()` and `valueOf` methods.
  static Anchor valueOf(String name) {
    if (_valueNames.containsValue(name)) {
      return _valueNames.entries.singleWhere((e) => e.value == name).key;
    } else {
      final regexp = RegExp(r'^\Anchor\(([^,]+), ([^\)]+)\)');
      final matches = regexp.firstMatch(name)?.groups([1, 2]);
      assert(
        matches != null && matches.length == 2,
        'Bad anchor format: $name',
      );
      return Anchor(double.parse(matches![0]!), double.parse(matches[1]!));
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Anchor && x == other.x && y == other.y;
  }

  @override
  int get hashCode => x.hashCode * 31 + y.hashCode;
}
