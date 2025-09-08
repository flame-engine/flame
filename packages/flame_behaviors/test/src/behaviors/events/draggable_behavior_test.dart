import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBehavior extends DraggableBehavior {}

void main() {
  group('$DraggableBehavior', () {
    test('can be instantiated', () {
      expect(_TestBehavior(), isNotNull);
    });
  });
}
