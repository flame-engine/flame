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

  /// The total canvas translation used in parallax effects.
  /// This field needs to be read in the case of repeated textures
  /// as an optimization step.
  Vector2 absoluteParallax = Vector2.zero();

  /// The total offsets computed from our [Layer.offsetX] and [Layer.offsetY]
  /// and all parent layer offsets, if any.
  Vector2 absoluteOffset = Vector2.zero();

  /// Given the layer's [opacity], compute [Paint] for drawing.
  /// This is useful if your layer requires translucency or other effects.
  Paint Function(double opacity) layerPaintFactory;

  /// A read on [paint] will compute the value from [layerPaintFactory].
  @override
  Paint get paint => layerPaintFactory(opacity);

  RenderableLayer({
    required this.layer,
    required Component? parent,
    required this.map,
    required this.camera,
    required this.destTileSize,
    required this.layerPaintFactory,
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
        layerPaintFactory: layerPaintFactory,
        images: images,
      );
    } else if (layer is ObjectGroup) {
      return ObjectLayer.load(
        layer,
        parent,
        camera,
        map,
        destTileSize,
        layerPaintFactory,
        filterQuality,
      );
    } else if (layer is Group) {
      return GroupLayer(
        layer: layer,
        parent: parent,
        camera: camera,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      );
    }

    return UnsupportedLayer(
      layer: layer,
      parent: parent,
      camera: camera,
      map: map,
      destTileSize: destTileSize,
      layerPaintFactory: layerPaintFactory,
    );
  }

  bool get visible => layer.visible;

  void refreshCache();

  @override
  double get opacity =>
      layer.opacity *
      switch (parent) {
        final GroupLayer p => p.opacity,
        _ => 1,
      };

  double get scaleX => destTileSize.x / map.tileWidth;
  double get scaleY => destTileSize.y / map.tileHeight;

  late double offsetX = layer.offsetX * scaleX;
  late double offsetY = layer.offsetY * scaleY;

  /// Calculates the offset we need to apply to the canvas to compensate for
  /// parallax positioning and scroll for the layer and the current camera
  /// position.
  /// https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  void applyParallaxOffset(Canvas canvas) {
    final viewfinder = camera?.viewfinder;
    final cameraX = viewfinder?.position.x ?? 0;
    final cameraY = viewfinder?.position.y ?? 0;
    final zoom = viewfinder?.zoom ?? 1.0;

    // Discover parent layer terms used for the calculations below.
    final parentOffset = switch (parent) {
      final GroupLayer p => p.absoluteOffset,
      _ => Vector2.zero(),
    };
    final parentParallax = switch (parent) {
      final GroupLayer p => p.absoluteParallax,
      _ => Vector2.zero(),
    };
    final parallaxLocality = Vector2(
      layer.parallaxX * parentParallax.x,
      layer.parallaxY * parentParallax.y,
    );

    // Calculate our local parallax.
    double calcParallax(double cam, double parallax) => cam * parallax;
    final localParallax =
        Vector2(
          calcParallax(cameraX, layer.parallaxX),
          calcParallax(cameraY, layer.parallaxY),
        ) /
        zoom;

    // Adjustment term for parallax locality.
    final delta = switch (parent is GroupLayer) {
      true => (localParallax + parallaxLocality) - parentParallax,
      false => Vector2.zero(),
    };

    absoluteParallax = localParallax + parallaxLocality;
    absoluteOffset = parentOffset + Vector2(offsetX, offsetY);

    // Strictly apply local translations in our render step.
    //
    // Explanation:
    // B/c sum of all local translations w.r.t. parallax locality is equal to the
    // products of all absolute parallax values followed by translation, the
    // scene graph render by Flame produces the same visuals as painting layers
    //using absolute values in a traditional composite renderer.
    canvas.translate(
      (cameraX + offsetX) - (localParallax.x + delta.x),
      (cameraY + offsetY) - (localParallax.y + delta.y),
    );
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
