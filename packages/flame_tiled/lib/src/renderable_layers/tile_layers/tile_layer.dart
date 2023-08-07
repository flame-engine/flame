import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/hexagonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/isometric_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/orthogonal_tile_layer.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/staggered_tile_layer.dart';
import 'package:flame_tiled/src/tile_animation.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// {@template flame_tile_layer}
/// [FlameTileLayer] is the base class of the following classes:
///
/// - [OrthogonalTileLayer]
/// - [StaggeredTileLayer]
/// - [HexagonalTileLayer]
/// - [IsometricTileLayer]
///
/// [FlameTileLayer] decides its concrete type by [MapOrientation]. So any
/// subclass of this should implement [cacheTiles] to reflect their map
/// orientation format.
///
/// [FlameTileLayer] stores its source image to [tiledAtlas]
/// and transform it by [transforms].
///
/// The flip is ignored if the [ignoreFlip] is set to true.
///
/// {@endtemplate}
@internal
abstract class FlameTileLayer extends RenderableLayer<TileLayer> {
  late final _layerPaint = Paint()
    ..color = Color.fromRGBO(255, 255, 255, opacity);
  final TiledAtlas tiledAtlas;
  late List<List<MutableRSTransform?>> transforms;
  final animations = <TileAnimation>[];
  final Map<Tile, TileFrames> animationFrames;
  final bool ignoreFlip;

  FlameTileLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
    required this.tiledAtlas,
    required this.animationFrames,
    required this.ignoreFlip,
    super.filterQuality,
  });

  /// {@macro flame_tile_layer}
  static FlameTileLayer load({
    required TileLayer layer,
    required GroupLayer? parent,
    required TiledMap map,
    required Vector2 destTileSize,
    required Map<Tile, TileFrames> animationFrames,
    required TiledAtlas atlas,
    FilterQuality? filterQuality,
    bool? ignoreFlip,
  }) {
    ignoreFlip ??= false;
    final mapOrientation = map.orientation;
    if (mapOrientation == null) {
      throw StateError('Map orientation should be present');
    }

    switch (mapOrientation) {
      case MapOrientation.isometric:
        return IsometricTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
          filterQuality: filterQuality,
        );
      case MapOrientation.staggered:
        return StaggeredTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
          filterQuality: filterQuality,
        );
      case MapOrientation.hexagonal:
        return HexagonalTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
          filterQuality: filterQuality,
        );
      case MapOrientation.orthogonal:
        return OrthogonalTileLayer(
          layer: layer,
          parent: parent,
          map: map,
          destTileSize: destTileSize,
          tiledAtlas: atlas,
          animationFrames: animationFrames,
          ignoreFlip: ignoreFlip,
          filterQuality: filterQuality,
        );
    }
  }

  @override
  void update(double dt) {
    for (final animation in animations) {
      animation.update(dt);
    }
  }

  @override
  void render(Canvas canvas, CameraComponent? camera) {
    if (tiledAtlas.batch == null) {
      return;
    }

    canvas.save();
    canvas.translate(offsetX, offsetY);
    if (camera != null) {
      applyParallaxOffset(canvas, camera);
    }
    tiledAtlas.batch!.render(canvas, paint: _layerPaint);
    canvas.restore();
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @protected
  void addAnimation(Tile tile, Tileset tileset, MutableRect source) {
    final frames = animationFrames[tile] ??= () {
      final frameRectangles = <Rect>[];
      final durations = <double>[];
      for (final frame in tile.animation) {
        final newTile = tileset.tiles[frame.tileId];
        final image = newTile.image ?? tileset.image;
        if (image?.source == null || !tiledAtlas.contains(image!.source)) {
          continue;
        }

        final spriteOffset = tiledAtlas.offsets[image.source]!;
        final rect = tileset
            .computeDrawRect(newTile)
            .toRect()
            .translate(spriteOffset.dx, spriteOffset.dy);
        frameRectangles.add(rect);
        durations.add(frame.duration / 1000);
      }
      return TileFrames(frameRectangles, durations);
    }();
    animations.add(TileAnimation(source, frames));
  }

  @override
  void refreshCache() {
    animations.clear();
    transforms = List.generate(
      layer.width,
      (index) => List.filled(layer.height, null),
    );

    tiledAtlas.batch?.clear();

    cacheTiles();
  }

  /// We need to know the following information for each tile to render a layer
  /// correctly.
  ///
  /// - source offset
  /// - rotation
  /// - translation
  /// - flip
  ///
  /// But gathering these in every tick is a too heavy task for the engine.
  /// So, [FlameTileLayer] caches these by [cacheTiles] and tiles quickly in
  /// every frame.
  @protected
  void cacheTiles();

  @protected
  bool shouldFlip(SimpleFlips flips) => !ignoreFlip && flips.flip;
}
