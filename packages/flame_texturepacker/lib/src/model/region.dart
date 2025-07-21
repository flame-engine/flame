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

  /// Ultra-compact data storage using bit packing.
  /// Uses 12 bits (supports 0-4095) with some values packed together.
  /// Format:
  /// [left|top, width|height, offsetX|offsetY, originalWidth, originalHeight]
  final Uint16List _packedData;

  /// Packed rotation data:
  /// bits 0-8 for degrees, bit 9 for rotate flag, bits 10-31 for index
  final int _rotationAndIndex;

  static const int _maxValue = 4095; // 12 bits max
  static const int _bitMask = 0xFFF; // 12 bits mask

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
  })  : assert(left >= 0 && left <= _maxValue, 'left must be 0-4095'),
        assert(top >= 0 && top <= _maxValue, 'top must be 0-4095'),
        assert(width >= 0 && width <= _maxValue, 'width must be 0-4095'),
        assert(height >= 0 && height <= _maxValue, 'height must be 0-4095'),
        assert(offsetX >= 0 && offsetX <= _maxValue, 'offsetX must be 0-4095'),
        assert(offsetY >= 0 && offsetY <= _maxValue, 'offsetY must be 0-4095'),
        _packedData = Uint16List.fromList([
          // Pack left (12 bits) + top first 4 bits
          (left.toInt() & _bitMask) | ((top.toInt() & 0xF) << 12),
          // Pack top remaining 8 bits + width first 8 bits
          ((top.toInt() >> 4) & 0xFF) | ((width.toInt() & 0xFF) << 8),
          // Pack width remaining 4 bits + height (12 bits)
          ((width.toInt() >> 8) & 0xF) | ((height.toInt() & _bitMask) << 4),
          // Pack offsetX (12 bits) + offsetY first 4 bits
          (offsetX.toInt() & _bitMask) | ((offsetY.toInt() & 0xF) << 12),
          // Pack offsetY remaining 8 bits + originalWidth first 8 bits
          ((offsetY.toInt() >> 4) & 0xFF) |
              (((originalWidth ?? width).toInt() & 0xFF) << 8),
          // Pack originalWidth remaining 4 bits + originalHeight (12 bits)
          (((originalWidth ?? width).toInt() >> 8) & 0xF) |
              (((originalHeight ?? height).toInt() & _bitMask) << 4),
        ]),
        _rotationAndIndex = (degrees & 0x1FF) |
            ((rotate ? 1 : 0) << 9) |
            ((index + 1) << 10); // +1 to handle -1 index

  /// The left position of the region in the texture atlas.
  double get left => (_packedData[0] & _bitMask).toDouble();

  /// The top position of the region in the texture atlas.
  double get top =>
      (((_packedData[0] >> 12) & 0xF) | ((_packedData[1] & 0xFF) << 4))
          .toDouble();

  /// The width of the image, after whitespace was removed for packing.
  double get width =>
      (((_packedData[1] >> 8) & 0xFF) | ((_packedData[2] & 0xF) << 8))
          .toDouble();

  /// The height of the image, after whitespace was removed for packing.
  double get height => ((_packedData[2] >> 4) & _bitMask).toDouble();

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  double get offsetX => (_packedData[3] & _bitMask).toDouble();

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  double get offsetY =>
      (((_packedData[3] >> 12) & 0xF) | ((_packedData[4] & 0xFF) << 4))
          .toDouble();

  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  double get originalWidth =>
      (((_packedData[4] >> 8) & 0xFF) | ((_packedData[5] & 0xF) << 8))
          .toDouble();

  /// The height of the image, before whitespace was removed for packing.
  double get originalHeight => ((_packedData[5] >> 4) & _bitMask).toDouble();

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
