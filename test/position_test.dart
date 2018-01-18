import 'package:test/test.dart';

import 'package:flame/position.dart';

void main() {
  group('position test', () {
    test('test add', () {
      Position p = new Position(0.0, 5.0);
      Position p2 = p.add(new Position(5.0, 5.0));
      expect(p, p2);
      expect(p.x, 5.0);
      expect(p.y, 10.0);
    });
  });
}
