import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A part of the selected region of the sprite editor that can be dragged.
enum SpriteRegionHandle(
  /// Where the handle is in the region, from `0` to `1` on each axis.
  final Offset alignment,
) {
  /// The top left corner.
  topLeft(Offset.zero),

  /// The middle of the top edge.
  top(Offset(0.5, 0)),

  /// The top right corner.
  topRight(Offset(1, 0)),

  /// The middle of the right edge.
  right(Offset(1, 0.5)),

  /// The bottom right corner.
  bottomRight(Offset(1, 1)),

  /// The middle of the bottom edge.
  bottom(Offset(0.5, 1)),

  /// The bottom left corner.
  bottomLeft(Offset(0, 1)),

  /// The middle of the left edge.
  left(Offset(0, 0.5));

  /// Returns [region] with this handle dragged to [point]. Dragging it past
  /// the opposite side flips the region.
  Rect dragged(Rect region, Offset point) {
    return Rect.fromPoints(
      Offset(
        alignment.dx == 0 ? point.dx : region.left,
        alignment.dy == 0 ? point.dy : region.top,
      ),
      Offset(
        alignment.dx == 1 ? point.dx : region.right,
        alignment.dy == 1 ? point.dy : region.bottom,
      ),
    );
  }
}

/// {@template sprite_view_transform}
/// Maps the pixels of an image to the sprite editor canvas and back, and
/// finds the handles of the selected region under a point of the canvas.
/// {@endtemplate}
@immutable
class const SpriteViewTransform({
  /// The canvas pixels per image pixel.
  final double scale = 1,

  /// Where the top left corner of the image is on the canvas.
  final Offset offset = Offset.zero,
}) {
  /// {@macro sprite_view_transform}
  this;

  /// A transform that centers an image of [imageSize] in a canvas of
  /// [size], as big as it fits within [padding] of its edges.
  factory fit(Size imageSize, Size size, {double padding = 24}) {
    final scale = math.min(
      math.max(size.width - padding * 2, 1) / imageSize.width,
      math.max(size.height - padding * 2, 1) / imageSize.height,
    );
    return SpriteViewTransform(
      scale: scale,
      offset: size.center(Offset.zero) - imageSize.center(Offset.zero) * scale,
    );
  }

  /// The radius around a handle within which the pointer hits it.
  static const hitRadius = 10.0;

  /// This transform scaled by [zoom] around [center], a point of the
  /// canvas that stays where it is.
  SpriteViewTransform zoomed(double zoom, Offset center) {
    return SpriteViewTransform(
      scale: scale * zoom,
      offset: center - (center - offset) * zoom,
    );
  }

  /// This transform moved by [delta], in canvas pixels.
  SpriteViewTransform panned(Offset delta) {
    return SpriteViewTransform(scale: scale, offset: offset + delta);
  }

  /// Where the point [image] of the image is on the canvas.
  Offset toCanvas(Offset image) => image * scale + offset;

  /// Where [rect], in pixels of the image, is on the canvas.
  Rect rectToCanvas(Rect rect) {
    return Rect.fromPoints(toCanvas(rect.topLeft), toCanvas(rect.bottomRight));
  }

  /// The point of the image at [point] of the canvas.
  Offset toImage(Offset point) => (point - offset) / scale;

  /// Where [handle] of [region] is on the canvas.
  Offset handleOffset(SpriteRegionHandle handle, Rect region) {
    return toCanvas(
      region.topLeft +
          Offset(
            region.width * handle.alignment.dx,
            region.height * handle.alignment.dy,
          ),
    );
  }

  /// The handle of [region] at [point] of the canvas, if any. The closest
  /// one wins.
  SpriteRegionHandle? handleAt(Rect region, Offset point) {
    SpriteRegionHandle? closest;
    var closestDistance = hitRadius;
    for (final handle in SpriteRegionHandle.values) {
      final distance = (handleOffset(handle, region) - point).distance;
      if (distance <= closestDistance) {
        closest = handle;
        closestDistance = distance;
      }
    }
    return closest;
  }

  @override
  bool operator ==(Object other) =>
      other is SpriteViewTransform &&
      other.scale == scale &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(scale, offset);
}
