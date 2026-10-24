import 'package:flame/rendering.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:meta/meta.dart';

/// Caches transforms for staggered maps as the row/col are switched.
@internal
class TileTransform(
  /// The Tiled coordinates of the tile.
  final int tx,
  final int ty,
  final MutableRect source,
  final MutableRSTransform transform,
  final SimpleFlips flip,
);
