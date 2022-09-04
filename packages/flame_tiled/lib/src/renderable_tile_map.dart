import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
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

  /// Camera used for determining the current viewport for layer rendering.
  /// Optional, but required for parallax support
  Camera? camera;

  /// Paint for the map's background color, if there is one
  late final ui.Paint? _backgroundPaint;

  /// {@macro _renderable_tiled_map}
  RenderableTiledMap(
    this.map,
    this.renderableLayers, {
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
            );

          case Group:
            final groupLayer = layer as Group;
            final childrenCompleter = Completer<List<_RenderableLayer>>();
            final renderableGroup = _RenderableGroupLayer.load(
              groupLayer,
              parent,
              camera,
              childrenCompleter.future,
            );
            final children = _renderableLayers(
              groupLayer.layers,
              await renderableGroup,
              map,
              destTileSize,
              camera,
            );
            childrenCompleter.complete(await children);
            return renderableGroup;

          default:
            return _UnrenderableLayer.load(layer);
        }
      }),
    );
  }

  /// Handle game resize and propagate it to renderable layers
  void handleResize(Vector2 canvasSize) {
    renderableLayers.forEach((rl) {
      rl.handleResize(canvasSize);
    });
  }

  /// Rebuilds the cache for rendering
  void _refreshCache() {
    renderableLayers.forEach((rl) {
      rl.refreshCache();
    });
  }

  /// Renders each renderable layer in the same order specified by the Tiled map
  void render(Canvas c) {
    if (_backgroundPaint != null) {
      c.drawPaint(_backgroundPaint!);
    }

    // paint each layer in reverse order, because the last layers should be
    // rendered beneath the first layers
    renderableLayers.where((l) => l.visible).forEach((renderableLayer) {
      renderableLayer.render(c, camera);
    });
  }

  /// Returns a layer of type [T] with given [name] from all the layers
  /// of this map. If no such layer is found, null is returned.
  T? getLayer<T extends Layer>(String name) {
    return map.layers
        .firstWhereOrNull((layer) => layer is T && layer.name == name) as T?;
  }
}

abstract class _RenderableLayer<T extends Layer> {
  final T layer;

  /// The parent [Group] layer (if it exists)
  final _RenderableGroupLayer? parent;

  _RenderableLayer(this.layer, this.parent);

  bool get visible => layer.visible;

  void render(Canvas canvas, Camera? camera);

  void handleResize(Vector2 canvasSize) {}

  void refreshCache() {}

  double get offsetX {
    if (parent != null) {
      return parent!.offsetX + layer.offsetX;
    } else {
      return layer.offsetX;
    }
  }

  double get offsetY {
    if (parent != null) {
      return parent!.offsetY + layer.offsetY;
    } else {
      return layer.offsetY;
    }
  }

  double get opacity {
    if (parent != null) {
      return parent!.opacity * layer.opacity;
    } else {
      return layer.opacity;
    }
  }

  double get parallaxX {
    if (parent != null) {
      return parent!.parallaxX * layer.parallaxX;
    } else {
      return layer.parallaxX;
    }
  }

  double get parallaxY {
    if (parent != null) {
      return parent!.parallaxY * layer.parallaxY;
    } else {
      return layer.parallaxY;
    }
  }

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
    _cacheLayerTiles();
  }

  @override
  void refreshCache() {
    _cacheLayerTiles();
  }

  void _cacheLayerTiles() {
    final tileData = layer.tileData!;
    final batchMap = _cachedSpriteBatches;
    tileData.asMap().forEach((ty, tileRow) {
      tileRow.asMap().forEach((tx, tileGid) {
        if (tileGid.tile == 0) {
          return;
        }
        final tile = _map.tileByGid(tileGid.tile);
        final tileset = _map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;
        if (img != null) {
          final batch = batchMap[img.source];
          final src = tileset.computeDrawRect(tile).toRect();
          final flips = SimpleFlips.fromFlips(tileGid.flips);
          final size = _destTileSize;
          final scale = size.x / src.width;
          final anchorX = src.width / 2;
          final anchorY = src.height / 2;
          final offsetX = ((tx + .5) * size.x) + (this.offsetX * scale);
          final offsetY = ((ty + .5) * size.y) + (this.offsetY * scale);
          final scos = flips.cos * scale;
          final ssin = flips.sin * scale;
          if (batch != null) {
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
      });
    });
  }

  @override
  void render(Canvas canvas, Camera? camera) {
    canvas.save();

    if (camera != null) {
      _applyParallaxOffset(canvas, camera);
    }

    _cachedSpriteBatches.values.forEach((batch) {
      batch.render(canvas, paint: _layerPaint);
    });

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

    await Future.forEach(map.tiledImages(), (TiledImage img) async {
      final src = img.source;
      if (src != null) {
        result[src] = await SpriteBatch.load(src);
      }
    });

    return result;
  }
}

class _RenderableImageLayer extends _RenderableLayer<ImageLayer> {
  final Image _image;
  late final ImageRepeat _repeat;
  Rect _paintArea = Rect.zero;

  _RenderableImageLayer(super.layer, super.parent, this._image) {
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
  ) async {
    return _RenderableImageLayer(
      layer,
      parent,
      await Flame.images.load(layer.image.source!),
    );
  }
}

class _RenderableGroupLayer extends _RenderableLayer<Group> {
  late final List<_RenderableLayer> children;

  _RenderableGroupLayer(
    super.layer,
    super.parent,
    Future<List<_RenderableLayer>> futureChildren,
  ) {
    futureChildren.then((children) => this.children = children);
  }

  @override
  void render(ui.Canvas canvas, Camera? camera) {
    children.forEach((child) {
      child.render(canvas, camera);
    });
  }

  static Future<_RenderableGroupLayer> load(
    Group layer,
    _RenderableGroupLayer? parent,
    Camera? camera,
    Future<List<_RenderableLayer>> children,
  ) async {
    return _RenderableGroupLayer(layer, parent, children);
  }
}

class _UnrenderableLayer extends _RenderableLayer {
  _UnrenderableLayer(super.layer, super.parent);

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore unrenderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<_RenderableLayer> load(Layer layer) async {
    return _UnrenderableLayer(layer, null);
  }
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
