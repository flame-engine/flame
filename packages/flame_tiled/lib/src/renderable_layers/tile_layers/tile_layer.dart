import 'dart:collection';

import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/hexagonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/isometric_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/orthogonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/staggered_tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// {@template flame_tile_layer}
/// [FlameTileLayer] is the base class of the following classes:
///
/// - [OrthogonalTileLayer]
/// - [StaggeredTileLayer]
/// - [HexagonalTileLayer]
/// - [IsometricTileLayer]
///
/// [FlameTileLayer] decides its concrete type by [MapOrientation]. So any
/// subclass of this should implement [cacheTiles] to reflect their map
/// orientation format.
///
/// [FlameTileLayer] stores its source image to [tiledAtlas]
/// and transform it by [transforms].
///
/// The flip is ignored if the [ignoreFlip] is set to true.
///
/// {@endtemplate}
@internal
abstract class FlameTileLayer extends RenderableLayer<TileLayer> {
  late Paint _layerPaint = layerPaintFactory(opacity);
  final TiledAtlas tiledAtlas;

  /// Cached transform of every tile, indexed as
  /// `transforms[x - originX][y - originY]` for the Tiled tile `(x, y)`.
  ///
  /// It covers the layer's [TileLayer.contentBounds]. Use [transformAt] and
  /// [storeTransform] instead of indexing it directly.
  late List<List<MutableRSTransform?>> transforms;

  /// The Tiled coordinates of the tile stored at `transforms[0][0]`.
  ///
  /// This is `(0, 0)` for finite maps. Infinite maps can have tiles at
  /// negative coordinates, in which case the origin is negative too.
  int originX = 0;
  int originY = 0;
  final animations = <TileAnimation>[];
  final Map<Tile, TileFrames> animationFrames;
  final bool ignoreFlip;
  Paint Function(double opacity) layerPaintFactory;

  FlameTileLayer({
    required super.layer,
    required super.map,
    required super.destTileSize,
    required this.tiledAtlas,
    required this.animationFrames,
    required this.ignoreFlip,
    required this.layerPaintFactory,
    super.filterQuality,
  });

  @override
  void onOpacityChanged() {
    _layerPaint = layerPaintFactory(opacity);
  }

  /// {@macro flame_tile_layer}
  static FlameTileLayer load({
    required TileLayer layer,
    required TiledMap map,
    required Vector2 destTileSize,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    required Paint Function(double opacity) layerPaintFactory,
    FilterQuality? filterQuality,
    bool? ignoreFlip,
  }) {
    ignoreFlip ??= false;
    final mapOrientation = map.orientation;
    if (mapOrientation == null) {
      throw StateError('Map orientation should be present');
    }

    return switch (mapOrientation) {
      MapOrientation.isometric => IsometricTileLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        tiledAtlas: atlas,
        animationFrames: animationFrames,
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      ),
      MapOrientation.staggered => StaggeredTileLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        tiledAtlas: atlas,
        animationFrames: animationFrames,
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      ),
      MapOrientation.hexagonal => HexagonalTileLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        tiledAtlas: atlas,
        animationFrames: animationFrames,
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      ),
      MapOrientation.orthogonal => OrthogonalTileLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        tiledAtlas: atlas,
        animationFrames: animationFrames,
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      ),
    };
  }

  @override
  void update(double dt) {
    for (final animation in animations) {
      animation.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    tiledAtlas.batch?.render(canvas, paint: _layerPaint);
  }

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
    // The area that has tiles: `(0, 0, width, height)` for finite layers, the
    // area covered by all chunks for infinite layers, and `null` for layers
    // without any tile data.
    final bounds = layer.contentBounds;
    if (bounds == null) {
      originX = 0;
      originY = 0;
      transforms = <List<MutableRSTransform?>>[];
    } else {
      originX = bounds.left;
      originY = bounds.top;
      transforms = List.generate(
        bounds.width,
        (_) => List.filled(bounds.height, null),
      );
    }

    tiledAtlas.batch?.clear();

    cacheTiles();
  }

  /// Transform for Tiled tile `(x, y)`, or `null` if that cell is empty or
  /// outside this layer's cached bounds.
  MutableRSTransform? transformAt(int x, int y) {
    final ix = x - originX;
    final iy = y - originY;
    if (ix < 0 ||
        iy < 0 ||
        ix >= transforms.length ||
        iy >= transforms[ix].length) {
      return null;
    }
    return transforms[ix][iy];
  }

  /// Stores the [transform] of the Tiled tile `(tx, ty)` in [transforms].
  @protected
  void storeTransform(int tx, int ty, MutableRSTransform transform) {
    transforms[tx - originX][ty - originY] = transform;
  }

  /// Non-empty tiles of this layer grouped by Tiled row, with rows sorted by
  /// `y` and each row sorted by `x`.
  ///
  /// Infinite layers store tiles chunk by chunk, so iterating the layer
  /// directly does not visit tiles in row-major order. Overlapping tiles
  /// (isometric, staggered, hexagonal and oversized tiles) need row-major
  /// order to be painted like Tiled does.
  @protected
  SplayTreeMap<int, List<(int x, Gid gid)>> tilesByWorldRow() {
    final rows = SplayTreeMap<int, List<(int x, Gid gid)>>();
    layer.forEachTile((x, y, gid) {
      if (gid.tile == 0) {
        return;
      }
      rows.putIfAbsent(y, () => []).add((x, gid));
    });
    for (final row in rows.values) {
      row.sort((a, b) => a.$1.compareTo(b.$1));
    }
    return rows;
  }

  /// We need to know the following information for each tile to render a layer
  /// correctly.
  ///
  /// - source offset
  /// - rotation
  /// - translation
  /// - flip
  ///
  /// But gathering these in every tick is a too heavy task for the engine.
  /// So, [FlameTileLayer] caches these by [cacheTiles] and tiles quickly in
  /// every frame.
  @protected
  void cacheTiles();

  @protected
  bool shouldFlip(SimpleFlips flips) => !ignoreFlip && flips.flip;
}
