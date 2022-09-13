import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:flame_tiled/src/renderable_tile_map.dart';
import 'package:tiled/tiled.dart';

/// {@template _tiled_component}
/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
/// {@endtemplate}
class TiledComponent<T extends FlameGame> extends Component with HasGameRef<T> {
  /// Map instance of this component.
  RenderableTiledMap tileMap;

  /// The logical size of the component. The game assumes that this is the
  /// approximate size of the object that will be drawn on the screen.
  late final Vector2 size = _computeSize();

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

  Vector2 _computeSize() {
    final tMap = tileMap.map;

    final xScale = tileMap.destTileSize.x / tMap.tileWidth;
    final yScale = tileMap.destTileSize.y / tMap.tileHeight;

    final tileScaled = Vector2(
      tileMap.map.tileWidth * xScale,
      tileMap.map.tileHeight * yScale,
    );

    if (tMap.orientation == null) {
      return Vector2.zero();
    }

    switch (tMap.orientation!) {
      case MapOrientation.staggered:
        return tMap.staggerAxis == StaggerAxis.y
            ? Vector2(
                tileScaled.x * tileMap.map.width + tileScaled.x / 2,
                tileScaled.y + ((tileMap.map.height - 1) * tileScaled.y / 2),
              )
            : Vector2(
                tileScaled.x + ((tileMap.map.width - 1) * tileScaled.x / 2),
                tileScaled.y * tileMap.map.height + tileScaled.y / 2,
              );

      case MapOrientation.hexagonal:
        return tMap.staggerAxis == StaggerAxis.y
            ? Vector2(
                tileMap.map.width * tileScaled.x + tileScaled.x / 2,
                tileScaled.y + ((tileMap.map.height - 1) * tileScaled.y * 0.75),
              )
            : Vector2(
                tileScaled.x + ((tileMap.map.width - 1) * tileScaled.x * 0.75),
                (tileMap.map.height * tileScaled.y) + tileScaled.y / 2,
              );

      case MapOrientation.isometric:
      case MapOrientation.orthogonal:
        return Vector2(
          tileMap.map.width * tileScaled.x,
          tileMap.map.height * tileScaled.y,
        );
    }
  }
}
