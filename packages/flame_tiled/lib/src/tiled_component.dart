import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:flame_tiled/src/renderable_tile_map.dart';

/// {@template _tiled_component}
/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
/// {@endtemplate}
class TiledComponent<T extends FlameGame> extends Component with HasGameRef<T> {
  /// Map instance of this component.
  RenderableTiledMap tileMap;

  /// {@macro _tiled_component}
  TiledComponent(
    this.tileMap, {
    super.children,
    super.priority,
  });

  @override
  Future<void>? onLoad() async {
    super.onLoad();
    // Automatically use the FlameGame camera if it's not already set.
    tileMap.camera ??= gameRef.camera;
  }

  @override
  void render(Canvas canvas) {
    tileMap.render(canvas);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    tileMap.handleResize(canvasSize);
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
