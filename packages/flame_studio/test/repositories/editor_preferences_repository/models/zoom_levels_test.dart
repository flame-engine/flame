import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ZoomLevels, () {
    test('levels go from min to max, in order', () {
      expect(ZoomLevels.all.first, ZoomLevels.min);
      expect(ZoomLevels.all.last, ZoomLevels.max);
      expect(ZoomLevels.all, orderedEquals([...ZoomLevels.all]..sort()));
      expect(ZoomLevels.all, contains(1));
    });

    test('next steps to the next level', () {
      expect(ZoomLevels.next(1), 1.5);
      expect(ZoomLevels.next(1.2), 1.5);
      expect(ZoomLevels.next(ZoomLevels.max), isNull);
    });

    test('previous steps to the previous level', () {
      expect(ZoomLevels.previous(1), 0.75);
      expect(ZoomLevels.previous(1.2), 1);
      expect(ZoomLevels.previous(ZoomLevels.min), isNull);
    });
  });
}
