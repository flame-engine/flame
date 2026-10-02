import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/rendering.dart';
import 'package:flame_tiled/src/extensions.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flame_tiled/src/tile_stack.dart';
import 'package:flame_tiled/src/tiled_component.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:tiled/tiled.dart';

Paint _defaultLayerPaintFactory(double opacity) =>
    Paint()..color = Color.fromRGBO(255, 255, 255, opacity);

/// {@template _renderable_tiled_map}
/// This is a component that renders Tiled's [TiledMap].
///
/// Each layer of the map is wrapped in a [RenderableLayer], which is a child
/// component of this map (or of its group layer), in the same order as in the
/// Tiled map. The layers handle rendering and caching for supported layer
/// types:
///  - [TileLayer] is supported with pre-computed SpriteBatches
///  - [ImageLayer] is supported with [paintImage]
///
/// Since the layers are components, other components can be added to them to
/// render in between the layers of the map, see [getRenderableLayer].
///
/// This also supports the following properties:
///  - [TiledMap.backgroundColor]
///  - [Layer.visible]
///  - [Layer.opacity]
///  - [Layer.offsetX]
///  - [Layer.offsetY]
///  - [Layer.parallaxX]
///  - [Layer.parallaxY]
///
/// The parallax factors are applied against the [CameraComponent] that the map
/// is rendered through, or against [camera] when it is set. A map that is not
/// rendered through a camera, for example one added directly to the game,
/// uses the camera of the game.
///
/// The map draws its layers as children, so when it is rendered outside of a
/// component tree, call [renderTree] and [updateTree] rather than [render]
/// and [update].
///
/// {@endtemplate}
class RenderableTiledMap(
  /// [TiledMap] instance for this map.
  final TiledMap map,

  /// The top level layers of the map, in the same order as [TiledMap.layers].
  ///
  /// The layers nested in a group layer are the children of that group's
  /// [RenderableLayer].
  final List<RenderableLayer> renderableLayers,

  /// The target size for each tile in the tiled map.
  final Vector2 destTileSize, {

  /// The camera that the parallax factors of the layers are calculated
  /// against.
  ///
  /// When this is null, which is the default, the camera that is currently
  /// rendering the map is used, falling back to the camera of the game when
  /// the map is not rendered through a camera. It only needs to be set when
  /// the map is rendered outside of a game.
  var CameraComponent? camera,
  final Map<Tile, TileFrames> animationFrames = const {},
}) extends Component {
  /// The size of the rendered map, see [TiledComponent.computeSize].
  late final Vector2 size = TiledComponent.computeSize(
    map.orientation,
    destTileSize,
    map.tileWidth,
    map.tileHeight,
    map.width,
    map.height,
    map.staggerAxis,
  );

  /// Paint for the map's background color, if there is one
  late final Paint? _backgroundPaint;

  /// {@macro _renderable_tiled_map}
  this {
    _refreshCache();

    final backgroundColor = map.backgroundColor?.toColor();
    if (backgroundColor != null) {
      _backgroundPaint = Paint();
      _backgroundPaint!.color = backgroundColor;
    } else {
      _backgroundPaint = null;
    }

    for (final layer in renderableLayers) {
      add(layer);
    }
  }

  /// Changes the visibility of the corresponding layer, which takes effect on
  /// the next render.
  void setLayerVisibility(int layerId, {required bool visible}) {
    map.layers[layerId].visible = visible;
  }

  /// Gets the visibility of the corresponding layer
  bool getLayerVisibility(int layerId) {
    return map.layers[layerId].visible;
  }

  /// Changes the opacity of the layer at [layerIndex] to [opacity].
  ///
  /// [opacity] must be between 0.0 (fully transparent) and 1.0 (fully opaque).
  void setLayerOpacity(int layerIndex, {required double opacity}) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'opacity must be between 0.0 and 1.0',
    );
    final renderableLayer = renderableLayers[layerIndex];
    renderableLayer.opacity = opacity;
  }

  /// Gets the opacity of the layer at [layerIndex].
  double getLayerOpacity(int layerIndex) {
    return renderableLayers[layerIndex].opacity;
  }

  /// Changes the Gid of the corresponding layer at the given layerId,
  /// if different
  ///
  /// {@template renderable_tile_map_set_tile}
  /// [x] and [y] are the tile coordinates shown in the Tiled editor, which
  /// can be negative on infinite maps. Only cells that exist in the map can
  /// be changed: nothing happens for cells outside of a finite map, or
  /// outside of the chunks of an infinite map.
  /// {@endtemplate}
  void setTileData({
    required int layerId,
    required int x,
    required int y,
    required Gid gid,
  }) {
    final layer = map.layers.firstWhereOrNull((layer) => layer.id == layerId);
    if (layer is TileLayer) {
      if (layer.setTileAt(x, y, gid)) {
        _refreshCache();
      }
    }
  }

  /// Changes the Gid of the corresponding layer at the given position,
  /// if different
  ///
  /// {@macro renderable_tile_map_set_tile}
  void setTileDataByLayerIndex({
    required int layerIndex,
    required int x,
    required int y,
    required Gid gid,
  }) {
    final layer = map.layers[layerIndex];
    if (layer is TileLayer) {
      if (layer.setTileAt(x, y, gid)) {
        _refreshCache();
      }
    }
  }

  /// Gets the Gid  of the corresponding layer at the given layerId
  ///
  /// {@template renderable_tile_map_get_tile}
  /// [x] and [y] are the tile coordinates shown in the Tiled editor, which
  /// can be negative on infinite maps. Returns `null` for cells outside of a
  /// finite map, or outside of the chunks of an infinite map.
  /// {@endtemplate}
  Gid? getTileData({
    required int layerId,
    required int x,
    required int y,
  }) {
    final layer = map.layers.firstWhereOrNull((layer) => layer.id == layerId);
    if (layer is TileLayer) {
      return layer.tileAt(x, y);
    }
    return null;
  }

  /// Gets the Gid  of the corresponding layer at the given position
  ///
  /// {@macro renderable_tile_map_get_tile}
  Gid? getTileDataByLayerIndex({
    required int layerIndex,
    required int x,
    required int y,
  }) {
    final layer = map.layers[layerIndex];
    if (layer is TileLayer) {
      return layer.tileAt(x, y);
    }
    return null;
  }

  /// Select a group of tiles from the coordinates [x] and [y].
  ///
  /// [x] and [y] are the tile coordinates shown in the Tiled editor, which
  /// can be negative on infinite maps.
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
    Iterable<RenderableLayer> layers,
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
            layer.layers,
            x,
            y,
            named: named,
            ids: ids,
            all:
                all ||
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

        final transform = layer.transformAt(x, y);
        if (transform != null) {
          tiles.add(transform);
        }
      }
    }
    return tiles;
  }

  /// Parses a file returning a [RenderableTiledMap].
  ///
  /// {@template renderable_tile_map_path}
  /// The [fileName] is the full path of the map, as declared in the
  /// `pubspec.yaml`, for example `assets/tiles/map.tmx`. External tilesets
  /// (`.tsx`) and object templates (`.tx`) that the map references are
  /// resolved relative to that path.
  /// {@endtemplate}
  ///
  /// {@template tiled_images_directory}
  /// Tileset and image-layer sources are resolved against [imagesDirectory],
  /// which defaults to `assets/images/`.
  /// {@endtemplate}
  ///
  /// {@template renderable_tile_map_factory}
  /// By default, [FlameTileLayer] renders flipped tiles if they exist.
  /// You can disable this by setting [ignoreFlip] to `true`.
  /// {@endtemplate}
  static Future<RenderableTiledMap> fromFile(
    String fileName,
    Vector2 destTileSize, {
    double? atlasMaxX,
    double? atlasMaxY,
    CameraComponent? camera,
    bool? ignoreFlip,
    Images? images,
    AssetBundle? bundle,
    bool Function(Tileset)? tsxPackingFilter,
    bool useAtlas = true,
    Paint Function(double opacity)? layerPaintFactory,
    double atlasPackingSpacingX = 0,
    double atlasPackingSpacingY = 0,
    String? package,
    String imagesDirectory = 'assets/images/',
  }) async {
    final mapPath = package == null ? fileName : 'packages/$package/$fileName';
    final contents = await (bundle ?? Flame.bundle).loadString(mapPath);
    return await fromString(
      contents,
      destTileSize,
      atlasMaxX: atlasMaxX,
      atlasMaxY: atlasMaxY,
      tsxDirectory: mapPath.substring(0, mapPath.lastIndexOf('/') + 1),
      imagesDirectory: imagesDirectory,
      camera: camera,
      ignoreFlip: ignoreFlip,
      images: images,
      bundle: bundle,
      tsxPackingFilter: tsxPackingFilter,
      useAtlas: useAtlas,
      layerPaintFactory: layerPaintFactory ?? _defaultLayerPaintFactory,
      atlasPackingSpacingX: atlasPackingSpacingX,
      atlasPackingSpacingY: atlasPackingSpacingY,
      package: package,
    );
  }

  /// Parses a string returning a [RenderableTiledMap].
  ///
  /// External tilesets (`.tsx`) and object templates (`.tx`) that the map
  /// references are resolved against [tsxDirectory].
  ///
  /// {@macro tiled_images_directory}
  ///
  /// {@macro renderable_tile_map_factory}
  static Future<RenderableTiledMap> fromString(
    String contents,
    Vector2 destTileSize, {
    double? atlasMaxX,
    double? atlasMaxY,
    String tsxDirectory = '',
    String imagesDirectory = 'assets/images/',
    CameraComponent? camera,
    bool? ignoreFlip,
    Images? images,
    AssetBundle? bundle,
    bool Function(Tileset)? tsxPackingFilter,
    bool useAtlas = true,
    Paint Function(double opacity)? layerPaintFactory,
    double atlasPackingSpacingX = 0,
    double atlasPackingSpacingY = 0,
    String? package,
  }) async {
    // tiled calls this once for every external file the map references,
    // including files referenced from other external files, always with a
    // path relative to the map.
    final map = await TiledMap.fromString(
      contents,
      (path) => (bundle ?? Flame.bundle).loadString('$tsxDirectory$path'),
    );
    return await fromTiledMap(
      map,
      destTileSize,
      atlasMaxX: atlasMaxX,
      atlasMaxY: atlasMaxY,
      imagesDirectory: imagesDirectory,
      camera: camera,
      ignoreFlip: ignoreFlip,
      images: images,
      bundle: bundle,
      tsxPackingFilter: tsxPackingFilter,
      useAtlas: useAtlas,
      layerPaintFactory: layerPaintFactory ?? _defaultLayerPaintFactory,
      atlasPackingSpacingX: atlasPackingSpacingX,
      atlasPackingSpacingY: atlasPackingSpacingY,
      package: package,
    );
  }

  /// Parses a [TiledMap] returning a [RenderableTiledMap].
  ///
  /// {@macro tiled_images_directory}
  ///
  /// {@macro renderable_tile_map_factory}
  static Future<RenderableTiledMap> fromTiledMap(
    TiledMap map,
    Vector2 destTileSize, {
    double? atlasMaxX,
    double? atlasMaxY,
    String imagesDirectory = 'assets/images/',
    CameraComponent? camera,
    bool? ignoreFlip,
    Images? images,
    AssetBundle? bundle,
    bool Function(Tileset)? tsxPackingFilter,
    bool useAtlas = true,
    Paint Function(double opacity)? layerPaintFactory,
    double atlasPackingSpacingX = 0,
    double atlasPackingSpacingY = 0,
    String? package,
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
      map,
      destTileSize,
      animationFrames,
      atlas: await TiledAtlas.fromTiledMap(
        map,
        maxX: atlasMaxX,
        maxY: atlasMaxY,
        images: images,
        tsxPackingFilter: tsxPackingFilter,
        useAtlas: useAtlas,
        spacingX: atlasPackingSpacingX,
        spacingY: atlasPackingSpacingY,
        package: package,
        imagesDirectory: imagesDirectory,
      ),
      ignoreFlip: ignoreFlip,
      images: images,
      layerPaintFactory: layerPaintFactory ?? _defaultLayerPaintFactory,
      package: package,
      imagesDirectory: imagesDirectory,
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
    TiledMap map,
    Vector2 destTileSize,
    Map<Tile, TileFrames> animationFrames, {
    required TiledAtlas atlas,
    required Paint Function(double opacity) layerPaintFactory,
    bool? ignoreFlip,
    Images? images,
    String? package,
    String imagesDirectory = 'assets/images/',
  }) {
    final layerLoaders = layers.map((layer) async {
      final renderableLayer = await RenderableLayer.load(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        animationFrames: animationFrames,
        atlas: atlas,
        ignoreFlip: ignoreFlip,
        images: images,
        layerPaintFactory: layerPaintFactory,
        package: package,
        imagesDirectory: imagesDirectory,
      );

      if (layer is Group && renderableLayer is GroupLayer) {
        final childLayers = await _renderableLayers(
          layer.layers,
          map,
          destTileSize,
          animationFrames,
          atlas: atlas,
          ignoreFlip: ignoreFlip,
          images: images,
          layerPaintFactory: layerPaintFactory,
          package: package,
          imagesDirectory: imagesDirectory,
        );
        for (final childLayer in childLayers) {
          renderableLayer.add(childLayer);
        }
      }

      return renderableLayer;
    }).toList();

    return Future.wait(layerLoaders);
  }

  /// Rebuilds the cache for rendering
  void _refreshCache() {
    for (final layer in renderableLayers) {
      layer.refreshCache();
    }
  }

  static final Vector2 _viewCenter = Vector2.zero();
  static final Vector2 _corner = Vector2.zero();

  late final Rect _mapRect = Rect.fromLTWH(0, 0, size.x, size.y);

  /// Positions the layers for the view of the camera before rendering them.
  @override
  void renderTree(Canvas canvas) {
    final camera =
        this.camera ?? CameraComponent.currentCamera ?? findGame()?.camera;
    final Rect visibleRect;
    if (camera == null) {
      _viewCenter.setZero();
      visibleRect = _mapRect;
    } else {
      visibleRect = _visibleRectInMap(camera.visibleWorldRect);
      _viewCenter.setValues(visibleRect.center.dx, visibleRect.center.dy);
    }
    for (final layer in renderableLayers) {
      layer.updateView(_viewCenter, visibleRect);
    }
    super.renderTree(canvas);
  }

  /// Converts [worldRect] into the coordinate space of this map, which is the
  /// local coordinate space of the closest [PositionComponent] ancestor,
  /// typically the `TiledComponent`.
  Rect _visibleRectInMap(Rect worldRect) {
    final space = findParent<PositionComponent>();
    if (space == null) {
      return worldRect;
    }
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (var i = 0; i < 4; i++) {
      _corner.setValues(
        i.isEven ? worldRect.left : worldRect.right,
        i < 2 ? worldRect.top : worldRect.bottom,
      );
      final local = space.absoluteToLocal(_corner);
      minX = min(minX, local.x);
      minY = min(minY, local.y);
      maxX = max(maxX, local.x);
      maxY = max(maxY, local.y);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Renders the background color of the map. The layers are rendered as
  /// children of this component, so use [renderTree] to draw the whole map
  /// onto a canvas.
  @override
  void render(Canvas canvas) {
    if (_backgroundPaint != null) {
      canvas.drawPaint(_backgroundPaint);
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

  /// Returns the [RenderableLayer] with the given [name], searching through
  /// the group layers as well. If no such layer is found, null is returned.
  ///
  /// Components added to the returned layer are rendered between that layer
  /// and the next layer of the map:
  ///
  /// ```dart
  /// tiledComponent.tileMap.getRenderableLayer('Ground')?.add(player);
  /// ```
  RenderableLayer? getRenderableLayer(String name) {
    return _findRenderableLayer(renderableLayers, name);
  }

  RenderableLayer? _findRenderableLayer(
    Iterable<RenderableLayer> layers,
    String name,
  ) {
    for (final layer in layers) {
      if (layer.layer.name == name) {
        return layer;
      }
      if (layer is GroupLayer) {
        final found = _findRenderableLayer(layer.layers, name);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  /// Updates the animation frames of the tiles, the layers update themselves
  /// as children of this component.
  @override
  void update(double dt) {
    for (final frame in animationFrames.values) {
      frame.update(dt);
    }
  }
}
