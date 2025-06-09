import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:meta/meta.dart';

export '../sprite.dart';

/// {@template raster_sprite_component}
/// A [RasterSpriteComponent] is a [SpriteComponent] that
/// will rasterize its sprite when loaded and will automatically
/// manage the disposal of the rasterized image when removed.
/// {@endtemplate}
class RasterSpriteComponent extends SpriteComponent {
  /// {@macro raster_sprite_component}
  RasterSpriteComponent({
    required this.baseSprite,
    this.images,
    super.autoResize,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.bleed,
    super.key,
  });

  /// The base sprite to be rasterized.
  final Sprite baseSprite;

  /// The [Images] cache used to store the rasterized image.
  final Images? images;

  @mustCallSuper
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    sprite = await baseSprite.rasterize(images: images);
  }
}
