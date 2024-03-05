import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';

/// A class that holds the data of a layer from a sprite fusion map.
class SpriteFusionLayerData {
  /// The name of the layer.
  final String name;

  /// The tiles of the layer.
  final List<SpriteFusionTileData> tiles;

  /// If the layer is a collider.
  final bool collider;

  /// Creates a new instance of [SpriteFusionLayerData].
  SpriteFusionLayerData({
    required this.name,
    required this.tiles,
    required this.collider,
  });

  /// Creates a new instance of [SpriteFusionLayerData] from a map.
  factory SpriteFusionLayerData.fromMap(Map<String, dynamic> map) {
    return SpriteFusionLayerData(
      name: map['name'] as String,
      tiles: (map['tiles'] as List<dynamic>)
          .map(
            (tile) =>
                SpriteFusionTileData.fromMap(tile as Map<String, dynamic>),
          )
          .toList(growable: false),
      collider: map['collider'] as bool,
    );
  }
}
