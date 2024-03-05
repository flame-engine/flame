import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';

/// A class that holds the data of the tilemap from a sprite fusion.
class SpriteFusionTilemapData {
  /// The size of the tiles in the tilemap.
  final double tileSize;

  /// The width of the tilemap in tile units.
  final double mapWidth;

  /// The height of the tilemap in tile units.
  final double mapHeight;

  /// The layers of the tilemap.
  final List<SpriteFusionLayerData> layers;

  /// Creates a new instance of [SpriteFusionTilemapData].
  SpriteFusionTilemapData({
    required this.tileSize,
    required this.mapWidth,
    required this.mapHeight,
    required this.layers,
  });

  /// Creates a new instance of [SpriteFusionTilemapData] from a map.
  factory SpriteFusionTilemapData.fromMap(Map<String, dynamic> map) {
    return SpriteFusionTilemapData(
      tileSize: double.parse(map['tileSize'].toString()),
      mapWidth: double.parse(map['mapWidth'].toString()),
      mapHeight: double.parse(map['mapHeight'].toString()),
      layers: (map['layers'] as List<dynamic>)
          .map(
            (layer) =>
                SpriteFusionLayerData.fromMap(layer as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}
