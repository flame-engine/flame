import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/image_layer.dart';
import 'package:flame_tiled/src/renderable_layers/object_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/unsupported_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:tiled/tiled.dart';

abstract class RenderableLayer<T extends Layer> extends PositionComponent
    with HasPaint<RenderableLayer<T>> {
  final T layer;
  final Vector2 destTileSize;
  final TiledMap map;
  final CameraComponent? camera;

  /// The [FilterQuality] that should be used by all the layers.
  final FilterQuality filterQuality;

  /// Cached canvas translation used in parallax effects.
  /// This field needs to be read in the case of repeated textures
  /// as part of an optimization.
  Vector2 cachedLayerOffset = Vector2.zero();

  RenderableLayer({
    required this.layer,
    required Component? parent,
    required this.map,
    required this.camera,
    required this.destTileSize,
    FilterQuality? filterQuality,
  }) : filterQuality = filterQuality ?? FilterQuality.none {
    this.parent = parent;
  }

  /// [load] is a factory method to create [RenderableLayer] by type of [layer].
  static Future<RenderableLayer> load({
    required Layer layer,
    required GroupLayer? parent,
    required TiledMap map,
    required Vector2 destTileSize,
    required CameraComponent? camera,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    required Paint Function(double opacity) layerPaintFactory,
    FilterQuality? filterQuality,
    bool? ignoreFlip,
    Images? images,
  }) async {
    if (layer is TileLayer) {
      return FlameTileLayer.load(
        layer: layer,
        parent: parent,
        camera: camera,
        map: map,
        destTileSize: destTileSize,
        animationFrames: animationFrames,
        atlas: atlas.clone(),
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      );
    } else if (layer is ImageLayer) {
      return FlameImageLayer.load(
        layer: layer,
        parent: parent,
        camera: camera,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
        images: images,
      );
    } else if (layer is ObjectGroup) {
      return ObjectLayer.load(
        layer,
        parent,
        camera,
        map,
        destTileSize,
        filterQuality,
      );
    } else if (layer is Group) {
      final groupLayer = layer;
      return GroupLayer(
        layer: groupLayer,
        parent: parent,
        camera: camera,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
      );
    }

    return UnsupportedLayer(
      layer: layer,
      parent: parent,
      camera: camera,
      map: map,
      destTileSize: destTileSize,
    );
  }

  bool get visible => layer.visible;

  void refreshCache();

  double get scaleX => destTileSize.x / map.tileWidth;
  double get scaleY => destTileSize.y / map.tileHeight;

  late double offsetX = layer.offsetX * scaleX +
      switch (parent) {
        final GroupLayer p => p.offsetX,
        _ => 0,
      };

  late double offsetY = layer.offsetY * scaleY +
      switch (parent) {
        final GroupLayer p => p.offsetY,
        _ => 0,
      };

  @override
  double get opacity =>
      layer.opacity *
      switch (parent) {
        final GroupLayer p => p.opacity,
        _ => 1,
      };

  late double parallaxX = layer.parallaxX *
      switch (parent) {
        final GroupLayer p => p.parallaxX,
        _ => 1,
      };

  late double parallaxY = layer.parallaxY *
      switch (parent) {
        final GroupLayer p => p.parallaxY,
        _ => 1,
      };

  /// Calculates the offset we need to apply to the canvas to compensate for
  /// parallax positioning and scroll for the layer and the current camera
  /// position.
  /// https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  void applyParallaxOffset(Canvas canvas) {
    final anchor = camera?.viewfinder.anchor ?? Anchor.center;
    final cameraX = camera?.viewfinder.position.x ?? 0.0;
    final cameraY = camera?.viewfinder.position.y ?? 0.0;
    final viewportCenterX = (camera?.viewport.virtualSize.x ?? 0.0) * anchor.x;
    final viewportCenterY = (camera?.viewport.virtualSize.y ?? 0.0) * anchor.y;
    final topLeftX = cameraX - viewportCenterX;
    final topLeftY = cameraY - viewportCenterY;

    final double initOffsetX = viewportCenterX * parallaxX;
    final double initOffsetY = viewportCenterY * parallaxY;

    // Use the complement of the parallax coefficient in order to account for
    // the camera applying its transformations earlier in the render cycle
    // of Flame. This adjustment draws the layers correctly w.r.t. their own
    // offset and parallax values.
    final double x = offsetX + (cameraX * (1.0 - parallaxX));
    final double y = offsetY + (cameraY * (1.0 - parallaxY));

    cachedLayerOffset = Vector2(x, y);
    canvas.translate(cachedLayerOffset.x, cachedLayerOffset.y);
  }

  // Only render if this layer is [visible].
  @override
  void renderTree(Canvas c) {
    if (!visible) {
      return;
    }
    c.save();
    applyParallaxOffset(c);
    super.renderTree(c);
    c.restore();
  }
}
