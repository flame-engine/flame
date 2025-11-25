/// A class that holds the data of a tile from a sprite fusion map.
class SpriteFusionTileData {
  /// The id of the tile.
  ///
  /// This is also the index position of the tile in the tileset, starting at 0,
  /// from left to right, top to bottom.
  final int id;

  /// The x position of the tile in tile units.
  final int x;

  /// The y position of the tile in tile units.
  final int y;

  /// The attributes of the tile.
  final Map<String, dynamic>? attributes;

  /// Creates a new instance of [SpriteFusionTileData].
  SpriteFusionTileData({
    required this.id,
    required this.x,
    required this.y,
    this.attributes,
  });

  /// Creates a new instance of [SpriteFusionTileData] from a map.
  factory SpriteFusionTileData.fromMap(Map<String, dynamic> map) {
    return SpriteFusionTileData(
      id: int.parse(map['id'].toString()),
      x: int.parse(map['x'].toString()),
      y: int.parse(map['y'].toString()),
      attributes: map['attributes'] as Map<String, dynamic>?,
    );
  }

  /// Checks if the tile has an attribute with the given [key].
  bool hasAttribute(String key) {
    return attributes != null && attributes!.containsKey(key);
  }

  /// Gets the attribute with the given [key].
  /// The attribute is casted to the given type [T].
  ///
  /// Returns null if the attribute does not exist.
  T? getAttribute<T>(String key) {
    return hasAttribute(key) ? attributes![key] as T : null;
  }
}
