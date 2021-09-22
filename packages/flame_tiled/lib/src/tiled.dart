import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart';

import 'flame_tsx_provider.dart';
import 'simple_flips.dart';

/// This component renders a tile map based on a TMX file from Tiled.
class RenderableTiledMap {
  static Paint paint = Paint()..color = Colors.white;

  TiledMap map;
  Map<String, SpriteBatch> batches;
  Vector2 destTileSize;

  RenderableTiledMap(
    this.map,
    this.batches,
    this.destTileSize,
  );

  static Future<RenderableTiledMap> parse(
    String fileName,
    Vector2 destTileSize,
  ) async {
    final map = await _loadMap(fileName);
    final batches = await _loadImages(map);
    generate(map, batches, destTileSize);

    return RenderableTiledMap(map, batches, destTileSize);
  }

  static XmlDocument _parseXml(String input) => XmlDocument.parse(input);

  static Future<TiledMap> _loadMap(String fileName) async {
    String file = await Flame.bundle.loadString('assets/tiles/$fileName');
    final tsxSourcePath = _parseXml(file)
        .rootElement
        .children
        .whereType<XmlElement>()
        .firstWhere((element) => element.name.local == 'tileset')
        .getAttribute('source');
    if (tsxSourcePath != null) {
      final tsxProvider = FlameTsxProvider(tsxSourcePath);
      await tsxProvider.initialize();
      return TileMapParser.parseTmx(file, tsx: tsxProvider);
    } else {
      return TileMapParser.parseTmx(file);
    }
  }

  static Future<Map<String, SpriteBatch>> _loadImages(TiledMap map) async {
    final result = <String, SpriteBatch>{};

    await Future.forEach(map.tiledImages(), ((TiledImage img) async {
      String? src = img.source;
      if (src != null) {
        result[src] = await SpriteBatch.load(src);
      }
    }));
    return result;
  }

  /// Generate the sprite batches from the existing tilemap.
  static void generate(
    TiledMap map,
    Map<String, SpriteBatch> batches,
    Vector2 destTileSize,
  ) {
    for (var batch in batches.keys) {
      batches[batch]!.clear();
    }
    _drawTiles(map, batches, destTileSize);
  }

  static void _drawTiles(
    TiledMap map,
    Map<String, SpriteBatch> batches,
    Vector2 destTileSize,
  ) {
    print(batches.keys);
    map.layers.where((layer) => layer.visible).forEach((Layer tileLayer) {
      if (tileLayer is TileLayer) {
        var tileData = tileLayer.tileData;
        if (tileData != null) {
          tileData.asMap().forEach((ty, tileRow) {
            tileRow.asMap().forEach((tx, tile) {
              if (tile.tile == 0) {
                return;
              }
              Tile t = map.tileByGid(tile.tile);
              Tileset ts = map.tilesetByTileGId(tile.tile);
              TiledImage? img = t.image ?? ts.image;
              if (img != null) {
                final batch = batches[img.source];
                final src = ts.computeDrawRect(t).toRect();
                final flips = SimpleFlips.fromFlips(tile.flips);
                final size = destTileSize;
                if (batch != null) {
                  batch.add(
                    source: src,
                    offset: Vector2(
                      tx * size.x + (tile.flips.horizontally ? size.x : 0),
                      ty * size.y + (tile.flips.vertically ? size.y : 0),
                    ),
                    rotation: flips.angle * math.pi / 2,
                    scale: size.x / src.width,
                  );
                }
              }
            });
          });
        }
      }
    });
  }

  void render(Canvas c) {
    batches.forEach((_, batch) => batch.render(c));
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  ObjectGroup getObjectGroupFromLayer(String name) {
    var g = map.layers
        .firstWhere((layer) => layer is ObjectGroup && layer.name == name);
    return g as ObjectGroup;
  }
}
