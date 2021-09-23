import 'dart:ui';

import 'package:flame/components.dart';

import 'renderable_tile_map.dart';

/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
class TiledComponent extends Component {
  RenderableTiledMap tileMap;

  TiledComponent(this.tileMap);

  @override
  void render(Canvas canvas) {
    tileMap.render(canvas);
  }

  static Future<TiledComponent> load(
    String fileName,
    Vector2 destTileSize,
  ) async {
    return TiledComponent(
      await RenderableTiledMap.fromFile(fileName, destTileSize),
    );
  }
}
