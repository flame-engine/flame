import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ListExtension', () {
    test('reverse', () {
      final list = [1, 3, 3, 7];
      list.reverse();
      expect(list, [7, 3, 3, 1]);
      list.insert(1, 4);
      list.reverse();
      expect(list, [1, 3, 3, 4, 7]);
    });

    test('random', () {
      final list = [1, 3, 3, 7];
      final random = Random(0);
      final element1 = list.random(random);
      expect(element1, 7);
      final element2 = list.random(random);
      expect(element2, 3);
    });
  });
}
