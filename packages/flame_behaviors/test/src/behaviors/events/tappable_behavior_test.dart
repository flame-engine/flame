import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBehavior extends TappableBehavior {}

void main() {
  group('$TappableBehavior', () {
    test('can be instantiated', () {
      expect(_TestBehavior(), isNotNull);
    });
  });
}
