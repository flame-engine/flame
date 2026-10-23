import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/hexagonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/isometric_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/orthogonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/staggered_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_chunk.dart';
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
abstract class FlameTileLayer({
  required super.layer,
  required super.map,
  required super.destTileSize,
  required final TiledAtlas tiledAtlas,
  required final Map<Tile, TileFrames> animationFrames,
  required final bool ignoreFlip,
  required var Paint Function(double opacity) layerPaintFactory,
  super.filterQuality,

  /// The size of the chunks of this layer, in tiles, for the layers that split
  /// their tiles in chunks (see [usesChunks]).
  ///
  /// Infinite maps are always split, and use the chunk size of the map when
  /// this is null. Finite maps are only split when this is set.
  final int? chunkSize,
}) extends RenderableLayer<TileLayer> with ImageRetainer {
  late Paint _layerPaint = layerPaintFactory(opacity);

  @override
  Iterable<Image> get retainedImages {
    final atlas = tiledAtlas.atlas;
    return atlas == null ? const [] : [atlas];
  }

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
    int? chunkSize,
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
        chunkSize: chunkSize,
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
        chunkSize: chunkSize,
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
        chunkSize: chunkSize,
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
        chunkSize: chunkSize,
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

    final view = cullRect;
    var rendered = 0;
    for (final chunk in _sortedChunks) {
      if (view == null || chunk.isVisibleIn(view)) {
        chunk.batch.render(canvas, paint: _layerPaint);
        rendered++;
      }
    }
    _renderedChunkCount = rendered;
  }

  /// The number of chunks that this layer has.
  @visibleForTesting
  int get chunkCount => _sortedChunks.length;

  /// The number of chunks that were rendered the last time this layer was.
  @visibleForTesting
  int get renderedChunkCount => _renderedChunkCount;
  int _renderedChunkCount = 0;

  /// Whether the tiles of this layer are split into chunks, which are only
  /// rendered while they are in view.
  ///
  /// This is the case for the layers of infinite maps, and for the layers of
  /// finite maps when [chunkSize] is set, as long as every tile stays inside of
  /// its own cell. Tiles that stick out of their cell (oversized tiles and
  /// tiles with an offset) are painted over the tiles of other cells, in an
  /// order that chunks would change. Then all of the tiles are kept in
  /// [TiledAtlas.batch].
  ///
  /// Only the tiles of this layer are looked at, and this is decided again
  /// every time the cache is refreshed, since changing a tile can change it.
  bool get usesChunks => _usesChunks;
  bool _usesChunks = false;

  bool _canUseChunks() {
    if (!map.infinite && chunkSize == null) {
      return false;
    }
    // A quarter turn swaps the width and the height of a tile, so in a cell
    // that is not square the tile sticks out of it. The tiles of hexagonal maps
    // are rotated in steps of 60º and keep their size.
    final quarterTurnsStickOut =
        map.tileWidth != map.tileHeight &&
        map.orientation != MapOrientation.hexagonal;
    final tileIds = <int>{};
    var hasQuarterTurn = false;
    layer.forEachTile((_, _, gid) {
      if (gid.tile != 0) {
        tileIds.add(gid.tile);
        hasQuarterTurn = hasQuarterTurn || gid.flips.diagonally;
      }
    });
    if (quarterTurnsStickOut && hasQuarterTurn) {
      return false;
    }
    // Only the tilesets that this layer uses, so that a tileset of bigger
    // tiles that is used by another layer does not keep this one whole.
    return tileIds
        .map(map.tilesetByTileGId)
        .toSet()
        .every(
          (tileset) =>
              tileset.image != null &&
              tileset.tileWidth == map.tileWidth &&
              tileset.tileHeight == map.tileHeight &&
              tileset.tileOffset == null,
        );
  }

  /// The size of a chunk, in tiles. Infinite layers use the chunk size of the
  /// map, so that a chunk of the layer is a chunk of Tiled.
  int _chunkWidth = _defaultChunkSize;
  int _chunkHeight = _defaultChunkSize;
  static const _defaultChunkSize = 16;

  final _chunks = <(int, int), TileChunk>{};

  /// The chunks in the order that they are rendered, which is row by row.
  List<TileChunk> _sortedChunks = const [];

  (int, int) _chunkKey(int tx, int ty) => (
    (tx / _chunkWidth).floor(),
    (ty / _chunkHeight).floor(),
  );

  /// Adds a tile to this layer, to the chunk that it belongs to when this layer
  /// [usesChunks], or else to [TiledAtlas.batch].
  ///
  /// [tx] and [ty] are the Tiled coordinates of the tile.
  @protected
  void addTile(
    int tx,
    int ty, {
    required MutableRect source,
    required MutableRSTransform transform,
    required bool flip,
  }) {
    if (!usesChunks) {
      tiledAtlas.batch?.addTransform(
        source: source,
        transform: transform,
        flip: flip,
      );
      return;
    }
    final key = _chunkKey(tx, ty);
    var chunk = _chunks[key];
    if (chunk == null) {
      final batch = tiledAtlas.newBatch();
      if (batch == null) {
        return;
      }
      chunk = _chunks[key] = TileChunk(batch);
    }
    chunk.add(source: source, transform: transform, flip: flip);
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
    _chunks.clear();
    _sortedChunks = const [];
    assert(
      chunkSize == null || chunkSize! > 0,
      'The chunk size must be at least one tile',
    );
    _chunkWidth =
        chunkSize ?? layer.chunks?.firstOrNull?.width ?? _defaultChunkSize;
    _chunkHeight =
        chunkSize ?? layer.chunks?.firstOrNull?.height ?? _defaultChunkSize;
    _usesChunks = _canUseChunks();

    cacheTiles();

    final keys = _chunks.keys.toList()
      ..sort(
        (a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1),
      );
    _sortedChunks = [for (final key in keys) _chunks[key]!];
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
    final transform = transforms[ix][iy];
    if (transform != null) {
      // The transform can be used to move the tile, out of its chunk.
      _chunks[_chunkKey(x, y)]?.alwaysVisible = true;
    }
    return transform;
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

  /// Builds the transform of a tile whose map cell is centered on
  /// ([offsetX], [offsetY]), so that it is drawn the same way Tiled draws it.
  ///
  /// Tiled aligns a tile to the bottom-left corner of its cell, which means
  /// that tiles that are larger than the map's tile size (oversized tiles) grow
  /// up and to the right. Flips and rotations are then applied within the
  /// bounds of the tile image itself, not around the cell:
  ///  - Horizontal and vertical flips keep the tile where it is.
  ///  - Rotations of 90º (which is what a diagonal flip is) swap the width and
  ///    height of the tile, but keep its bottom-left corner on the bottom-left
  ///    corner of the cell.
  ///  - In hexagonal maps the tile is rotated in steps of 60º around the center
  ///    of the image instead, and it keeps its size (see
  ///    [SimpleFlips.fromHexagonalFlips]).
  ///
  /// For reference, this is the same as `CellRenderer::render` in Tiled.
  @protected
  MutableRSTransform tileTransform({
    required MutableRect src,
    required SimpleFlips flips,
    required double offsetX,
    required double offsetY,
  }) {
    final scale = destTileSize.x / map.tileWidth;
    final scos = flips.cos * scale;
    final ssin = flips.sin * scale;

    final halfWidth = src.width / 2;
    final halfHeight = src.height / 2;
    // The size of the area that the tile covers once it has been rotated.
    final isSwapped = !flips.isHexagonal && flips.angle.isOdd;
    final boundsHalfWidth = isSwapped ? halfHeight : halfWidth;
    final boundsHalfHeight = isSwapped ? halfWidth : halfHeight;

    // The transform rotates around the center of the image, which has to end up
    // on the center of the area that the rotated tile covers. [offsetX] and
    // [offsetY] are the center of the cell, so we move to its bottom-left
    // corner (-tileWidth / 2, +tileHeight / 2) and then to the center of the
    // covered area (+boundsHalfWidth, -boundsHalfHeight).
    final centerShiftX = scale * (boundsHalfWidth - map.tileWidth / 2);
    final centerShiftY = scale * (map.tileHeight / 2 - boundsHalfHeight);

    // The position of the transform is kept on the center of the cell for every
    // tile, no matter its size or rotation. This matters because a TileStack
    // sets the same position on the tiles of all of its layers, so tiles with
    // different sizes would lose their relative offsets otherwise. The shift
    // above is added to the anchor instead, which doesn't change where the tile
    // is drawn.
    //
    // RSTransform wants the anchor as the offset from the position to where
    // the origin of the image ends up once it has been rotated and scaled.
    return MutableRSTransform(
      scos,
      ssin,
      offsetX,
      offsetY,
      -scos * halfWidth + ssin * halfHeight + centerShiftX,
      -ssin * halfWidth - scos * halfHeight + centerShiftY,
    );
  }

  /// The flip (done by mirroring the tile horizontally) is applied before the
  /// rotation of [tileTransform], so vertical flips are represented by a
  /// horizontal flip and a rotation of 180º in [SimpleFlips].
  @protected
  bool shouldFlip(SimpleFlips flips) => !ignoreFlip && flips.flip;
}
