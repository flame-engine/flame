import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentRadius, () {
    test('defaults to 25', () {
      expect(const ComponentRadius().radius, equals(25));
    });

    test('round-trips through JSON', () {
      const radius = ComponentRadius(radius: 12.5);

      expect(ComponentRadius.fromJson(radius.toJson()), equals(radius));
    });

    test('reads integers', () {
      expect(
        ComponentRadius.fromJson(const {'radius': 10}),
        equals(const ComponentRadius(radius: 10)),
      );
    });

    test('falls back to the default for missing or invalid values', () {
      expect(ComponentRadius.fromJson(null), equals(const ComponentRadius()));
      expect(
        ComponentRadius.fromJson(const {'radius': 'big'}),
        equals(const ComponentRadius()),
      );
      expect(
        ComponentRadius.fromJson(const {'radius': -1}),
        equals(const ComponentRadius()),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentRadius().copyWith(radius: 1),
        equals(const ComponentRadius(radius: 1)),
      );
      expect(
        const ComponentRadius(radius: 1).copyWith(),
        equals(const ComponentRadius(radius: 1)),
      );
    });
  });
}
