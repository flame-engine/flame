import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer/hexagonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer/isometric_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer/orthogonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer/staggered_tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

@internal
abstract class FlameTileLayer extends RenderableLayer<TileLayer> {
  late final _layerPaint = Paint();
  final TiledAtlas tiledAtlas;
  late List<List<MutableRSTransform?>> indexes;
  final animations = <TileAnimation>[];
  final Map<Tile, TileFrames> animationFrames;
  final bool ignoreFlip;

  FlameTileLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
    required this.tiledAtlas,
    required this.animationFrames,
    required this.ignoreFlip,
  }) {
    _layerPaint.color = Color.fromRGBO(255, 255, 255, opacity);
  }

  static Future<FlameTileLayer> load({
    required TileLayer layer,
    required GroupLayer? parent,
    required TiledMap map,
    required Vector2 destTileSize,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    bool? ignoreFlip,
  }) async {
    ignoreFlip ??= false;

    final mapOrientation = map.orientation;
    if (mapOrientation == null) {
      throw StateError('Map orientation should be present');
    }

    switch (mapOrientation) {
      case MapOrientation.isometric:
        return IsometricTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
        );
      case MapOrientation.staggered:
        return StaggeredTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
        );
      case MapOrientation.hexagonal:
        return HexagonalTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
        );
      case MapOrientation.orthogonal:
        return OrthogonalTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
        );
    }
  }

  @override
  void update(double dt) {
    for (final animation in animations) {
      animation.update(dt);
    }
  }

  @override
  void render(Canvas canvas, Camera? camera) {
    if (tiledAtlas.batch == null) {
      return;
    }

    canvas.save();

    canvas.translate(offsetX, offsetY);

    if (camera != null) {
      applyParallaxOffset(canvas, camera);
    }

    tiledAtlas.batch!.render(canvas, paint: _layerPaint);

    canvas.restore();
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @protected
  void addAnimation(Tile tile, Tileset tileset, MutableRect source) {
    final frames = animationFrames[tile] ??= () {
      final frameRectangles = <Rect>[];
      final durations = <double>[];
      for (final frame in tile.animation) {
        final newTile = tileset.tiles[frame.tileId];
        final image = newTile.image ?? tileset.image;
        if (image?.source == null || !tiledAtlas.contains(image!.source)) {
          continue;
        }

        final spriteOffset = tiledAtlas.offsets[image.source]!;
        final rect = tileset
            .computeDrawRect(newTile)
            .toRect()
            .translate(spriteOffset.dx, spriteOffset.dy);
        frameRectangles.add(rect);
        durations.add(frame.duration / 1000);
      }
      return TileFrames(frameRectangles, durations);
    }();
    animations.add(TileAnimation(source, frames));
  }

  @override
  void refreshCache() {
    animations.clear();
    indexes = List.generate(
      layer.width,
      (index) => List.filled(layer.height, null),
    );

    tiledAtlas.batch?.clear();

    cacheTiles();
  }

  @protected
  void cacheTiles();

  @protected
  bool shouldFlip(SimpleFlips flips) => !ignoreFlip && flips.flip;
}
