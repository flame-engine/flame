import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

extension ParallaxComponentExtension on FlameGame {
  Future<ParallaxComponent> loadParallaxComponent(
    Iterable<ParallaxData> dataList, {
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) async {
    return ParallaxComponent.load(
      dataList,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }
}

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different velocities to give an effect of depth.
class ParallaxComponent<T extends FlameGame> extends PositionComponent
    with HasGameRef<T> {
  @override
  PositionType positionType = PositionType.viewport;

  bool isFullscreen = true;
  Parallax? _parallax;

  Parallax? get parallax => _parallax;
  set parallax(Parallax? p) {
    _parallax = p;
    _parallax?.resize(size);
  }

  /// Creates a component with an empty parallax which can be set later.
  ParallaxComponent({
    Parallax? parallax,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  })  : _parallax = parallax,
        isFullscreen = size == null && !(parallax?.isSized ?? false),
        super(
          size: size ?? ((parallax?.isSized ?? false) ? parallax?.size : null),
        );

  @mustCallSuper
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isFullscreen) {
      return;
    }
    final newSize = gameRef.camera.viewport.effectiveSize;
    this.size.setFrom(newSize);
    parallax?.resize(newSize);
  }

  @mustCallSuper
  @override
  void onMount() {
    assert(
      parallax != null,
      'The parallax needs to be set in either the constructor or in onLoad',
    );
  }

  @mustCallSuper
  @override
  void update(double dt) {
    parallax?.update(dt);
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    parallax?.render(canvas);
  }

  /// Note that this method only should be used if all of your layers should
  /// have the same layer arguments (how the images should be repeated, aligned
  /// and filled), otherwise load the [ParallaxLayer]s individually and use the
  /// normal constructor.
  ///
  /// [load] takes a list of [ParallaxData] of all the images and a size that
  /// you want to use in the parallax.
  ///
  /// Optionally arguments for the [baseVelocity] and [velocityMultiplierDelta]
  /// can be passed in, [baseVelocity] defines what the base velocity of the
  /// layers should be and [velocityMultiplierDelta] defines how the velocity
  /// should change the closer the layer is (`velocityMultiplierDelta ^ n`,
  /// where `n` is the layer index).
  /// Arguments for how all the images should repeat ([repeat]),
  /// which edge it should align with ([alignment]), which axis it should fill
  /// the image on ([fill]) and [images] which is the image cache that should be
  /// used can also be passed in.
  ///
  /// If no image cache is set, the global flame cache is used.
  static Future<ParallaxComponent> load(
    Iterable<ParallaxData> dataList, {
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) async {
    return ParallaxComponent(
      parallax: await Parallax.load(
        dataList,
        size: size,
        baseVelocity: baseVelocity,
        velocityMultiplierDelta: velocityMultiplierDelta,
        repeat: repeat,
        alignment: alignment,
        fill: fill,
        images: images,
      ),
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }
}
