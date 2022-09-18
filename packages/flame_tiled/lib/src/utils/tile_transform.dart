import 'dart:ui' as ui;

import 'package:flame/sprite.dart';
import 'package:meta/meta.dart';

/// Caches transforms for staggered maps as the row/col are switched.
@internal
class TileTransform {
  final ui.Rect source;
  final ui.RSTransform transform;
  final bool flip;
  final SpriteBatch batch;

  TileTransform(
    this.source,
    this.transform,
    this.flip,
    this.batch,
  );
}
