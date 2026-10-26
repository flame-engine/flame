import 'dart:math';
import 'dart:ui';

import 'package:flame/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:meta/meta.dart';

/// How the tiles of a tile layer are split, so that the parts that are out of
/// view can be skipped.
@internal
enum TileLayerSplit() {
  /// All of the tiles are drawn with a single batch.
  none,

  /// The tiles are split in squares of neighboring tiles. The squares are drawn
  /// row by row, which only paints the tiles in the same order as [none] when
  /// no tile reaches into another cell.
  chunks,

  /// The tiles are split in runs: tiles that follow each other in one row, in
  /// the order they are painted in. The runs are drawn in that order too, so
  /// they paint the tiles exactly like [none], even when tiles overlap.
  runs,
}

/// A run of [TileLayerSplit.runs]: the tiles of the row [ty] from the column
/// [startX] to [endX], which are drawn by [chunk].
@internal
class TileRun(final int ty, final int startX, final TileChunk chunk) {
  /// The column of the last tile of the run.
  late int endX = startX;
}

/// A group of neighboring tiles of a tile layer that are drawn with their own
/// [SpriteBatch], so that the whole group can be skipped while it is outside of
/// the view.
@internal
class TileChunk(final SpriteBatch batch) {
  double _left = double.infinity;
  double _top = double.infinity;
  double _right = double.negativeInfinity;
  double _bottom = double.negativeInfinity;

  /// Whether this chunk is always drawn.
  ///
  /// Set when a tile transform of the chunk is handed out, because whoever
  /// holds it can move the tile outside of the bounds of the chunk.
  bool alwaysVisible = false;

  /// Adds a tile to the batch and grows the bounds of the chunk to fit it.
  ///
  /// The bounds are calculated from the transform as it is now, which is the
  /// reason for [alwaysVisible].
  void add({
    required MutableRect source,
    required MutableRSTransform transform,
    required bool flip,
  }) {
    batch.addTransform(source: source, transform: transform, flip: flip);

    final width = source.width;
    final height = source.height;
    final scos = transform.scos;
    final ssin = transform.ssin;
    for (var i = 0; i < 4; i++) {
      final x = i.isEven ? 0.0 : width;
      final y = i < 2 ? 0.0 : height;
      final cornerX = scos * x - ssin * y + transform.tx;
      final cornerY = ssin * x + scos * y + transform.ty;
      _left = min(_left, cornerX);
      _top = min(_top, cornerY);
      _right = max(_right, cornerX);
      _bottom = max(_bottom, cornerY);
    }
  }

  /// Whether this chunk has to be drawn when [view] is what is visible.
  bool isVisibleIn(Rect view) {
    return alwaysVisible ||
        (_left <= view.right &&
            _right >= view.left &&
            _top <= view.bottom &&
            _bottom >= view.top);
  }
}
