import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:tiled/tiled.dart';
import 'package:xml/xml.dart';

import 'flame_tsx_provider.dart';
import 'simple_flips.dart';

/// This is a wrapper over Tiled's [TiledMap] with pre-computed SpriteBatches
/// for rendering each layer of the map.
class RenderableTiledMap {
  final TiledMap map;
  final Map<String, SpriteBatch> batches;
  final Vector2 destTileSize;

  RenderableTiledMap(
    this.map,
    this.batches,
    this.destTileSize,
  ) {
    _fillBatches();
  }

  static Future<RenderableTiledMap> fromFile(
    String fileName,
    Vector2 destTileSize,
  ) async {
    final contents = await Flame.bundle.loadString('assets/tiles/$fileName');
    return fromString(contents, destTileSize);
  }

  static Future<RenderableTiledMap> fromString(
    String contents,
    Vector2 destTileSize,
  ) async {
    final map = await _loadMap(contents);
    final batches = await _loadImages(map);

    return RenderableTiledMap(map, batches, destTileSize);
  }

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

  void _fillBatches() {
    for (final batch in batches.keys) {
      batches[batch]!.clear();
    }

    map.layers
        .where((layer) => layer.visible)
        .whereType<TileLayer>()
        .map((e) => e.tileData)
        .whereType<List<List<Gid>>>()
        .forEach(_renderLayer);
  }

  void _renderLayer(List<List<Gid>> tileData) {
    tileData.asMap().forEach((ty, tileRow) {
      tileRow.asMap().forEach((tx, tile) {
        if (tile.tile == 0) {
          return;
        }
        final t = map.tileByGid(tile.tile);
        final ts = map.tilesetByTileGId(tile.tile);
        final img = t.image ?? ts.image;
        if (img != null) {
          final batch = batches[img.source];
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
    batches.forEach((_, batch) => batch.render(c));
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
