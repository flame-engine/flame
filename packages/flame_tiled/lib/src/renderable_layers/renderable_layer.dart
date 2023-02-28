import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/image_layer.dart';
import 'package:flame_tiled/src/renderable_layers/object_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
abstract class RenderableLayer<T extends Layer> {
  final T layer;
  final Vector2 destTileSize;
  final TiledMap map;

  /// The parent [Group] layer (if it exists)
  final GroupLayer? parent;

  RenderableLayer({
    required this.layer,
    required this.parent,
    required this.map,
    required this.destTileSize,
  });

  /// [load] is a factory method to create [RenderableLayer] by type of [layer].
  static Future<RenderableLayer> load({
    required Layer layer,
    required GroupLayer? parent,
    required TiledMap map,
    required Vector2 destTileSize,
    required Camera? camera,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    bool? ignoreFlip,
  }) async {
    if (layer is TileLayer) {
      return FlameTileLayer.load(
        layer: layer,
        parent: parent,
        map: map,
        destTileSize: destTileSize,
        animationFrames: animationFrames,
        atlas: atlas.clone(),
        ignoreFlip: ignoreFlip,
      );
    } else if (layer is ImageLayer) {
      return FlameImageLayer.load(
        layer: layer,
        parent: parent,
        camera: camera,
        map: map,
        destTileSize: destTileSize,
      );
    } else if (layer is ObjectGroup) {
      return ObjectLayer.load(
        layer,
        map,
        destTileSize,
      );
    } else if (layer is Group) {
      final groupLayer = layer;
      return GroupLayer(
        layer: groupLayer,
        parent: parent,
        map: map,
        destTileSize: destTileSize,
      );
    }

    return UnsupportedLayer(
      layer: layer,
      parent: parent,
      map: map,
      destTileSize: destTileSize,
    );
  }

  bool get visible => layer.visible;

  void render(Canvas canvas, Camera? camera);

  void handleResize(Vector2 canvasSize);

  void refreshCache();

  void update(double dt);

  double get scaleX => destTileSize.x / map.tileWidth;
  double get scaleY => destTileSize.y / map.tileHeight;

  late double offsetX = layer.offsetX * scaleX + (parent?.offsetX ?? 0);

  late double offsetY = layer.offsetY * scaleY + (parent?.offsetY ?? 0);

  late double opacity = layer.opacity * (parent?.opacity ?? 1);

  late double parallaxX = layer.parallaxX * (parent?.parallaxX ?? 1);

  late double parallaxY = layer.parallaxY * (parent?.parallaxY ?? 1);

  /// Calculates the offset we need to apply to the canvas to compensate for
  /// parallax positioning and scroll for the layer and the current camera
  /// position
  /// https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  void applyParallaxOffset(Canvas canvas, Camera camera) {
    final cameraX = camera.position.x;
    final cameraY = camera.position.y;
    final vpCenterX = camera.viewport.effectiveSize.x / 2;
    final vpCenterY = camera.viewport.effectiveSize.y / 2;

    // Due to how Tiled treats the center of the view as the reference
    // point for parallax positioning (see Tiled docs), we need to offset the
    // entire layer
    var x = (1 - parallaxX) * vpCenterX;
    var y = (1 - parallaxY) * vpCenterY;
    // compensate the offset for zoom
    x /= camera.zoom;
    y /= camera.zoom;

    // Now add the scroll for the current camera position
    x += cameraX - (cameraX * parallaxX);
    y += cameraY - (cameraY * parallaxY);

    canvas.translate(x, y);
  }
}

@internal
class UnsupportedLayer extends RenderableLayer {
  UnsupportedLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
  });

  @override
  void render(Canvas canvas, Camera? camera) {}

  @override
  void handleResize(Vector2 canvasSize) {}

  @override
  void refreshCache() {}

  @override
  void update(double dt) {}
}
