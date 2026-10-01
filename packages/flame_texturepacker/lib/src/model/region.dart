import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flutter/foundation.dart';

/// Represents a region within the texture packer atlas.
@immutable
final class const Region({
  /// The page in the texture pack this region belongs to.
  required final Page page,

  /// The name of the original image file, without the file's extension.
  /// If the name ends with an underscore followed by only numbers, that part is
  /// excluded: underscores denote special instructions to the texture packer.
  required final String name,

  /// The left position of the region in the texture atlas.
  final double left = 0,

  /// The top position of the region in the texture atlas.
  final double top = 0,

  /// The width of the image, after whitespace was removed for packing.
  final double width = 0,

  /// The height of the image, after whitespace was removed for packing.
  final double height = 0,

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  final double offsetX = 0,

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  final double offsetY = 0,
  double? originalWidth,
  double? originalHeight,

  /// The degrees the region has been rotated, counter clockwise between 0 and
  /// 359. Most atlas region handling deals only with 0 or 90 degree rotation
  /// (enough to handle rectangles).
  /// More advanced texture packing may support other rotations (eg, for tightly
  /// packing polygons).
  final int degrees = 0,

  /// If true, the region has been rotated 90 degrees counter clockwise.
  final bool rotate = false,

  /// The number at the end of the original image file name, or -1 if none.
  ///
  /// When sprites are packed, if the original file name ends with a number, it
  /// is stored as the index and is not considered as part of the sprite's name.
  /// This is useful for keeping animation frames in order.
  final int index = -1,
}) {
  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  final double originalWidth = originalWidth ?? width;

  /// The height of the image, before whitespace was removed for packing.
  final double originalHeight = originalHeight ?? height;
}
