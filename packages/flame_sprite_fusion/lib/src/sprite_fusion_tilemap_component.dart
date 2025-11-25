import 'dart:async';
import 'dart:convert';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_sprite_fusion/flame_sprite_fusion.dart';
import 'package:flutter/widgets.dart';

/// A component that renders a tilemap from a sprite fusion.
class SpriteFusionTilemapComponent extends PositionComponent {
  /// The data of the tilemap.
  final SpriteFusionTilemapData tilemapData;

  /// The sprite sheet of the tilemap.
  final SpriteSheet spriteSheet;

  /// The sprite batch of the tilemap.
  late final SpriteBatch _spriteBatch;

  /// Creates a new [SpriteFusionTilemapComponent] with the given [tilemapData]
  /// and [spriteSheet].
  SpriteFusionTilemapComponent({
    required this.tilemapData,
    required this.spriteSheet,
    bool useAtlas = true,
    super.position,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : super(
         size: Vector2(
           tilemapData.mapWidth * tilemapData.tileSize,
           tilemapData.mapHeight * tilemapData.tileSize,
         ),
       ) {
    _spriteBatch = SpriteBatch(spriteSheet.image, useAtlas: useAtlas);

    for (final data in tilemapData.layers.reversed) {
      for (final tileData in data.tiles) {
        final sprite = spriteSheet.getSpriteById(tileData.id);

        _spriteBatch.add(
          source: Rect.fromLTWH(
            sprite.srcPosition.x,
            sprite.srcPosition.y,
            sprite.srcSize.x,
            sprite.srcSize.y,
          ),
          offset: Vector2(
            tileData.x * tilemapData.tileSize,
            tileData.y * tilemapData.tileSize,
          ),
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _spriteBatch.render(canvas);
  }

  /// Loads a [SpriteFusionTilemapComponent] from the given json file and
  /// spritesheet file.
  static Future<SpriteFusionTilemapComponent> load({
    required String mapJsonFile,
    required String spriteSheetFile,
    bool useAtlas = true,
    String tilemapPrefix = 'assets/tiles/',
    AssetBundle? assetBundle,
    Images? images,
    Vector2? position,
    Vector2? scale,
    double? angle,
    double nativeAngle = 0,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    ComponentKey? key,
  }) async {
    final content = await (assetBundle ?? Flame.bundle).loadString(
      '$tilemapPrefix$mapJsonFile',
    );

    final json = jsonDecode(content) as Map<String, dynamic>;

    return SpriteFusionTilemapComponent(
      tilemapData: SpriteFusionTilemapData.fromMap(json),
      spriteSheet: SpriteSheet(
        image: await (images ?? Flame.images).load(spriteSheetFile),
        srcSize: Vector2.all(double.parse(json['tileSize'].toString())),
      ),
      useAtlas: useAtlas,
      position: position,
      scale: scale,
      angle: angle,
      nativeAngle: nativeAngle,
      anchor: anchor,
      children: children,
      priority: priority,
      key: key,
    );
  }
}
