import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:meta/meta.dart';

/// [OrthogonalTileLayer] is a tile layer that each axis is represented
/// orthogonally.
@internal
class OrthogonalTileLayer extends FlameTileLayer {
  OrthogonalTileLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
    required super.tiledAtlas,
    required super.animationFrames,
    required super.ignoreFlip,
    super.filterQuality,
  });

  @override
  void cacheTiles() {
    final tileData = layer.tileData!;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      for (var tx = 0; tx < tileRow.length; tx++) {
        final tileGid = tileRow[tx];
        if (tileGid.tile == 0) {
          continue;
        }

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
        final scale = size.x / map.tileWidth;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;
        offsetX = (tx + .5) * size.x;
        offsetY = (ty + .5) * size.y;

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        transforms[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );

        batch.addTransform(
          source: src,
          transform: transforms[tx][ty],
          flip: shouldFlip(flips),
        );

        if (tile.animation.isNotEmpty) {
          addAnimation(tile, tileset, src);
        }
      }
    }
  }
}
