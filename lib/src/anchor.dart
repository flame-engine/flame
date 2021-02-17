import 'extensions/vector2.dart';

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

  final double x;
  final double y;

  Vector2 get toVector2 => Vector2(x, y);

  const Anchor(this.x, this.y);

  Vector2 translate(Vector2 p, Vector2 size) {
    return p - (toVector2..multiply(size));
  }

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

  static final List<Anchor> values = _valueNames.keys.toList();

  @override
  String toString() {
    return _valueNames[this];
  }

  static Anchor parse(String name) {
    return _valueNames.entries.singleWhere((e) => e.value == name).key;
  }
}
