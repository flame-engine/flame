import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:flame_tiled/src/renderable_tile_map.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

/// {@template _tiled_component}
/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
/// {@endtemplate}
class TiledComponent<T extends FlameGame> extends PositionComponent
    with HasGameRef<T> {
  /// Map instance of this component.
  RenderableTiledMap tileMap;

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set size(Vector2 size) {
    // Intentionally left empty.
  }

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set width(double w) {
    // Intentionally left empty.
  }

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set height(double h) {
    // Intentionally left empty.
  }

  /// {@macro _tiled_component}
  TiledComponent(
    this.tileMap, {
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : super(
          size: computeSize(
            tileMap.map.orientation,
            tileMap.destTileSize,
            tileMap.map.tileWidth,
            tileMap.map.tileHeight,
            tileMap.map.width,
            tileMap.map.height,
            tileMap.map.staggerAxis,
          ),
        );

  @override
  Future<void>? onLoad() async {
    super.onLoad();
    // Automatically use the FlameGame camera if it's not already set.
    tileMap.camera ??= gameRef.camera;
  }

  @override
  void update(double dt) {
    tileMap.update(dt);
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

  @visibleForTesting
  static Vector2 computeSize(
    MapOrientation? orientation,
    Vector2 destTileSize,
    int tileWidth,
    int tileHeight,
    int mapWidth,
    int mapHeight,
    StaggerAxis? staggerAxis,
  ) {
    if (orientation == null) {
      return NotifyingVector2.zero();
    }
    final xScale = destTileSize.x / tileWidth;
    final yScale = destTileSize.y / tileHeight;

    final tileScaled = Vector2(
      tileWidth * xScale,
      tileHeight * yScale,
    );

    switch (orientation) {
      case MapOrientation.staggered:
        return staggerAxis == StaggerAxis.y
            ? Vector2(
                tileScaled.x * mapWidth + tileScaled.x / 2,
                (mapHeight + 1) * (tileScaled.y / 2),
              )
            : Vector2(
                (mapWidth + 1) * (tileScaled.x / 2),
                tileScaled.y * mapHeight + tileScaled.y / 2,
              );

      case MapOrientation.hexagonal:
        return staggerAxis == StaggerAxis.y
            ? Vector2(
                mapWidth * tileScaled.x + tileScaled.x / 2,
                tileScaled.y + ((mapHeight - 1) * tileScaled.y * 0.75),
              )
            : Vector2(
                tileScaled.x + ((mapWidth - 1) * tileScaled.x * 0.75),
                (mapHeight * tileScaled.y) + tileScaled.y / 2,
              );

      case MapOrientation.isometric:
        final halfTile = tileScaled / 2;
        final dimensions = mapWidth + mapHeight;
        return halfTile..scale(dimensions.toDouble());

      case MapOrientation.orthogonal:
        return Vector2(
          mapWidth * tileScaled.x,
          mapHeight * tileScaled.y,
        );
    }
  }
}
