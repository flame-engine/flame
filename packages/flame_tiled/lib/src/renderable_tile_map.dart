import 'dart:math' as math;

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

  /// Cached [SpriteBatch]es of this map.
  final Map<String, SpriteBatch> batches;

  /// The size of tile to be rendered on the game.
  final Vector2 destTileSize;

  /// Cached list of [SpriteBatch]es, ordered by layer.
  final List<Map<String, SpriteBatch>>? batchesByLayer;

  /// {@macro _renderable_tiled_map}
  RenderableTiledMap(
    this.map,
    this.batches,
    this.destTileSize, [
    this.batchesByLayer,
  ]) {
    _fillBatches();
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
    final batches = await _loadImages(map);
    final batchesByLayer = await Future.wait(
      _renderableTileLayers(map).map((e) => _deepCopySpriteBatchMap(batches)),
    );

    return RenderableTiledMap(map, batches, destTileSize, batchesByLayer);
  }

  static Iterable<TileLayer> _renderableTileLayers(TiledMap map) =>
      map.layers.where((layer) => layer.visible).whereType<TileLayer>();

  static Future<TiledMap> _loadMap(String contents) async {
    final tsxSourcePath = XmlDocument.parse(contents)
        .rootElement
        .children
        .whereType<XmlElement>()
        .firstWhere((element) => element.name.local == 'tileset')
        .getAttribute('source');

    TsxProvider? tsxProvider;
    if (tsxSourcePath != null) {
      tsxProvider = await FlameTsxProvider.parse(tsxSourcePath);
    } else {
      tsxProvider = null;
    }
    return TileMapParser.parseTmx(contents, tsx: tsxProvider);
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

  static Future<Map<String, SpriteBatch>> _deepCopySpriteBatchMap(
    Map<String, SpriteBatch> copyFrom,
  ) async {
    final result = <String, SpriteBatch>{};

    await Future.forEach(copyFrom.keys, (String src) async {
      result[src] = await SpriteBatch.load(src);
    });
    return result;
  }

  void _fillBatches() {
    if (batchesByLayer == null) {
      for (final batch in batches.keys) {
        batches[batch]!.clear();
      }
    } else {
      batchesByLayer!.forEach(
        (batchMap) => batchMap.values.forEach((batch) => batch.clear),
      );
    }

    var layerInd = 0;
    _renderableTileLayers(map)
        .map((e) => e.tileData)
        .whereType<List<List<Gid>>>()
        .forEach(
          (List<List<Gid>> tileData) async => _renderLayer(
            tileData,
            batchesByLayer != null ? batchesByLayer![layerInd++] : batches,
          ),
        );
  }

  void _renderLayer(
    List<List<Gid>> tileData,
    Map<String, SpriteBatch> batchMap,
  ) {
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
              offset: Vector2(tx * size.x, ty * size.y),
              rotation: flips.angle * math.pi / 2,
              scale: size.x / src.width,
            );
          }
        }
      });
    });
  }

  /// Render all [batches] that compose this tile map.
  void render(Canvas c) {
    if (batchesByLayer != null) {
      batchesByLayer!.forEach((batchMap) {
        batchMap.forEach((_, batch) => batch.render(c));
      });
    } else {
      batches.forEach((_, batch) => batch.render(c));
    }
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  ObjectGroup getObjectGroupFromLayer(String name) {
    final g = map.layers.firstWhere((layer) {
      return layer is ObjectGroup && layer.name == name;
    });
    return g as ObjectGroup;
  }
}
