part of '../renderable_tile_map.dart';

class _RenderableTileLayer extends _RenderableLayer<TileLayer> {
  final TiledMap _map;
  final Vector2 _destTileSize;
  late final _layerPaint = ui.Paint();
  late final Map<String, SpriteBatch> _cachedSpriteBatches;

  _RenderableTileLayer(
    super.layer,
    super.parent,
    this._map,
    this._destTileSize,
    this._cachedSpriteBatches,
  ) {
    _layerPaint.color = Color.fromRGBO(255, 255, 255, opacity);
  }

  @override
  void refreshCache() {
    _cacheLayerTiles();
  }

  void _cacheLayerTiles() {
    for (final batch in _cachedSpriteBatches.values) {
      batch.clear();
    }

    if (_map.orientation == null) {
      return;
    }

    switch (_map.orientation!) {
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
    final batchMap = _cachedSpriteBatches;
    final size = _destTileSize;

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = _map.tileByGid(tileGid.tile);
        final tileset = _map.tilesetByTileGId(tileGid.tile);
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

        batch.addTransform(
          source: src,
          transform: ui.RSTransform(
            scos,
            ssin,
            offsetX + -scos * anchorX + ssin * anchorY,
            offsetY + -ssin * anchorX - scos * anchorY,
          ),
          flip: flips.flip,
        );
      }
    }
  }

  void _cacheIsometricTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    final halfDestinationTile = _destTileSize / 2;
    final size = _destTileSize;
    final isometricXShift = _map.width * size.x * 0.5;

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = _map.tileByGid(tileGid.tile);
        final tileset = _map.tilesetByTileGId(tileGid.tile);
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

        batch.addTransform(
          source: src,
          transform: ui.RSTransform(
            scos,
            ssin,
            offsetX + -scos * anchorX + ssin * anchorY,
            offsetY + -ssin * anchorX - scos * anchorY,
          ),
          flip: flips.flip,
        );
      }
    }
  }

  void _cacheIsometricStaggeredTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    final halfDestinationTile = _destTileSize / 2;
    final size = _destTileSize;
    final halfMapTile = Vector2(_map.tileWidth / 2, _map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
    if (_map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.5;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (_map.staggerAxis == StaggerAxis.x) {
      staggerX = size.x * 0.5;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (_map.staggerAxis == StaggerAxis.y) {
        if ((ty.isOdd && _map.staggerIndex == StaggerIndex.odd) ||
            (ty.isEven && _map.staggerIndex == StaggerIndex.even)) {
          staggerX = halfDestinationTile.x;
        } else {
          staggerX = 0.0;
        }
      }

      // When staggering in the X axis, we need to hold painting of "lower"
      // tiles (those with staggerY adjustments) otherwise they'll just get
      // painted over. See the second pass loop after tx.
      final xSecondPass = <_Transform>[];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = _map.tileByGid(tileGid.tile);
        final tileset = _map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        // Tiles shift up and down as we move across the row.
        if (_map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && _map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && _map.staggerIndex == StaggerIndex.even)) {
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
        if (_map.staggerAxis == StaggerAxis.y) {
          offsetX = tx * size.x + staggerX + halfDestinationTile.x;
          offsetY = ty * staggerY + halfDestinationTile.y;
        } else {
          offsetX = tx * staggerX + halfDestinationTile.x;
          offsetY = ty * size.y + staggerY + halfDestinationTile.y;
        }

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        final transform = ui.RSTransform(
          scos,
          ssin,
          offsetX + -scos * anchorX + ssin * anchorY,
          offsetY + -ssin * anchorX - scos * anchorY,
        );

        // A second pass is only needed in the case of staggery.
        if (_map.staggerAxis == StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(_Transform(src, transform, flips.flip, batch));
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
    final halfDestinationTile = _destTileSize / 2;
    final size = _destTileSize;
    final halfMapTile = Vector2(_map.tileWidth / 2, _map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
    if (_map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.75;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (_map.staggerAxis == StaggerAxis.x) {
      staggerX = size.x * 0.75;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (_map.staggerAxis == StaggerAxis.y) {
        if ((ty.isOdd && _map.staggerIndex == StaggerIndex.odd) ||
            (ty.isEven && _map.staggerIndex == StaggerIndex.even)) {
          staggerX = halfDestinationTile.x;
        } else {
          staggerX = 0.0;
        }
      }

      // When staggering in the X axis, we need to hold painting of "lower"
      // tiles (those with staggerY adjustments) otherwise they'll just get
      // painted over. See the second pass loop after tx.
      final xSecondPass = <_Transform>[];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

        final tile = _map.tileByGid(tileGid.tile);
        final tileset = _map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img == null) {
          continue;
        }

        final batch = batchMap[img.source];
        if (batch == null) {
          continue;
        }

        // Hexagonal Flat tiles shift up and down as we move across the row.
        if (_map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && _map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && _map.staggerIndex == StaggerIndex.even)) {
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
        if (_map.staggerAxis == StaggerAxis.y) {
          offsetX = tx * size.x + staggerX + halfDestinationTile.x;
          offsetY = ty * staggerY + halfDestinationTile.y;
        } else {
          offsetX = tx * staggerX + halfDestinationTile.x;
          offsetY = ty * size.y + staggerY + halfDestinationTile.y;
        }

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        final transform = ui.RSTransform(
          scos,
          ssin,
          offsetX + -scos * anchorX + ssin * anchorY,
          offsetY + -ssin * anchorX - scos * anchorY,
        );

        // A second pass is only needed in the case of staggery.
        if (_map.staggerAxis == StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(_Transform(src, transform, flips.flip, batch));
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
      _applyParallaxOffset(canvas, camera);
    }

    for (final batch in _cachedSpriteBatches.values) {
      batch.render(canvas, paint: _layerPaint);
    }

    canvas.restore();
  }

  static Future<_RenderableLayer> load(
    TileLayer layer,
    _RenderableGroupLayer? parent,
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    return _RenderableTileLayer(
      layer,
      parent,
      map,
      destTileSize,
      await _loadImages(map),
    );
  }

  static Future<Map<String, SpriteBatch>> _loadImages(TiledMap map) async {
    final result = <String, SpriteBatch>{};

    for (final img in map.tiledImages()) {
      final src = img.source;
      if (src != null) {
        result[src] = await SpriteBatch.load(src);
      }
    }

    return result;
  }
}
