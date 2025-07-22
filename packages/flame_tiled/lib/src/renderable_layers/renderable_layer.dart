import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/image_layer.dart';
import 'package:flame_tiled/src/renderable_layers/object_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

abstract class RenderableLayer<T extends Layer> extends PositionComponent
    with HasPaint<RenderableLayer<T>> {
  final T layer;
  final Vector2 destTileSize;
  final TiledMap map;
  final CameraComponent? camera;

  /// The [FilterQuality] that should be used by all the layers.
  final FilterQuality filterQuality;

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
  late double opacity = layer.opacity *
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
  void applyParallaxOffset(Canvas canvas, CameraComponent camera) {
    final anchor = camera.viewfinder.anchor;
    final cameraX = camera.viewfinder.position.x;
    final cameraY = camera.viewfinder.position.y;
    final viewportCenterX = camera.viewport.size.x * anchor.x;
    final viewportCenterY = camera.viewport.size.y * anchor.y;

    // Due to how Tiled treats the center of the view as the reference
    // point for parallax positioning (see Tiled docs), we need to offset the
    // entire layer
    var x = (1 - parallaxX) * viewportCenterX;
    var y = (1 - parallaxY) * viewportCenterY;
    // Compensate the offset for zoom.
    x /= camera.viewfinder.zoom;
    y /= camera.viewfinder.zoom;
    // Scale to tile space.
    x /= destTileSize.x;
    y /= destTileSize.y;

    // Now add the scroll for the current camera position
    x += cameraX - (cameraX * parallaxX);
    y += cameraY - (cameraY * parallaxY);

    canvas.translate(x, y);
  }

  // Only render if this layer is [visible].
  @override
  void renderTree(Canvas c) {
    if (!visible) {
      return;
    }
    super.renderTree(c);
  }
}

@internal
class UnsupportedLayer extends RenderableLayer {
  UnsupportedLayer({
    required super.layer,
    required super.map,
    required super.parent,
    required super.camera,
    required super.destTileSize,
  });

  @override
  void refreshCache() {}
}
