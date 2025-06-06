import 'dart:async';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// {@template raster_sprite_component}
/// A [RasterSpriteComponent] is a [SpriteComponent] that
/// will rasterize its sprite when loaded and will automatically
/// manage the disposal of the rasterized image when removed.
/// {@endtemplate}
class RasterSpriteComponent extends SpriteComponent {
  /// {@macro raster_sprite_component}
  RasterSpriteComponent({
    required this.baseSprite,
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

  @mustCallSuper
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await baseSprite.rasterize();
  }

  @mustCallSuper
  @override
  void onRemove() {
    super.onRemove();

    sprite?.image.dispose();
    sprite = null;
  }
}

