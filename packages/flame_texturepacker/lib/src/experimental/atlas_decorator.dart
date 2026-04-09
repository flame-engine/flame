import 'dart:ui' as ui;
import 'package:flutter/painting.dart';

/// Context provided to [AtlasDecorator]s during the baking process.
/// This allows shaders to sample from the original atlas using correctly
/// mapping global texture coordinates.
class AtlasContext {
  final ui.Image atlasImage;
  final ui.Rect srcRect;
  final ui.Size atlasSize;
  final ui.Size localSize;
  final int? itemIndex;
  final int? itemCount;

  /// The total padding applied to the current drawing canvas.
  /// This is the sum of all [BakePadding]s in the decorator chain.
  final EdgeInsets padding;

  /// Whether the sprite is rotated 90° CCW in the source atlas image.
  final bool rotated;

  AtlasContext({
    required this.atlasImage,
    required this.srcRect,
    required this.atlasSize,
    required this.localSize,
    this.rotated = false,
    this.itemIndex,
    this.itemCount,
    this.padding = EdgeInsets.zero,
  });
}

/// An interface for Decorators that require access to the source atlas context.
/// This is particularly useful for fragment shaders that need to sample from
/// an atlas.
abstract class AtlasDecorator {
  void updateAtlasContext(AtlasContext context);
}

/// An interface for Decorators that add visual padding to the content
/// (e.g. outlines, shadows, glows).
///
/// This is used by the baking process to properly expand the baking canvas
/// and adjust the resulting sprite offsets.
abstract class BakePadding {
  EdgeInsets get padding;
}
