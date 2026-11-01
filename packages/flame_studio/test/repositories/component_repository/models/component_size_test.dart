import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentSize, () {
    test('defaults to 50x50', () {
      const size = ComponentSize();

      expect(size.width, equals(50));
      expect(size.height, equals(50));
    });

    test('round-trips through JSON', () {
      const size = ComponentSize(width: 12.5, height: 4);

      expect(ComponentSize.fromJson(size.toJson()), equals(size));
    });

    test('reads integers', () {
      expect(
        ComponentSize.fromJson(const {'width': 10, 'height': 20}),
        equals(const ComponentSize(width: 10, height: 20)),
      );
    });

    test('falls back to defaults for missing or invalid values', () {
      expect(ComponentSize.fromJson(null), equals(const ComponentSize()));
      expect(
        ComponentSize.fromJson(const {'width': 'wide', 'height': -1}),
        equals(const ComponentSize()),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentSize().copyWith(width: 1),
        equals(const ComponentSize(width: 1)),
      );
      expect(
        const ComponentSize().copyWith(height: 2),
        equals(const ComponentSize(height: 2)),
      );
    });
  });
}
