import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flame_texturepacker/src/model/region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Region', () {
    late Page dummyPage;

    setUp(() {
      dummyPage = Page();
    });

    test('encodes and decodes all fields correctly', () {
      final region = Region(
        page: dummyPage,
        name: 'test_region',
        left: 123,
        top: 456,
        width: 789,
        height: 321,
        offsetX: 50,
        offsetY: 75,
        originalWidth: 800,
        originalHeight: 600,
        degrees: 90,
        rotate: true,
        index: 3,
      );

      expect(region.name, 'test_region');
      expect(region.page, dummyPage);

      expect(region.left, 123);
      expect(region.top, 456);
      expect(region.width, 789);
      expect(region.height, 321);
      expect(region.offsetX, 50);
      expect(region.offsetY, 75);
      expect(region.originalWidth, 800);
      expect(region.originalHeight, 600);

      expect(region.degrees, 90);
      expect(region.rotate, isTrue);
      expect(region.index, 3);
    });

    test('default values decode correctly', () {
      final region = Region(
        page: dummyPage,
        name: 'default_region',
      );

      expect(region.name, 'default_region');
      expect(region.page, dummyPage);

      expect(region.left, 0);
      expect(region.top, 0);
      expect(region.width, 0);
      expect(region.height, 0);
      expect(region.offsetX, 0);
      expect(region.offsetY, 0);
      expect(region.originalWidth, 0);
      expect(region.originalHeight, 0);

      expect(region.degrees, 0);
      expect(region.rotate, isFalse);
      expect(region.index, -1);
    });

    test('handles max values correctly', () {
      const max = 4095;

      final region = Region(
        page: dummyPage,
        name: 'max_region',
        left: max.toDouble(),
        top: max.toDouble(),
        width: max.toDouble(),
        height: max.toDouble(),
        offsetX: max.toDouble(),
        offsetY: max.toDouble(),
        originalWidth: max.toDouble(),
        originalHeight: max.toDouble(),
        degrees: 359,
        rotate: true,
        index: 999999,
      );

      expect(region.left, max.toDouble());
      expect(region.top, max.toDouble());
      expect(region.width, max.toDouble());
      expect(region.height, max.toDouble());
      expect(region.offsetX, max.toDouble());
      expect(region.offsetY, max.toDouble());
      expect(region.originalWidth, max.toDouble());
      expect(region.originalHeight, max.toDouble());

      expect(region.degrees, 359);
      expect(region.rotate, isTrue);
      expect(region.index, 999999);
    });
  });
}
