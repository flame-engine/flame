import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/mutable_transform.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/tile_transform.dart';
import 'package:meta/meta.dart';

/// [HexagonalTileLayer] have hexagonal-shaped tiles and also its overall shape
/// is like a honeycomb.
@internal
class HexagonalTileLayer extends FlameTileLayer {
  HexagonalTileLayer({
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
    final halfDestinationTile = destTileSize / 2;
    final size = destTileSize;
    final halfMapTile = Vector2(map.tileWidth / 2, map.tileHeight / 2);
    final batch = tiledAtlas.batch;
    if (batch == null) {
      return;
    }

    var staggerY = 0.0;
    var staggerX = 0.0;
    // Hexagonal Pointy Tiles move down by a fractional amount.
    if (map.staggerAxis == StaggerAxis.y) {
      staggerY = size.y * 0.75;
    } else if (map.staggerAxis == StaggerAxis.x) {
      // Hexagonal Flat Tiles move right by a fractional amount.
      staggerX = size.x * 0.75;
    }

    for (var ty = 0; ty < tileData.length; ty++) {
      final tileRow = tileData[ty];

      // Hexagonal Pointy Tiles shift left and right depending on the row
      if (map.staggerAxis == StaggerAxis.y) {
        if ((ty.isOdd && map.staggerIndex == StaggerIndex.odd) ||
            (ty.isEven && map.staggerIndex == StaggerIndex.even)) {
          staggerX = halfDestinationTile.x;
        } else {
          staggerX = 0.0;
        }
      }

      // When staggering in the X axis, we need to hold painting of "lower"
      // tiles (those with staggerY adjustments) otherwise they'll just get
      // painted over. See the second pass loop after tx.
      final xSecondPass = <TileTransform>[];

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

        // Hexagonal Flat tiles shift up and down as we move across the row.
        if (map.staggerAxis == StaggerAxis.x) {
          if ((tx.isOdd && map.staggerIndex == StaggerIndex.odd) ||
              (tx.isEven && map.staggerIndex == StaggerIndex.even)) {
            staggerY = halfDestinationTile.y;
          } else {
            staggerY = 0.0;
          }
        }

        final flips = SimpleFlips.fromFlips(tileGid.flips);
        final scale = size.x / map.tileWidth;
        final anchorX = src.width - halfMapTile.x;
        final anchorY = src.height - halfMapTile.y;

        late double offsetX;
        late double offsetY;

        // halfTile.x: shifts the map half a tile forward rather than
        //             lining up on at the center.
        // halfTile.y: shifts the map half a tile down rather than
        //             lining up on at the center.
        // StaggerX/Y: Moves the tile forward/down depending on orientation.
        //  * stagger: Hexagonal tiles move down or right by only a fraction,
        //             specifically 3/4 the width or height, for packing.
        if (map.staggerAxis == StaggerAxis.y) {
          offsetX = tx * size.x + staggerX + halfDestinationTile.x;
          offsetY = ty * staggerY + halfDestinationTile.y;
        } else {
          offsetX = tx * staggerX + halfDestinationTile.x;
          offsetY = ty * size.y + staggerY + halfDestinationTile.y;
        }

        final scos = flips.cos * scale;
        final ssin = flips.sin * scale;

        final transform = transforms[tx][ty] = MutableRSTransform(
          scos,
          ssin,
          offsetX,
          offsetY,
          -scos * anchorX + ssin * anchorY,
          -ssin * anchorX - scos * anchorY,
        );
        // A second pass is only needed in the case of staggery.
        if (map.staggerAxis == StaggerAxis.x && staggerY > 0) {
          xSecondPass.add(TileTransform(src, transform, flips, batch));
        } else {
          batch.addTransform(
            source: src,
            transform: transform,
            flip: shouldFlip(flips),
          );
        }
        if (tile.animation.isNotEmpty) {
          addAnimation(tile, tileset, src);
        }
      }

      for (final tile in xSecondPass) {
        tile.batch.addTransform(
          source: tile.source,
          transform: tile.transform,
          flip: shouldFlip(tile.flip),
        );
      }
    }
  }
}
