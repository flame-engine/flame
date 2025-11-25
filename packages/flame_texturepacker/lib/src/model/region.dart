import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flutter/foundation.dart';

/// Represents a region within the texture packer atlas.
@immutable
final class Region {
  /// The page in the texture pack this region belongs to.
  final Page page;

  /// The name of the original image file, without the file's extension.
  /// If the name ends with an underscore followed by only numbers, that part is
  /// excluded: underscores denote special instructions to the texture packer.
  final String name;

  /// The left position of the region in the texture atlas.
  final double left;

  /// The top position of the region in the texture atlas.
  final double top;

  /// The width of the image, after whitespace was removed for packing.
  final double width;

  /// The height of the image, after whitespace was removed for packing.
  final double height;

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  final double offsetX;

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  final double offsetY;

  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  final double originalWidth;

  /// The height of the image, before whitespace was removed for packing.
  final double originalHeight;

  /// The degrees the region has been rotated, counter clockwise between 0 and
  /// 359. Most atlas region handling deals only with 0 or 90 degree rotation
  /// (enough to handle rectangles).
  /// More advanced texture packing may support other rotations (eg, for tightly
  /// packing polygons).
  final int degrees;

  /// If true, the region has been rotated 90 degrees counter clockwise.
  final bool rotate;

  /// The number at the end of the original image file name, or -1 if none.
  ///
  /// When sprites are packed, if the original file name ends with a number, it
  /// is stored as the index and is not considered as part of the sprite's name.
  /// This is useful for keeping animation frames in order.
  final int index;

  /// Creates a new [Region] with the given properties.
  const Region({
    required this.page,
    required this.name,
    this.left = 0,
    this.top = 0,
    this.width = 0,
    this.height = 0,
    this.offsetX = 0,
    this.offsetY = 0,
    double? originalWidth,
    double? originalHeight,
    this.degrees = 0,
    this.rotate = false,
    this.index = -1,
  }) : originalWidth = originalWidth ?? width,
       originalHeight = originalHeight ?? height;
}
