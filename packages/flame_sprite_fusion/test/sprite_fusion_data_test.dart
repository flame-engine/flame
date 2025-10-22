import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteFusionTileData', () {
    test('creation test', () {
      final tileData = SpriteFusionTileData(id: 50, x: 65, y: 89);

      expect(tileData.id, 50);
      expect(tileData.x, 65);
      expect(tileData.y, 89);
    });

    test('creation test with map', () {
      final map = <String, dynamic>{
        'id': 50,
        'x': 65,
        'y': 89,
      };
      final tileData = SpriteFusionTileData.fromMap(map);

      expect(tileData.id, map['id']);
      expect(tileData.x, map['x']);
      expect(tileData.y, map['y']);
    });

    test('hasAttribute returns false when attributes is null', () {
      final tileData = SpriteFusionTileData(id: 1, x: 0, y: 0);

      expect(tileData.hasAttribute('anyKey'), false);
    });

    test('hasAttribute returns false when attribute does not exist', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'existingKey': 'value'},
      );

      expect(tileData.hasAttribute('nonExistentKey'), false);
    });

    test('hasAttribute returns true when attribute exists', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'type': 'grass', 'walkable': true},
      );

      expect(tileData.hasAttribute('type'), true);
      expect(tileData.hasAttribute('walkable'), true);
    });

    test('getAttribute returns null when attributes is null', () {
      final tileData = SpriteFusionTileData(id: 1, x: 0, y: 0);

      expect(tileData.getAttribute<String>('anyKey'), null);
    });

    test('getAttribute returns null when attribute does not exist', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'existingKey': 'value'},
      );

      expect(tileData.getAttribute<String>('nonExistentKey'), null);
    });

    test('getAttribute returns correct value for String type', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'type': 'grass'},
      );

      expect(tileData.getAttribute<String>('type'), 'grass');
    });

    test('getAttribute returns correct value for bool type', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'walkable': true, 'blocking': false},
      );

      expect(tileData.getAttribute<bool>('walkable'), true);
      expect(tileData.getAttribute<bool>('blocking'), false);
    });

    test('getAttribute returns correct value for int type', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'damage': 10, 'health': 100},
      );

      expect(tileData.getAttribute<int>('damage'), 10);
      expect(tileData.getAttribute<int>('health'), 100);
    });

    test('getAttribute returns correct value for double type', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {'speed': 1.5, 'multiplier': 2.75},
      );

      expect(tileData.getAttribute<double>('speed'), 1.5);
      expect(tileData.getAttribute<double>('multiplier'), 2.75);
    });

    test('getAttribute with multiple attributes', () {
      final tileData = SpriteFusionTileData(
        id: 1,
        x: 0,
        y: 0,
        attributes: {
          'type': 'grass',
          'walkable': true,
          'damage': 0,
          'speed': 1.0,
        },
      );

      expect(tileData.getAttribute<String>('type'), 'grass');
      expect(tileData.getAttribute<bool>('walkable'), true);
      expect(tileData.getAttribute<int>('damage'), 0);
      expect(tileData.getAttribute<double>('speed'), 1.0);
    });
  });

  group('SpriteFusionLayerData', () {
    test('creation test', () {
      final tileData = SpriteFusionLayerData(
        name: 'layer1',
        tiles: [
          SpriteFusionTileData(id: 50, x: 65, y: 89),
          SpriteFusionTileData(id: 51, x: 66, y: 90),
        ],
        collider: true,
      );

      expect(tileData.name, 'layer1');
      expect(tileData.tiles.length, 2);
      expect(tileData.collider, true);
    });

    test('creation test with map', () {
      final map = <String, dynamic>{
        'name': 'layer4',
        'tiles': [
          {'id': 50, 'x': 65, 'y': 89},
          {'id': 51, 'x': 66, 'y': 90},
          {'id': 40, 'x': 70, 'y': 95},
        ],
        'collider': false,
      };
      final tileData = SpriteFusionLayerData.fromMap(map);

      expect(tileData.name, map['name']);
      expect(tileData.tiles.length, 3);
      expect(tileData.collider, map['collider']);
    });
  });

  group('SpriteFusionTilemapData', () {
    test('creation test', () {
      final tileData = SpriteFusionTilemapData(
        mapWidth: 10,
        mapHeight: 20,
        tileSize: 32,
        layers: [
          SpriteFusionLayerData(
            name: 'layer1',
            tiles: [
              SpriteFusionTileData(id: 50, x: 65, y: 89),
              SpriteFusionTileData(id: 51, x: 66, y: 90),
            ],
            collider: true,
          ),
          SpriteFusionLayerData(
            name: 'layer2',
            tiles: [
              SpriteFusionTileData(id: 50, x: 65, y: 89),
              SpriteFusionTileData(id: 51, x: 66, y: 90),
            ],
            collider: false,
          ),
        ],
      );

      expect(tileData.mapWidth, 10);
      expect(tileData.mapHeight, 20);
      expect(tileData.tileSize, 32);
      expect(tileData.layers.length, 2);
    });

    test('creation test with map', () {
      final map = <String, dynamic>{
        'mapWidth': 10,
        'mapHeight': 20,
        'tileSize': 32,
        'layers': [
          {
            'name': 'layer1',
            'tiles': [
              {'id': 50, 'x': 65, 'y': 89},
              {'id': 51, 'x': 66, 'y': 90},
            ],
            'collider': true,
          },
          {
            'name': 'layer2',
            'tiles': [
              {'id': 50, 'x': 65, 'y': 89},
              {'id': 51, 'x': 66, 'y': 90},
            ],
            'collider': false,
          },
        ],
      };
      final tileData = SpriteFusionTilemapData.fromMap(map);

      expect(tileData.mapWidth, map['mapWidth']);
      expect(tileData.mapHeight, map['mapHeight']);
      expect(tileData.tileSize, map['tileSize']);
      expect(tileData.layers.length, 2);
    });
  });
}
