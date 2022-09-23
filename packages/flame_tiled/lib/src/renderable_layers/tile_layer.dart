import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/tile_transform.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart' as tiled;

@internal
class TileLayer extends RenderableLayer<tiled.TileLayer> {
  late final _layerPaint = Paint();
  late final Map<String, SpriteBatch> _cachedSpriteBatches;
  late List<List<MutableRSTransform?>> indexes;

  TileLayer(
    super.layer,
    super.parent,
    super.map,
    super.destTileSize,
    this._cachedSpriteBatches,
  ) {
    _layerPaint.color = Color.fromRGBO(255, 255, 255, opacity);
  }

  @override
  void refreshCache() {
    indexes = List.generate(
      layer.width,
      (index) => List.filled(layer.height, null),
    );

    _cacheLayerTiles();
  }

  void _cacheLayerTiles() {
    for (final batch in _cachedSpriteBatches.values) {
      batch.clear();
    }

    if (map.orientation == null) {
      return;
    }

    switch (map.orientation!) {
      case tiled.MapOrientation.isometric:
        _cacheIsometricTiles();
        break;
      case tiled.MapOrientation.staggered:
        _cacheIsometricStaggeredTiles();
        break;
      case tiled.MapOrientation.hexagonal:
        _cacheHexagonalTiles();
        break;
      case tiled.MapOrientation.orthogonal:
        _cacheOrthogonalLayerTiles();
        break;
    }
  }

  void _cacheOrthogonalLayerTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    final size = destTileSize;

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile);
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;

        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        final src = tileset.computeDrawRect(tile).toRect();
        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width / 2;
        final anchorY = src.height / 2;

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
      }
    }
  }

  void _cacheIsometricTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final isometricXShift = map.width * size.x * 0.5;

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = map.tileByGid(tileGid.tile);
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        final src = tileset.computeDrawRect(tile).toRect();
        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / src.width;
        final anchorX = src.width / 2;
        final anchorY = src.height / 2;

        late double offsetX;
        late double offsetY;

        offsetX = halfDestinationTile.x * (tx - ty) + isometricXShift;
        offsetY = halfDestinationTile.y * (tx + ty) - size.y;

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
      }
    }
  }

  void _cacheIsometricStaggeredTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
    if (map.staggerAxis == tiled.StaggerAxis.y) {
      staggerY = size.y * 0.5;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (map.staggerAxis == tiled.StaggerAxis.x) {
      staggerX = size.x * 0.5;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (map.staggerAxis == tiled.StaggerAxis.y) {
        if ((ty.isOdd && map.staggerIndex == tiled.StaggerIndex.odd) ||
            (ty.isEven && map.staggerIndex == tiled.StaggerIndex.even)) {
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

        final tile = map.tileByGid(tileGid.tile);
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        // Tiles shift up and down as we move across the row.
        if (map.staggerAxis == tiled.StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == tiled.StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == tiled.StaggerIndex.even)) {
            staggerY = halfDestinationTile.y;
          } else {
            staggerY = 0.0;
          }
        }

        final src = tileset.computeDrawRect(tile).toRect();
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
        if (map.staggerAxis == tiled.StaggerAxis.y) {
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
        if (map.staggerAxis == tiled.StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(TileTransform(src, transform, flips.flip, batch));
        } else {
          batch.addTransform(
            source: src,
            transform: transform,
            flip: flips.flip,
          );
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
    final batchMap = _cachedSpriteBatches;
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
    if (map.staggerAxis == tiled.StaggerAxis.y) {
      staggerY = size.y * 0.75;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (map.staggerAxis == tiled.StaggerAxis.x) {
      staggerX = size.x * 0.75;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (map.staggerAxis == tiled.StaggerAxis.y) {
        if ((ty.isOdd && map.staggerIndex == tiled.StaggerIndex.odd) ||
            (ty.isEven && map.staggerIndex == tiled.StaggerIndex.even)) {
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

        final tile = map.tileByGid(tileGid.tile);
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        // Hexagonal Flat tiles shift up and down as we move across the row.
        if (map.staggerAxis == tiled.StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == tiled.StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == tiled.StaggerIndex.even)) {
            staggerY = halfDestinationTile.y;
          } else {
            staggerY = 0.0;
          }
        }

        final src = tileset.computeDrawRect(tile).toRect();
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
        if (map.staggerAxis == tiled.StaggerAxis.y) {
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
        if (map.staggerAxis == tiled.StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(TileTransform(src, transform, flips.flip, batch));
        } else {
          batch.addTransform(
            source: src,
            transform: transform,
            flip: flips.flip,
          );
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
    canvas.save();

    canvas.translate(offsetX, offsetY);

    if (camera != null) {
      applyParallaxOffset(canvas, camera);
    }

    for (final batch in _cachedSpriteBatches.values) {
      batch.render(canvas, paint: _layerPaint);
    }

    canvas.restore();
  }

  static Future<TileLayer> load(
    tiled.TileLayer layer,
    GroupLayer? parent,
    tiled.TiledMap map,
    Vector2 destTileSize,
  ) async {
    return TileLayer(
      layer,
      parent,
      map,
      destTileSize,
      await _loadImages(map),
    );
  }

  static Future<Map<String, SpriteBatch>> _loadImages(
    tiled.TiledMap map,
  ) async {
    final result = <String, SpriteBatch>{};

    for (final img in map.tiledImages()) {
      final src = img.source;
      if (src != null) {
        result[src] = await SpriteBatch.load(src);
      }
    }

    return result;
  }

  @override
  void handleResize(Vector2 canvasSize) {}
}
