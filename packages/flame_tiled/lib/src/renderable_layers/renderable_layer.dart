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
import 'package:flame_tiled/src/tiled_component.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

/// {@template renderable_layer}
/// A component that renders a single Tiled [Layer].
///
/// Every layer of a map is a [RenderableLayer] in the component tree of the
/// map, nested in the same order and hierarchy as in Tiled. This means that
/// components added to a layer are rendered right after that layer, and thus
/// underneath any layer that comes later in the map. Use this to draw sprites
/// between the layers of a map, for example a player that walks behind the
/// foreground:
///
/// ```dart
/// final layer = tiledComponent.tileMap.getRenderableLayer('Ground');
/// layer?.add(player);
/// ```
///
/// The [position] of a layer is the sum of the layer's offset ([offsetX] and
/// [offsetY]) and the parallax displacement for the current camera view. It
/// is recalculated whenever the map is rendered, so move a layer by changing
/// [offsetX] and [offsetY] instead of [position].
/// {@endtemplate}
abstract class RenderableLayer<T extends Layer>({
  /// The Tiled layer that this component renders.
  required final T layer,

  /// The map that [layer] belongs to.
  required final TiledMap map,

  /// The target size for each tile of the map.
  required final Vector2 destTileSize,
  FilterQuality? filterQuality,
}) extends PositionComponent {
  /// The [FilterQuality] that should be used by all the layers.
  final FilterQuality filterQuality = filterQuality ?? FilterQuality.none;

  /// The horizontal offset of this layer, relative to its parent, scaled to
  /// [destTileSize].
  late double offsetX = layer.offsetX * scaleX;

  /// The vertical offset of this layer, relative to its parent, scaled to
  /// [destTileSize].
  late double offsetY = layer.offsetY * scaleY;

  /// {@macro renderable_layer}
  this {
    position.setValues(offsetX, offsetY);
  }

  /// [load] is a factory method to create [RenderableLayer] by type of [layer].
  @internal
  static Future<RenderableLayer> load({
    required Layer layer,
    required TiledMap map,
    required Vector2 destTileSize,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    required Paint Function(double opacity) layerPaintFactory,
    FilterQuality? filterQuality,
    bool? ignoreFlip,
    Images? images,
    String? package,
    String imagesDirectory = 'assets/images/',
  }) async {
    if (layer is TileLayer) {
      return FlameTileLayer.load(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        animationFrames: animationFrames,
        atlas: atlas.clone(),
        ignoreFlip: ignoreFlip,
        filterQuality: filterQuality,
        layerPaintFactory: layerPaintFactory,
      );
    } else if (layer is ImageLayer) {
      return await FlameImageLayer.load(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
        images: images,
        package: package,
        imagesDirectory: imagesDirectory,
      );
    } else if (layer is ObjectGroup) {
      return ObjectLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
      );
    } else if (layer is Group) {
      return GroupLayer(
        layer: layer,
        map: map,
        destTileSize: destTileSize,
        filterQuality: filterQuality,
      );
    }

    return UnsupportedLayer(
      layer: layer,
      map: map,
      destTileSize: destTileSize,
    );
  }

  /// The group layer that this layer is nested in, if any.
  RenderableLayer<Group>? get parentLayer {
    final parent = this.parent;
    return parent is RenderableLayer<Group> ? parent : null;
  }

  /// Whether this layer, and the components added to it, are rendered.
  ///
  /// Reflects [Layer.visible], so it can be changed at runtime through
  /// `RenderableTiledMap.setLayerVisibility`.
  bool get visible => layer.visible;

  /// Rebuilds the cached rendering data of this layer.
  void refreshCache();

  double get scaleX => destTileSize.x / map.tileWidth;
  double get scaleY => destTileSize.y / map.tileHeight;

  /// The effective opacity of this layer, which is its own opacity multiplied
  /// by the opacity of all its parent layers.
  double get opacity => layer.opacity * (parentLayer?.opacity ?? 1);

  set opacity(double value) {
    layer.opacity = value;
    onOpacityChanged();
  }

  /// Called after [opacity] is changed.
  ///
  /// Override to react to opacity updates (e.g. to rebuild a cached paint).
  /// When overriding inside a container layer, propagate the call to children
  /// so that descendant layers with cached paints are also updated.
  @protected
  void onOpacityChanged() {}

  /// The effective horizontal parallax factor of this layer, which is its own
  /// factor multiplied by the factors of all its parent layers.
  double get parallaxX => layer.parallaxX * (parentLayer?.parallaxX ?? 1);

  /// The effective vertical parallax factor of this layer, which is its own
  /// factor multiplied by the factors of all its parent layers.
  double get parallaxY => layer.parallaxY * (parentLayer?.parallaxY ?? 1);

  /// The area of this layer, in its local coordinates, that is currently
  /// visible through the camera, or the area of the map when the map is
  /// rendered without a camera.
  Rect get visibleRect => _visibleRect ??= _mapRect;
  Rect? _visibleRect;

  Rect get _mapRect {
    final size = TiledComponent.computeSize(
      map.orientation,
      destTileSize,
      map.tileWidth,
      map.tileHeight,
      map.width,
      map.height,
      map.staggerAxis,
    );
    return Rect.fromLTWH(0, 0, size.x, size.y);
  }

  /// Positions this layer for the current view of the camera, following the
  /// parallax scrolling rules of Tiled.
  ///
  /// [viewCenter] is the point of the map that is in the center of the view.
  /// A layer is displaced from its offset by `viewCenter * (1 - parallax)`, so
  /// that a layer with a parallax factor of 0 stays fixed on the screen and a
  /// layer with a factor of 1 scrolls together with the map. When the map is
  /// rendered without a camera, [viewCenter] is zero and the layer sits at its
  /// offset.
  ///
  /// [visibleRect] is the visible area of the map, in the local coordinates of
  /// the parent of this layer.
  ///
  /// See https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  @internal
  @mustCallSuper
  void updateView(Vector2 viewCenter, Rect visibleRect) {
    final parentParallaxX = parentLayer?.parallaxX ?? 1;
    final parentParallaxY = parentLayer?.parallaxY ?? 1;
    final x = offsetX + viewCenter.x * parentParallaxX * (1 - layer.parallaxX);
    final y = offsetY + viewCenter.y * parentParallaxY * (1 - layer.parallaxY);
    if (position.x != x || position.y != y) {
      position.setValues(x, y);
    }
    _visibleRect = visibleRect.shift(Offset(-x, -y));
  }

  @override
  void renderTree(Canvas canvas) {
    if (!visible) {
      return;
    }
    super.renderTree(canvas);
  }
}

/// A [RenderableLayer] for a layer type that this package cannot render.
///
/// It is still added to the component tree so that its offset and parallax
/// factor propagate to any components that are added to it.
@internal
class UnsupportedLayer({
  required super.layer,
  required super.map,
  required super.destTileSize,
}) extends RenderableLayer {
  @override
  void refreshCache() {}
}
