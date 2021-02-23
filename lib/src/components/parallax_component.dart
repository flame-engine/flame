import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../assets/images.dart';
import '../extensions/vector2.dart';
import '../game/game.dart';
import '../parallax.dart';
import 'position_component.dart';

extension ParallaxComponentExtension on Game {
  Future<ParallaxComponent> loadParallaxComponent(
    List<String> paths, {
    Vector2 size,
    Vector2 baseVelocity,
    Vector2 velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
  }) async {
    final componentSize = size ?? this.size;
    final component = await ParallaxComponent.load(
      paths,
      size: componentSize,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      repeat: repeat,
      alignment: alignment,
      fill: fill,
      images: images,
    );

    return component..size.setFrom(componentSize);
  }
}

/// A full parallax, several layers of images drawn out on the screen and each
/// layer moves with different velocities to give an effect of depth.
class ParallaxComponent extends PositionComponent {
  Parallax _parallax;

  Parallax get parallax => _parallax;
  set parallax(Parallax p) {
    _parallax = p;
    _parallax.resize(size);
  }

  /// Creates a component with an empty parallax which can be set later
  ParallaxComponent();

  /// Creates a component from a [Parallax] object
  ParallaxComponent.fromParallax(this._parallax);

  @mustCallSuper
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    parallax?.resize(size);
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
  /// [load] takes a list of paths to all the images and a size that you want to use in the
  /// parallax.
  /// Optionally arguments for the [baseVelocity] and [layerDelta] can be passed
  /// in, [baseVelocity] defines what the base velocity of the layers should be
  /// and [velocityMultiplierDelta] defines how the velocity should change the
  /// closer the layer is ([velocityMultiplierDelta ^ n], where n is the
  /// layer index).
  /// Arguments for how all the images should repeat ([repeat]),
  /// which edge it should align with ([alignment]), which axis it should fill
  /// the image on ([fill]) and [images] which is the image cache that should be
  /// used can also be passed in.
  /// If no image cache is set, the global flame cache is used.
  static Future<ParallaxComponent> load(
    List<String> paths, {
    Vector2 size,
    Vector2 baseVelocity,
    Vector2 velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images images,
  }) async {
    final component = ParallaxComponent.fromParallax(
      await Parallax.load(
        paths,
        size,
        baseVelocity: baseVelocity,
        velocityMultiplierDelta: velocityMultiplierDelta,
        repeat: repeat,
        alignment: alignment,
        fill: fill,
        images: images,
      ),
    );

    if (size != null) {
      component.size.setFrom(size);
    }

    return component;
  }
}
