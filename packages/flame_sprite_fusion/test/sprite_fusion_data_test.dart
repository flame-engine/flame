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
