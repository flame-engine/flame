import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentPosition, () {
    test('defaults to the origin', () {
      const position = ComponentPosition();

      expect(position.x, equals(0));
      expect(position.y, equals(0));
    });

    test('round-trips through JSON, including negative values', () {
      const position = ComponentPosition(x: -10, y: 20.5);

      expect(ComponentPosition.fromJson(position.toJson()), equals(position));
    });

    test('fromJson falls back to the origin for invalid values', () {
      expect(
        ComponentPosition.fromJson(const {'x': 'a'}),
        equals(const ComponentPosition()),
      );
      expect(
        ComponentPosition.fromJson(null),
        equals(const ComponentPosition()),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentPosition(x: 1, y: 2).copyWith(y: 3),
        equals(const ComponentPosition(x: 1, y: 3)),
      );
    });
  });
}
