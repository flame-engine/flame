import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'position_component.dart';

export '../sprite_animation.dart';

class SpriteAnimationComponent extends PositionComponent {
  SpriteAnimation animation;
  Paint overridePaint;
  bool removeOnFinish = false;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationComponent({
    Vector2 position,
    Vector2 size,
    this.animation,
    this.overridePaint,
    this.removeOnFinish = false,
  }) : super(position: position, size: size);

  /// Creates an [SpriteAnimationComponent] from an [animation] and a [size]
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the [BaseGame] when the animation is finished.
  @Deprecated('Use SpriteAnimationComponent instead')
  SpriteAnimationComponent.fromSpriteAnimation(
    Vector2 size,
    this.animation, {
    this.removeOnFinish = false,
  })  : assert(animation != null),
        super(size: size);

  factory SpriteAnimationComponent.position(
    double x,
    double y, {
    Vector2 size,
    SpriteAnimation animation,
    Paint overridePaint,
    bool removeOnFinish = false,
  }) =>
      SpriteAnimationComponent(
        position: Vector2(x, y),
        size: size,
        animation: animation,
        overridePaint: overridePaint,
        removeOnFinish: removeOnFinish,
      );

  /// Creates a SpriteAnimationComponent from a [size], an [image] and [data]. Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the [BaseGame] when the animation is finished.
  SpriteAnimationComponent.fromFrameData(
    Vector2 size,
    Image image,
    SpriteAnimationData data, {
    this.removeOnFinish = false,
  }) {
    super.size.setFrom(size);
    animation = SpriteAnimation.fromFrameData(
      image,
      data,
    );
  }

  @override
  bool get shouldRemove => removeOnFinish && (animation?.isLastFrame ?? false);

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animation?.getSprite()?.render(
          canvas,
          size: size,
          overridePaint: overridePaint,
        );
  }

  @override
  void update(double t) {
    super.update(t);
    animation?.update(t);
  }
}
