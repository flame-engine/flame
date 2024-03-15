import 'package:flame/components.dart';
import 'package:flame_texturepacker/src/model/region.dart';

/// {@template _texture_packer_sprite}
/// A [Sprite] extracted from a texture packer file.
/// {@endtemplate}
class TexturePackerSprite extends Sprite {
  /// {@macro _texture_packer_sprite}
  TexturePackerSprite(Region region)
      : name = region.name,
        index = region.index,
        offsetX = region.offsetX,
        offsetY = region.offsetY,
        packedWidth = region.width,
        packedHeight = region.height,
        originalWidth = region.originalWidth,
        originalHeight = region.originalHeight,
        rotate = region.rotate,
        degrees = region.degrees,
        super(
          region.page.texture,
          srcPosition: Vector2(region.left, region.top),
          srcSize: Vector2(region.width, region.height),
        );

  /// The number at the end of the original image file name, or -1 if none.
  ///
  /// When sprites are packed, if the original file name ends with a number, it
  /// is stored as the index and is not considered as part of the sprite's name.
  /// This is useful for keeping animation frames in order.
  final int index;

  /// The name of the original image file, without the file's extension.
  /// If the name ends with an underscore followed by only numbers, that part is
  /// excluded: underscores denote special instructions to the texture packer.
  final String name;

  /// The offset from the left of the original image to the left of the packed
  /// image, after whitespace was removed for packing.
  final double offsetX;

  /// The offset from the bottom of the original image to the bottom of the
  /// packed image, after whitespace was removed for packing.
  final double offsetY;

  /// The width of the image, after whitespace was removed for packing.
  final double packedWidth;

  /// The height of the image, after whitespace was removed for packing.
  final double packedHeight;

  /// The width of the image, before whitespace was removed and rotation was
  /// applied for packing.
  final double originalWidth;

  /// The height of the image, before whitespace was removed for packing.
  final double originalHeight;

  /// If true, the region has been rotated 90 degrees counter clockwise.
  final bool rotate;

  /// The degrees the region has been rotated, counter clockwise between 0 and
  /// 359. Most atlas region handling deals only with 0 or 90 degree rotation
  /// (enough to handle rectangles).
  /// More advanced texture packing may support other rotations (eg, for tightly
  /// packing polygons).
  final int degrees;

  /// The [degrees] field (angle) represented as radians.
  double get angle => radians(degrees.toDouble());
}
