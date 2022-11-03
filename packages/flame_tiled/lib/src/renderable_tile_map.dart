import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/src/flame_tsx_provider.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/image_layer.dart';
import 'package:flame_tiled/src/renderable_layers/object_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flame_tiled/src/tile_stack.dart';
import 'package:flutter/painting.dart';
import 'package:tiled/tiled.dart';

/// {@template _renderable_tiled_map}
/// This is a wrapper over Tiled's [TiledMap] which can be rendered to a
/// canvas.
///
/// Internally each layer is wrapped with a [RenderableLayer] which handles
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
  final List<RenderableLayer> renderableLayers;

  /// The target size for each tile in the tiled map.
  final Vector2 destTileSize;

  /// Camera used for determining the current viewport for layer rendering.
  /// Optional, but required for parallax support
  Camera? camera;

  /// Paint for the map's background color, if there is one
  late final Paint? _backgroundPaint;

  final Map<Tile, TileFrames> animationFrames;

  /// {@macro _renderable_tiled_map}
  RenderableTiledMap(
    this.map,
    this.renderableLayers,
    this.destTileSize, {
    this.camera,
    this.animationFrames = const {},
  }) {
    _refreshCache();

    final backgroundColor = map.backgroundColor;
    if (backgroundColor != null) {
      _backgroundPaint = Paint();
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
  Gid? getTileData({
    required int layerId,
    required int x,
    required int y,
  }) {
    final layer = map.layers[layerId];
    if (layer is TileLayer) {
      return layer.tileData?[y][x];
    }
    return null;
  }

  /// Select a group of tiles from the coordinates [x] and [y].
  ///
  /// If [all] is set to true, every renderable tile from the map is collected.
  ///
  /// If the [named] or [ids] sets are not empty, any layer with matching
  /// name or id will have their renderable tiles collected. If the matching
  /// layer is a group layer, all layers in the group will have their tiles
  /// collected.
  TileStack tileStack(
    int x,
    int y, {
    Set<String> named = const <String>{},
    Set<int> ids = const <int>{},
    bool all = false,
  }) {
    return TileStack(
      _tileStack(
        renderableLayers,
        x,
        y,
        named: named,
        ids: ids,
        all: all,
      ),
    );
  }

  /// Recursive support for [tileStack]
  List<MutableRSTransform> _tileStack(
    List<RenderableLayer> layers,
    int x,
    int y, {
    Set<String> named = const <String>{},
    Set<int> ids = const <int>{},
    bool all = false,
  }) {
    final tiles = <MutableRSTransform>[];
    for (final layer in layers) {
      if (layer is GroupLayer) {
        // if the group matches named or ids; grab every child.
        // else descend and ask for named children.
        tiles.addAll(
          _tileStack(
            layer.children,
            x,
            y,
            named: named,
            ids: ids,
            all: all ||
                named.contains(layer.layer.name) ||
                ids.contains(layer.layer.id),
          ),
        );
      } else if (layer is FlameTileLayer) {
        if (!(all ||
            named.contains(layer.layer.name) ||
            ids.contains(layer.layer.id))) {
          continue;
        }

        if (layer.indexes[x][y] != null) {
          tiles.add(layer.indexes[x][y]!);
        }
      }
    }
    return tiles;
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
    // We're not going to load animation frames that are never referenced; but
    // we do supply the common cache for all layers in this map, and maintain
    // the update cycle for these in one place.
    final animationFrames = <Tile, TileFrames>{};

    // While this _should_ not be needed - it is possible have tilesets out of
    // order and Tiled won't complain, but we'll fail.
    map.tilesets.sort((l, r) => (l.firstGid ?? 0) - (r.firstGid ?? 0));

    final renderableLayers = await _renderableLayers(
      map.layers,
      null,
      map,
      destTileSize,
      camera,
      animationFrames,
      atlas: await TiledAtlas.fromTiledMap(map),
    );

    return RenderableTiledMap(
      map,
      renderableLayers,
      destTileSize,
      camera: camera,
      animationFrames: animationFrames,
    );
  }

  static Future<List<RenderableLayer<Layer>>> _renderableLayers(
    List<Layer> layers,
    GroupLayer? parent,
    TiledMap map,
    Vector2 destTileSize,
    Camera? camera,
    Map<Tile, TileFrames> animationFrames, {
    required TiledAtlas atlas,
  }) async {
    final renderLayers = <RenderableLayer<Layer>>[];
    for (final layer in layers.where((layer) => layer.visible)) {
      switch (layer.runtimeType) {
        case TileLayer:
          renderLayers.add(
            await FlameTileLayer.load(
              layer as TileLayer,
              parent,
              map,
              destTileSize,
              animationFrames,
              atlas.clone(),
            ),
          );
          break;
        case ImageLayer:
          renderLayers.add(
            await FlameImageLayer.load(
              layer as ImageLayer,
              parent,
              camera,
              map,
              destTileSize,
            ),
          );
          break;

        case Group:
          final groupLayer = layer as Group;
          final renderableGroup = GroupLayer(
            groupLayer,
            parent,
            map,
            destTileSize,
          );
          renderableGroup.children = await _renderableLayers(
            groupLayer.layers,
            renderableGroup,
            map,
            destTileSize,
            camera,
            animationFrames,
            atlas: atlas,
          );
          renderLayers.add(renderableGroup);
          break;

        case ObjectGroup:
          renderLayers.add(
            await ObjectLayer.load(
              layer as ObjectGroup,
              map,
              destTileSize,
            ),
          );
          break;

        default:
          assert(false, '$layer layer is unsupported.');
          renderLayers.add(
            UnsupportedLayer(layer, parent, map, destTileSize),
          );
          break;
      }
    }
    return renderLayers;
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

  void update(double dt) {
    // First, update animation frames.
    for (final frame in animationFrames.values) {
      frame.update(dt);
    }

    // Then every layer.
    for (final layer in renderableLayers) {
      layer.update(dt);
    }
  }
}
