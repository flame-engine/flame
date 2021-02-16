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
  SpriteAnimationComponent();

  /// Creates an [SpriteAnimationComponent] from an [animation] and a [size]
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the [BaseGame] when the animation is finished.
  SpriteAnimationComponent.fromSpriteAnimation(
    Vector2 size,
    this.animation, {
    this.removeOnFinish = false,
  }) : assert(animation != null) {
    super.size.setFrom(size);
  }

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

  /// Component will be removed after loop end and [removeOnFinish] is set.
  /// [Component.shouldRemove] worked here.
  @override
  bool get shouldRemove =>
      (removeOnFinish && (animation?.isLastFrame ?? false)) ||
      super.shouldRemove;

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
