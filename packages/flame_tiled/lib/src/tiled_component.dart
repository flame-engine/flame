import 'dart:ui';

import 'package:flame/components.dart';

import 'package:flame_tiled/src/renderable_tile_map.dart';

/// {@template _tiled_component}
/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
/// {@endtemplate}
class TiledComponent extends Component {
  /// Map instance of this component.
  RenderableTiledMap tileMap;

  /// {@macro _tiled_component}
  TiledComponent(
    this.tileMap, {
    super.children,
    super.priority,
  });

  @override
  void render(Canvas canvas) {
    tileMap.render(canvas);
  }

  /// Loads a [TiledComponent] from a file.
  static Future<TiledComponent> load(
    String fileName,
    Vector2 destTileSize, {
    int? priority,
  }) async {
    return TiledComponent(
      await RenderableTiledMap.fromFile(fileName, destTileSize),
      priority: priority,
    );
  }
}
