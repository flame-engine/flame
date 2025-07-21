import 'dart:typed_data';
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

  /// Packed position, size, and offsets as 16-bit unsigned integers.
  /// Format: [left, top, width, height, offsetX, offsetY]
  final Uint16List _packedData;

  /// Original dimensions as 16-bit unsigned integers (width, height)
  final Uint16List _originalData;

  /// Packed rotation data: bits 0-8 for degrees, bit 9 for rotate flag, bits 10-31 for index
  final int _rotationAndIndex;

  /// Creates a new [Region] with the given properties.
  Region({
    required this.page,
    required this.name,
    double left = 0,
    double top = 0,
    double width = 0,
    double height = 0,
    double offsetX = 0,
    double offsetY = 0,
    double? originalWidth,
    double? originalHeight,
    int degrees = 0,
    bool rotate = false,
    int index = -1,
  })  : assert(left >= 0 && left <= 65535, 'left must be 0-65535'),
        assert(top >= 0 && top <= 65535, 'top must be 0-65535'),
        assert(width >= 0 && width <= 65535, 'width must be 0-65535'),
        assert(height >= 0 && height <= 65535, 'height must be 0-65535'),
        assert(offsetX >= 0 && offsetX <= 65535, 'offsetX must be 0-65535'),
        assert(offsetY >= 0 && offsetY <= 65535, 'offsetY must be 0-65535'),
        _packedData = Uint16List.fromList([
          left.toInt(),
          top.toInt(),
          width.toInt(),
          height.toInt(),
          offsetX.toInt(),
          offsetY.toInt(),
        ]),
        _originalData = Uint16List.fromList([
          (originalWidth ?? width).toInt(),
          (originalHeight ?? height).toInt(),
        ]),
        _rotationAndIndex = (degrees & 0x1FF) |
            ((rotate ? 1 : 0) << 9) |
            ((index + 1) << 10); // +1 to handle -1 index

  /// The left position of the region in the texture atlas.
  double get left => _packedData[0].toDouble();

  /// The top position of the region in the texture atlas.
  double get top => _packedData[1].toDouble();

  /// The width of the image, after whitespace was removed for packing.
  double get width => _packedData[2].toDouble();

  /// The height of the image, after whitespace was removed for packing.
  double get height => _packedData[3].toDouble();

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  double get offsetX => _packedData[4].toDouble();

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  double get offsetY => _packedData[5].toDouble();

  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  double get originalWidth => _originalData[0].toDouble();

  /// The height of the image, before whitespace was removed for packing.
  double get originalHeight => _originalData[1].toDouble();

  /// The degrees the region has been rotated, counter clockwise between 0 and
  /// 359. Most atlas region handling deals only with 0 or 90 degree rotation
  /// (enough to handle rectangles).
  /// More advanced texture packing may support other rotations (eg, for tightly
  /// packing polygons).
  int get degrees => _rotationAndIndex & 0x1FF;

  /// If true, the region has been rotated 90 degrees counter clockwise.
  bool get rotate => (_rotationAndIndex >> 9) & 1 == 1;

  /// The number at the end of the original image file name, or -1 if none.
  ///
  /// When sprites are packed, if the original file name ends with a number, it
  /// is stored as the index and is not considered as part of the sprite's name.
  /// This is useful for keeping animation frames in order.
  int get index =>
      (_rotationAndIndex >> 10) - 1; // -1 to restore original -1 default
}
