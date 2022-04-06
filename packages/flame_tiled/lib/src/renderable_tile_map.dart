import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:tiled/tiled.dart';
import 'package:xml/xml.dart';

import 'flame_tsx_provider.dart';
import 'simple_flips.dart';

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

  /// Cached [SpriteBatch]es of this map.
  @Deprecated(
    'If you take a direct dependency on batches, use batchesByLayer instead. '
    'This will be removed in flame_tiled v1.4.0',
  )
  Map<String, SpriteBatch> get batches => batchesByLayer.isNotEmpty
      ? batchesByLayer.first
      : <String, SpriteBatch>{};

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
    final map = await _loadMap(contents);
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

  static Future<TiledMap> _loadMap(String contents) async {
    final tsxSourcePaths = XmlDocument.parse(contents)
        .rootElement
        .children
        .whereType<XmlElement>()
        .where((element) => element.name.local == 'tileset')
        .map((e) => e.getAttribute('source'));

    final tsxProviders = await Future.wait(
      tsxSourcePaths
          .where((key) => key != null)
          .map((key) async => FlameTsxProvider.parse(key!)),
    );

    return TileMapParser.parseTmx(
      contents,
      tsxList: tsxProviders.isEmpty ? null : tsxProviders,
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
          if (batch != null) {
            batch.add(
              source: src,
              offset: Vector2(tx * size.x, ty * size.y)
                ..add(layerOffset * size.x / src.width),
              rotation: flips.angle * math.pi / 2,
              scale: size.x / src.width,
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

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  @Deprecated(
    'Use the getLayer() method instead. '
    'This method will be removed in flame_tiled v1.4.0.',
  )
  ObjectGroup getObjectGroupFromLayer(String name) {
    final g = map.layers.firstWhere((layer) {
      return layer is ObjectGroup && layer.name == name;
    });
    return g as ObjectGroup;
  }

  /// Returns a layer of type [T] with given [name] from all the layers
  /// of this map. If no such layer is found, null is returned.
  T? getLayer<T extends Layer>(String name) {
    return map.layers
        .firstWhereOrNull((layer) => layer is T && layer.name == name) as T?;
  }
}
