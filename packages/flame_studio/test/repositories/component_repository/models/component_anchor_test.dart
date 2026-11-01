import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentAnchor, () {
    test('top left, the default, is the origin', () {
      expect(ComponentAnchor.topLeft.x, equals(0));
      expect(ComponentAnchor.topLeft.y, equals(0));
      expect(
        const RectangleComponent(name: 'player').anchor,
        equals(ComponentAnchor.topLeft),
      );
    });

    test('has the nine Flame anchors, row by row', () {
      expect(
        ComponentAnchor.presets.values,
        equals([
          for (final y in [0.0, 0.5, 1.0])
            for (final x in [0.0, 0.5, 1.0]) ComponentAnchor(x: x, y: y),
        ]),
      );
    });

    test('presetName is the name of the Flame anchor, if any', () {
      expect(ComponentAnchor.center.presetName, equals('center'));
      expect(
        ComponentAnchor.center.copyWith(x: 1).presetName,
        equals('centerRight'),
      );
      expect(const ComponentAnchor(x: 0.25).presetName, isNull);
    });

    test('round-trips through JSON, including custom values', () {
      const anchor = ComponentAnchor(x: -0.5, y: 1.25);

      expect(ComponentAnchor.fromJson(anchor.toJson()), equals(anchor));
    });

    test('fromJson falls back to the top left corner for invalid values', () {
      expect(
        ComponentAnchor.fromJson(const {'x': 'a', 'y': 1}),
        equals(ComponentAnchor.bottomLeft),
      );
      expect(ComponentAnchor.fromJson(null), equals(ComponentAnchor.topLeft));
    });

    test('copyWith replaces the given fields', () {
      expect(
        ComponentAnchor.center.copyWith(y: 1),
        equals(ComponentAnchor.bottomCenter),
      );
    });
  });
}
