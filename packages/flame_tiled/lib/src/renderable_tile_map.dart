import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/src/flame_tsx_provider.dart';
import 'package:flame_tiled/src/simple_flips.dart';
import 'package:tiled/tiled.dart';

/// {@template _renderable_tiled_map}
/// This is a wrapper over Tiled's [TiledMap] with pre-computed SpriteBatches
/// for rendering each layer of the map.
/// {@endtemplate}
class RenderableTiledMap {
  /// [TiledMap] instance for this map.
  final TiledMap map;

  /// The size of tile to be rendered on the game.
  final Vector2 destTileSize;

  /// Cached list of [SpriteBatch]es, ordered by layer.
  final List<Map<String, SpriteBatch>> batchesByLayer;

  /// {@macro _renderable_tiled_map}
  RenderableTiledMap(
    this.map,
    this.batchesByLayer,
    this.destTileSize,
  ) {
    refreshCache();
  }

  /// Changes the visibility of the corresponding layer, if different
  void setLayerVisibility(int layerId, bool visibility) {
    if (map.layers[layerId].visible != visibility) {
      map.layers[layerId].visible = visibility;
      refreshCache();
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
          refreshCache();
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
    Vector2 destTileSize,
  ) async {
    final contents = await Flame.bundle.loadString('assets/tiles/$fileName');
    return fromString(contents, destTileSize);
  }

  /// Parses a string returning a [RenderableTiledMap].
  static Future<RenderableTiledMap> fromString(
    String contents,
    Vector2 destTileSize,
  ) async {
    final map = await TiledMap.fromString(
      contents,
      FlameTsxProvider.parse,
    );
    return fromTiledMap(map, destTileSize);
  }

  /// Parses a [TiledMap] returning a [RenderableTiledMap].
  static Future<RenderableTiledMap> fromTiledMap(
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    final batchesByLayer = await Future.wait(
      _renderableTileLayers(map).map((e) => _loadImages(map)),
    );

    return RenderableTiledMap(
      map,
      batchesByLayer,
      destTileSize,
    );
  }

  static Iterable<TileLayer> _renderableTileLayers(TiledMap map) {
    return map.layers.where((layer) => layer.visible).whereType<TileLayer>();
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

  /// Rebuilds the cache for rendering
  void refreshCache() {
    batchesByLayer.forEach(
      (batchMap) => batchMap.values.forEach((batch) => batch.clear()),
    );

    _renderableTileLayers(map)
        .where((e) => e.tileData != null)
        .forEachIndexed((mapIndex, layer) {
      return _renderLayer(
        mapIndex,
        layer.tileData!,
        Vector2(layer.offsetX, layer.offsetY),
      );
    });
  }

  void _renderLayer(
    int mapIndex,
    List<List<Gid>> tileData,
    Vector2 layerOffset,
  ) {
    final batchMap = batchesByLayer.elementAt(mapIndex);
    tileData.asMap().forEach((ty, tileRow) {
      tileRow.asMap().forEach((tx, tile) {
        if (tile.tile == 0) {
          return;
        }
        final t = map.tileByGid(tile.tile);
        final ts = map.tilesetByTileGId(tile.tile);
        final img = t.image ?? ts.image;
        if (img != null) {
          final batch = batchMap[img.source];
          final src = ts.computeDrawRect(t).toRect();
          final flips = SimpleFlips.fromFlips(tile.flips);
          final size = destTileSize;
          final scale = size.x / src.width;
          final anchorX = src.width / 2;
          final anchorY = src.height / 2;
          final offsetX = ((tx + .5) * size.x) + (layerOffset.x * scale);
          final offsetY = ((ty + .5) * size.y) + (layerOffset.y * scale);
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

  /// Render [batchesByLayer] that compose this tile map.
  void render(Canvas c) {
    batchesByLayer.forEach((batchMap) {
      batchMap.forEach((_, batch) => batch.render(c));
    });
  }

  /// Returns a layer of type [T] with given [name] from all the layers
  /// of this map. If no such layer is found, null is returned.
  T? getLayer<T extends Layer>(String name) {
    return map.layers
        .firstWhereOrNull((layer) => layer is T && layer.name == name) as T?;
  }
}
