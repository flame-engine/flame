import 'extensions/vector2.dart';

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
///  where 0 means top/left and 1 means right/bottom.
class Anchor {
  static const Anchor topLeft = Anchor._(0.0, 0.0);
  static const Anchor topCenter = Anchor._(0.5, 0.0);
  static const Anchor topRight = Anchor._(1.0, 0.0);
  static const Anchor centerLeft = Anchor._(0.0, 0.5);
  static const Anchor center = Anchor._(0.5, 0.5);
  static const Anchor centerRight = Anchor._(1.0, 0.5);
  static const Anchor bottomLeft = Anchor._(0.0, 1.0);
  static const Anchor bottomCenter = Anchor._(0.5, 1.0);
  static const Anchor bottomRight = Anchor._(1.0, 1.0);

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
  Vector2 get toVector2 => Vector2(x, y);

  /// Consider Anchor a sealed class (or more specifically an enum).
  const Anchor._(this.x, this.y);

  Vector2 translate(Vector2 p, Vector2 size) {
    return p - (toVector2..multiply(size));
  }

  /// Returns a string representation of this Anchor.
  ///
  /// This should only be used for serialization purposes.
  String get name => _valueNames[this];

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

  /// List of all possible anchor values.
  static final List<Anchor> values = _valueNames.keys.toList();

  /// This should only be used for de-serialization purposes.
  ///
  /// If you need to convert anchors to serializable data (like JSON),
  /// use the `toString()` and `valueOf` methods.
  static Anchor valueOf(String name) {
    return _valueNames.entries.singleWhere((e) => e.value == name).key;
  }
}
