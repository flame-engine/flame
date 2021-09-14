import 'dart:async';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../../game.dart';
import '../assets/images.dart';
import '../extensions/vector2.dart';
import '../parallax.dart';
import 'position_component.dart';

extension ParallaxComponentExtension on FlameGame {
  Future<ParallaxComponent> loadParallaxComponent(
    List<ParallaxData> dataList, {
    Vector2? size,
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    int? priority,
  }) async {
    final component = await ParallaxComponent.load(
      dataList,
      size: size,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
      priority: priority,
    );

    return component;
  }
}

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different velocities to give an effect of depth.
class ParallaxComponent<T extends FlameGame> extends PositionComponent
    with HasGameRef<T> {
  bool isFullscreen = true;
  Parallax? _parallax;

  Parallax? get parallax => _parallax;
  set parallax(Parallax? p) {
    _parallax = p;
    _parallax?.resize(size);
  }

  /// Creates a component with an empty parallax which can be set later.
  ParallaxComponent({
    Vector2? position,
    Vector2? size,
    int? priority,
  }) : super(position: position, size: size, priority: priority) {
    if (size != null) {
      isFullscreen = false;
    }
  }

  /// Creates a component from a [Parallax] object.
  factory ParallaxComponent.fromParallax(
    Parallax parallax, {
    Vector2? position,
    int? priority,
  }) {
    return ParallaxComponent(
      position: position,
      size: parallax.isSized ? parallax.size : null,
      priority: priority,
    )..parallax = parallax;
  }

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

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.update(dt);
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    parallax?.render(canvas);
  }

  /// Note that this method only should be used if all of your layers should
  /// have the same layer arguments (how the images should be repeated, aligned
  /// and filled), otherwise load the [ParallaxLayer]s individually and use the
  /// normal constructor.
  ///
  /// [load] takes a list of [ParallaxData] of all the images and a size that you want to use in the
  /// parallax.
  ///
  /// Optionally arguments for the [baseVelocity] and [velocityMultiplierDelta] can be passed
  /// in, [baseVelocity] defines what the base velocity of the layers should be
  /// and [velocityMultiplierDelta] defines how the velocity should change the
  /// closer the layer is ([velocityMultiplierDelta ^ n], where n is the
  /// layer index).
  /// Arguments for how all the images should repeat ([repeat]),
  /// which edge it should align with ([alignment]), which axis it should fill
  /// the image on ([fill]) and [images] which is the image cache that should be
  /// used can also be passed in.
  ///
  /// If no image cache is set, the global flame cache is used.
  static Future<ParallaxComponent> load(
    List<ParallaxData> dataList, {
    Vector2? size,
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    int? priority,
  }) async {
    final component = ParallaxComponent.fromParallax(
      await Parallax.load(
        dataList,
        size: size,
        baseVelocity: baseVelocity,
        velocityMultiplierDelta: velocityMultiplierDelta,
        repeat: repeat,
        alignment: alignment,
        fill: fill,
        images: images,
      ),
      priority: priority,
    );

    if (size != null) {
      component.size.setFrom(size);
    }

    return component;
  }
}
