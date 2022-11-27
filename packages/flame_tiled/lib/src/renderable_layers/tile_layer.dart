import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flame_tiled/src/tile_transform.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

@internal
class FlameTileLayer extends RenderableLayer<TileLayer> {
  late final _layerPaint = Paint();
  final TiledAtlas tiledAtlas;
  late List<List<MutableRSTransform?>> indexes;
  final animations = <TileAnimation>[];
  final Map<Tile, TileFrames> animationFrames;

  FlameTileLayer(
    super.layer,
    super.parent,
    super.map,
    super.destTileSize,
    this.tiledAtlas,
    this.animationFrames,
  ) {
    _layerPaint.color = Color.fromRGBO(255, 255, 255, opacity);
  }

  @override
  void refreshCache() {
    animations.clear();
    indexes = List.generate(
      layer.width,
      (index) => List.filled(layer.height, null),
    );

    _cacheLayerTiles();
  }

  @override
  void update(double dt) {
    for (final animation in animations) {
      animation.update(dt);
    }
  }

  void _cacheLayerTiles() {
    tiledAtlas.batch?.clear();

    if (map.orientation == null) {
      return;
    }

    switch (map.orientation!) {
      case MapOrientation.isometric:
        _cacheIsometricTiles();
        break;
      case MapOrientation.staggered:
        _cacheIsometricStaggeredTiles();
        break;
      case MapOrientation.hexagonal:
        _cacheHexagonalTiles();
        break;
      case MapOrientation.orthogonal:
        _cacheOrthogonalLayerTiles();
        break;
    }
  }

  void _cacheOrthogonalLayerTiles() {
    final tileData = layer.tileData!;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile)!;
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;

        if (img == null) {
          continue;
        }

        if (!tiledAtlas.contains(img.source)) {
          return;
        }

        final spriteOffset = tiledAtlas.offsets[img.source]!;
        final src = MutableRect.fromRect(
          tileset
              .computeDrawRect(tile)
              .toRect()
              .translate(spriteOffset.dx, spriteOffset.dy),
        );

        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;
        offsetX = (tx + .5) * size.x;
        offsetY = (ty + .5) * size.y;

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        indexes[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );

        batch.addTransform(
          source: src,
          transform: indexes[tx][ty],
          flip: flips.flip,
        );

        if (tile.animation.isNotEmpty) {
          _addAnimation(tile, tileset, src);
        }
      }
    }
  }

  void _cacheIsometricTiles() {
    final tileData = layer.tileData!;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final isometricXShift = map.height * halfDestinationTile.x;
    final isometricYShift = halfDestinationTile.y;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile)!;
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        if (!tiledAtlas.contains(img.source)) {
          return;
        }

        final spriteOffset = tiledAtlas.offsets[img.source]!;
        final src = MutableRect.fromRect(
          tileset
              .computeDrawRect(tile)
              .toRect()
              .translate(spriteOffset.dx, spriteOffset.dy),
        );
        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;

        offsetX = halfDestinationTile.x * (tx - ty) + isometricXShift;
        offsetY = halfDestinationTile.y * (tx + ty) + isometricYShift;

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        indexes[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );

        batch.addTransform(
          source: src,
          transform: indexes[tx][ty],
          flip: flips.flip,
        );

        if (tile.animation.isNotEmpty) {
          _addAnimation(tile, tileset, src);
        }
      }
    }
  }

  void _cacheIsometricStaggeredTiles() {
    final tileData = layer.tileData!;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Isometric staggered tiles move down by a fractional amount.
    if (map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.5;
    } else
    // Isometric staggered tiles move right by a fractional amount.
    if (map.staggerAxis == StaggerAxis.x) {
      staggerX = size.x * 0.5;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Isometric staggered tiles shift left and right depending on the row
      if (map.staggerAxis == StaggerAxis.y) {
        if ((ty.isOdd && map.staggerIndex == StaggerIndex.odd) ||
            (ty.isEven && map.staggerIndex == StaggerIndex.even)) {
          staggerX = halfDestinationTile.x;
        } else {
          staggerX = 0.0;
        }
      }

      // When staggering in the X axis, we need to hold painting of "lower"
      // tiles (those with staggerY adjustments) otherwise they'll just get
      // painted over. See the second pass loop after tx.
      final xSecondPass = <TileTransform>[];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile)!;
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        if (!tiledAtlas.contains(img.source)) {
          return;
        }

        final spriteOffset = tiledAtlas.offsets[img.source]!;
        final src = MutableRect.fromRect(
          tileset
              .computeDrawRect(tile)
              .toRect()
              .translate(spriteOffset.dx, spriteOffset.dy),
        );

        // Tiles shift up and down as we move across the row.
        if (map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == StaggerIndex.even)) {
            staggerY = halfDestinationTile.y;
          } else {
            staggerY = 0.0;
          }
        }

        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;

        // halfTile.x: shifts the map half a tile forward rather than
        //             lining up on at the center.
        // halfTile.y: shifts the map half a tile down rather than
        //             lining up on at the center.
        // StaggerX/Y: Moves the tile forward/down depending on orientation.
        //  * stagger: Isometric tiles move down or right by only a fraction,
        //             specifically 1/2 the width or height, for packing.
        if (map.staggerAxis == StaggerAxis.y) {
          offsetX = tx * size.x + staggerX + halfDestinationTile.x;
          offsetY = ty * staggerY + halfDestinationTile.y;
        } else {
          offsetX = tx * staggerX + halfDestinationTile.x;
          offsetY = ty * size.y + staggerY + halfDestinationTile.y;
        }

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        final transform = indexes[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );

        // A second pass is only needed in the case of staggery.
        if (map.staggerAxis == StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(TileTransform(src, transform, flips.flip, batch));
        } else {
          batch.addTransform(
            source: src,
            transform: transform,
            flip: flips.flip,
          );
        }
        if (tile.animation.isNotEmpty) {
          _addAnimation(tile, tileset, src);
        }
      }

      for (final tile in xSecondPass) {
        tile.batch.addTransform(
          source: tile.source,
          transform: tile.transform,
          flip: tile.flip,
        );
      }
    }
  }

  void _cacheHexagonalTiles() {
    final tileData = layer.tileData!;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Pointy Tiles move down by a fractional amount.
    if (map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.75;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (map.staggerAxis == StaggerAxis.x) {
      staggerX = size.x * 0.75;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (map.staggerAxis == StaggerAxis.y) {
        if ((ty.isOdd && map.staggerIndex == StaggerIndex.odd) ||
            (ty.isEven && map.staggerIndex == StaggerIndex.even)) {
          staggerX = halfDestinationTile.x;
        } else {
          staggerX = 0.0;
        }
      }

      // When staggering in the X axis, we need to hold painting of "lower"
      // tiles (those with staggerY adjustments) otherwise they'll just get
      // painted over. See the second pass loop after tx.
      final xSecondPass = <TileTransform>[];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile)!;
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        if (!tiledAtlas.contains(img.source)) {
          return;
        }

        final spriteOffset = tiledAtlas.offsets[img.source]!;
        final src = MutableRect.fromRect(
          tileset
              .computeDrawRect(tile)
              .toRect()
              .translate(spriteOffset.dx, spriteOffset.dy),
        );

        // Hexagonal Flat tiles shift up and down as we move across the row.
        if (map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == StaggerIndex.even)) {
            staggerY = halfDestinationTile.y;
          } else {
            staggerY = 0.0;
          }
        }

        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;

        // halfTile.x: shifts the map half a tile forward rather than
        //             lining up on at the center.
        // halfTile.y: shifts the map half a tile down rather than
        //             lining up on at the center.
        // StaggerX/Y: Moves the tile forward/down depending on orientation.
        //  * stagger: Hexagonal tiles move down or right by only a fraction,
        //             specifically 3/4 the width or height, for packing.
        if (map.staggerAxis == StaggerAxis.y) {
          offsetX = tx * size.x + staggerX + halfDestinationTile.x;
          offsetY = ty * staggerY + halfDestinationTile.y;
        } else {
          offsetX = tx * staggerX + halfDestinationTile.x;
          offsetY = ty * size.y + staggerY + halfDestinationTile.y;
        }

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        final transform = indexes[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );
        // A second pass is only needed in the case of staggery.
        if (map.staggerAxis == StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(TileTransform(src, transform, flips.flip, batch));
        } else {
          batch.addTransform(
            source: src,
            transform: transform,
            flip: flips.flip,
          );
        }
        if (tile.animation.isNotEmpty) {
          _addAnimation(tile, tileset, src);
        }
      }

      for (final tile in xSecondPass) {
        tile.batch.addTransform(
          source: tile.source,
          transform: tile.transform,
          flip: tile.flip,
        );
      }
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

  static Future<FlameTileLayer> load(
    TileLayer layer,
    GroupLayer? parent,
    TiledMap map,
    Vector2 destTileSize,
    Map<Tile, TileFrames> animationFrames,
    TiledAtlas atlas,
  ) async {
    return FlameTileLayer(
      layer,
      parent,
      map,
      destTileSize,
      atlas,
      animationFrames,
    );
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  void _addAnimation(Tile tile, Tileset tileset, MutableRect source) {
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
}
