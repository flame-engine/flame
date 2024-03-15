import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TiledObjectHelpers', () {
    test('position returns correct values', () {
      final tiledObject = TiledObject(id: 0);

      expect(tiledObject.position.x, 0);
      expect(tiledObject.position.y, 0);

      tiledObject.x = 26;
      tiledObject.y = 83;

      expect(tiledObject.position.x, 26);
      expect(tiledObject.position.y, 83);
    });

    test('size returns correct values', () {
      final tiledObject = TiledObject(id: 0);

      expect(tiledObject.size.x, 0);
      expect(tiledObject.size.y, 0);

      tiledObject.width = 59;
      tiledObject.height = 42;

      expect(tiledObject.size.x, 59);
      expect(tiledObject.size.y, 42);
    });
  });
}
