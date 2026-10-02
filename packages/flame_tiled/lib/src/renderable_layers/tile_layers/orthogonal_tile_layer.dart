import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:meta/meta.dart';

/// [OrthogonalTileLayer] is a tile layer that each axis is represented
/// orthogonally.
@internal
class OrthogonalTileLayer({
  required super.layer,
  required super.map,
  required super.destTileSize,
  required super.tiledAtlas,
  required super.animationFrames,
  required super.ignoreFlip,
  required super.layerPaintFactory,
  super.filterQuality,
}) extends FlameTileLayer {
  @override
  void cacheTiles() {
    final size = destTileSize;
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    for (final MapEntry(key: ty, value: tileRow) in tilesByWorldRow().entries) {
      for (final (tx, tileGid) in tileRow) {
        final tile = map.tileByGid(tileGid.tile)!;
        final tileset = map.tilesetByTileGId(tileGid.tile);
        final img = tile.image ?? tileset.image;

        if (img == null) {
          continue;
        }

        if (!tiledAtlas.contains(img.source)) {
          return;
        }

        final spriteOffset = tiledAtlas.offsets[img.source]!;
        final src = MutableRect.fromRect(
          tileset
              .computeDrawRect(tile)
              .toRect()
              .translate(spriteOffset.dx, spriteOffset.dy),
        );

        final flips = SimpleFlips.fromFlips(tileGid.flips);
        late double offsetX;
        late double offsetY;
        offsetX = (tx + 0.5) * size.x;
        offsetY = (ty + 0.5) * size.y;

        offsetX += tileset.tileOffset?.x ?? 0;
        offsetY += tileset.tileOffset?.y ?? 0;

        final transform = tileTransform(
          src: src,
          flips: flips,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        storeTransform(tx, ty, transform);

        batch.addTransform(
          source: src,
          transform: transform,
          flip: shouldFlip(flips),
        );

        if (tile.animation.isNotEmpty) {
          addAnimation(tile, tileset, src);
        }
      }
    }
  }
}
