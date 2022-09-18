import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/src/flame_tsx_provider.dart';
import 'package:flame_tiled/src/simple_flips.dart';
import 'package:flutter/painting.dart';
import 'package:tiled/tiled.dart';

/// {@template _renderable_tiled_map}
/// This is a wrapper over Tiled's [TiledMap] which can be rendered to a canvas.
///
/// Internally each layer is wrapped with a [_RenderableLayer] which handles
/// rendering and caching for supported layer types:
///  - [TileLayer] is supported with pre-computed SpriteBatches
///  - [ImageLayer] is supported with [paintImage]
///
/// This also supports the following properties:
///  - [TiledMap.backgroundColor]
///  - [Layer.opacity]
///  - [Layer.offsetX]
///  - [Layer.offsetY]
///  - [Layer.parallaxX] (only supported if [Camera] is supplied)
///  - [Layer.parallaxY] (only supported if [Camera] is supplied)
///
/// {@endtemplate}
class RenderableTiledMap {
  /// [TiledMap] instance for this map.
  final TiledMap map;

  /// Layers to be rendered, in the same order as [TiledMap.layers]
  final List<_RenderableLayer> renderableLayers;

  /// The target size for each tile in the tiled map.
  final Vector2 destTileSize;

  /// Camera used for determining the current viewport for layer rendering.
  /// Optional, but required for parallax support
  Camera? camera;

  /// Paint for the map's background color, if there is one
  late final ui.Paint? _backgroundPaint;

  /// {@macro _renderable_tiled_map}
  RenderableTiledMap(
    this.map,
    this.renderableLayers,
    this.destTileSize, {
    this.camera,
  }) {
    _refreshCache();

    final backgroundColor = _parseTiledColor(map.backgroundColor);
    if (backgroundColor != null) {
      _backgroundPaint = ui.Paint();
      _backgroundPaint!.color = backgroundColor;
    } else {
      _backgroundPaint = null;
    }
  }

  /// Changes the visibility of the corresponding layer, if different
  void setLayerVisibility(int layerId, bool visibility) {
    if (map.layers[layerId].visible != visibility) {
      map.layers[layerId].visible = visibility;
      _refreshCache();
    }
  }

  /// Gets the visibility of the corresponding layer
  bool getLayerVisibility(int layerId) {
    return map.layers[layerId].visible;
  }

  /// Changes the Gid of the corresponding layer at the given position,
  /// if different
  void setTileData({
    required int layerId,
    required int x,
    required int y,
    required Gid gid,
  }) {
    final layer = map.layers[layerId];
    if (layer is TileLayer) {
      final td = layer.tileData;
      if (td != null) {
        if (td[y][x].tile != gid.tile ||
            td[y][x].flips.horizontally != gid.flips.horizontally ||
            td[y][x].flips.vertically != gid.flips.vertically ||
            td[y][x].flips.diagonally != gid.flips.diagonally) {
          td[y][x] = gid;
          _refreshCache();
        }
      }
    }
  }

  /// Gets the Gid  of the corresponding layer at the given position
  Gid? getTileData({required int layerId, required int x, required int y}) {
    final layer = map.layers[layerId];
    if (layer is TileLayer) {
      return layer.tileData?[y][x];
    }
    return null;
  }

  /// Parses a file returning a [RenderableTiledMap].
  ///
  /// NOTE: this method looks for files under the path "assets/tiles/".
  static Future<RenderableTiledMap> fromFile(
    String fileName,
    Vector2 destTileSize, {
    Camera? camera,
  }) async {
    final contents = await Flame.bundle.loadString('assets/tiles/$fileName');
    return fromString(contents, destTileSize, camera: camera);
  }

  /// Parses a string returning a [RenderableTiledMap].
  static Future<RenderableTiledMap> fromString(
    String contents,
    Vector2 destTileSize, {
    Camera? camera,
  }) async {
    final map = await TiledMap.fromString(
      contents,
      FlameTsxProvider.parse,
    );
    return fromTiledMap(map, destTileSize, camera: camera);
  }

  /// Parses a [TiledMap] returning a [RenderableTiledMap].
  static Future<RenderableTiledMap> fromTiledMap(
    TiledMap map,
    Vector2 destTileSize, {
    Camera? camera,
  }) async {
    final renderableLayers =
        await _renderableLayers(map.layers, null, map, destTileSize, camera);

    return RenderableTiledMap(
      map,
      renderableLayers,
      destTileSize,
      camera: camera,
    );
  }

  static Future<List<_RenderableLayer<Layer>>> _renderableLayers(
    List<Layer> layers,
    _RenderableGroupLayer? parent,
    TiledMap map,
    Vector2 destTileSize,
    Camera? camera,
  ) async {
    return Future.wait(
      layers.where((layer) => layer.visible).toList().map((layer) async {
        switch (layer.runtimeType) {
          case TileLayer:
            return _RenderableTileLayer.load(
              layer as TileLayer,
              parent,
              map,
              destTileSize,
            );
          case ImageLayer:
            return _RenderableImageLayer.load(
              layer as ImageLayer,
              parent,
              camera,
              map,
              destTileSize,
            );

          case Group:
            final groupLayer = layer as Group;
            final renderableGroup = _RenderableGroupLayer(
              groupLayer,
              parent,
              map,
              destTileSize,
            );
            final children = _renderableLayers(
              groupLayer.layers,
              renderableGroup,
              map,
              destTileSize,
              camera,
            );
            renderableGroup.children = await children;
            return renderableGroup;

          default:
            return _UnrenderableLayer.load(
              layer,
              map,
              destTileSize,
            );
        }
      }),
    );
  }

  /// Handle game resize and propagate it to renderable layers
  void handleResize(Vector2 canvasSize) {
    for (final layer in renderableLayers) {
      layer.handleResize(canvasSize);
    }
  }

  /// Rebuilds the cache for rendering
  void _refreshCache() {
    for (final layer in renderableLayers) {
      layer.refreshCache();
    }
  }

  /// Renders each renderable layer in the same order specified by the Tiled map
  void render(Canvas c) {
    if (_backgroundPaint != null) {
      c.drawPaint(_backgroundPaint!);
    }

    // Paint each layer in reverse order, because the last layers should be
    // rendered beneath the first layers
    for (final layer in renderableLayers.where((l) => l.visible)) {
      layer.render(c, camera);
    }
  }

  /// Returns a layer of type [T] with given [name] from all the layers
  /// of this map. If no such layer is found, null is returned.
  T? getLayer<T extends Layer>(String name) {
    try {
      // layerByName will searches recursively starting with tiled.dart v0.8.5
      return map.layerByName(name) as T;
    } on ArgumentError {
      return null;
    }
  }
}

abstract class _RenderableLayer<T extends Layer> {
  final T layer;
  final Vector2 destTileSize;
  final TiledMap map;

  /// The parent [Group] layer (if it exists)
  final _RenderableGroupLayer? parent;

  _RenderableLayer(
    this.layer,
    this.parent,
    this.map,
    this.destTileSize,
  );

  bool get visible => layer.visible;

  void render(Canvas canvas, Camera? camera);

  void handleResize(Vector2 canvasSize);

  void refreshCache();

  double get scaleX => destTileSize.x / map.tileWidth;
  double get scaleY => destTileSize.y / map.tileHeight;

  late double offsetX = layer.offsetX * scaleX + (parent?.offsetX ?? 0);

  late double offsetY = layer.offsetY * scaleY + (parent?.offsetY ?? 0);

  late double opacity = layer.opacity * (parent?.opacity ?? 1);

  late double parallaxX = layer.parallaxX * (parent?.parallaxX ?? 1);

  late double parallaxY = layer.parallaxY * (parent?.parallaxY ?? 1);

  /// Calculates the offset we need to apply to the canvas to compensate for
  /// parallax positioning and scroll for the layer and the current camera
  /// position
  /// https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  void _applyParallaxOffset(Canvas canvas, Camera camera) {
    final cameraX = camera.position.x;
    final cameraY = camera.position.y;
    final vpCenterX = camera.viewport.effectiveSize.x / 2;
    final vpCenterY = camera.viewport.effectiveSize.y / 2;

    // Due to how Tiled treats the center of the view as the reference
    // point for parallax positioning (see Tiled docs), we need to offset the
    // entire layer
    var x = (1 - parallaxX) * vpCenterX;
    var y = (1 - parallaxY) * vpCenterY;
    // compensate the offset for zoom
    x /= camera.zoom;
    y /= camera.zoom;

    // Now add the scroll for the current camera position
    x += cameraX - (cameraX * parallaxX);
    y += cameraY - (cameraY * parallaxY);

    canvas.translate(x, y);
  }
}

class _RenderableTileLayer extends _RenderableLayer<TileLayer> {
  late final _layerPaint = ui.Paint();
  late final Map<String, SpriteBatch> _cachedSpriteBatches;

  _RenderableTileLayer(
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
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
    if (map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.5;
    } else
    // Hexagonal Flat Tiles move right by a fractional amount.
    if (map.staggerAxis == StaggerAxis.x) {
      staggerX = size.x * 0.5;
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
      final xSecondPass = <_Transform>[];

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
        if (map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == StaggerIndex.even)) {
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
        if (map.staggerAxis == StaggerAxis.y) {
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
        if (map.staggerAxis == StaggerAxis.x && staggerY > 0) {
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
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Ponity Tiles move down by a fractional amount.
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
      final xSecondPass = <_Transform>[];

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
        if (map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == StaggerIndex.even)) {
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
        if (map.staggerAxis == StaggerAxis.y) {
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
        if (map.staggerAxis == StaggerAxis.x && staggerY > 0) {
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

  @override
  void handleResize(Vector2 canvasSize) {}
}

class _RenderableImageLayer extends _RenderableLayer<ImageLayer> {
  final Image _image;
  late final ImageRepeat _repeat;
  Rect _paintArea = Rect.zero;

  _RenderableImageLayer(
    super.layer,
    super.parent,
    this._image,
    super.map,
    super.destTileSize,
  ) {
    _initImageRepeat();
  }

  @override
  void handleResize(Vector2 canvasSize) {
    _paintArea = Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y);
  }

  @override
  void render(Canvas canvas, Camera? camera) {
    canvas.save();

    canvas.translate(offsetX, offsetY);

    if (camera != null) {
      _applyParallaxOffset(canvas, camera);
    }

    paintImage(
      canvas: canvas,
      rect: _paintArea,
      image: _image,
      opacity: opacity,
      alignment: Alignment.topLeft,
      repeat: _repeat,
    );

    canvas.restore();
  }

  void _initImageRepeat() {
    if (layer.repeatX && layer.repeatY) {
      _repeat = ImageRepeat.repeat;
    } else if (layer.repeatX) {
      _repeat = ImageRepeat.repeatX;
    } else if (layer.repeatY) {
      _repeat = ImageRepeat.repeatY;
    } else {
      _repeat = ImageRepeat.noRepeat;
    }
  }

  static Future<_RenderableLayer> load(
    ImageLayer layer,
    _RenderableGroupLayer? parent,
    Camera? camera,
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    return _RenderableImageLayer(
      layer,
      parent,
      await Flame.images.load(layer.image.source!),
      map,
      destTileSize,
    );
  }

  @override
  void refreshCache() {}
}

class _RenderableGroupLayer extends _RenderableLayer<Group> {
  /// The child layers of this [Group] to be rendered recursively.
  ///
  /// NOTE: This is set externally instead of via constructor params because
  ///       there are cyclic dependencies when loading the renderable layers.
  late final List<_RenderableLayer> children;

  _RenderableGroupLayer(
    super.layer,
    super.parent,
    super.map,
    super.destTileSize,
  );

  @override
  void refreshCache() {
    for (final child in children) {
      child.refreshCache();
    }
  }

  @override
  void handleResize(Vector2 canvasSize) {
    for (final child in children) {
      child.handleResize(canvasSize);
    }
  }

  @override
  void render(ui.Canvas canvas, Camera? camera) {
    for (final child in children) {
      child.render(canvas, camera);
    }
  }
}

class _UnrenderableLayer extends _RenderableLayer {
  _UnrenderableLayer(
    super.layer,
    super.parent,
    super.map,
    super.destTileSize,
  );

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore unrenderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<_RenderableLayer> load(
    Layer layer,
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    return _UnrenderableLayer(layer, null, map, destTileSize);
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @override
  void refreshCache() {}
}

Color? _parseTiledColor(String? tiledColor) {
  int? colorValue;
  if (tiledColor?.length == 7) {
    // parse '#rrbbgg'  as hex '0xaarrggbb' with the alpha channel on full
    colorValue = int.tryParse(tiledColor!.replaceFirst('#', '0xff'));
  } else if (tiledColor?.length == 9) {
    // parse '#aarrbbgg'  as hex '0xaarrggbb'
    colorValue = int.tryParse(tiledColor!.replaceFirst('#', '0x'));
  }
  if (colorValue != null) {
    return Color(colorValue);
  } else {
    return null;
  }
}

/// Caches transforms for staggered maps as the row/col are switched.
class _Transform {
  final Rect source;
  final ui.RSTransform transform;
  final bool flip;
  final SpriteBatch batch;

  _Transform(
    this.source,
    this.transform,
    this.flip,
    this.batch,
  );
}
