import 'dart:ui';

import 'package:flame/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:meta/meta.dart';

/// Caches transforms for staggered maps as the row/col are switched.
@internal
class TileTransform {
  final Rect source;
  final MutableRSTransform transform;
  final SimpleFlips flip;
  final SpriteBatch batch;

  TileTransform(
    this.source,
    this.transform,
    this.flip,
    this.batch,
  );
}
