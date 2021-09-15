import 'dart:ui';

import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'mixins/has_paint.dart';
import 'position_component.dart';

export '../sprite_animation.dart';

class SpriteAnimationComponent extends PositionComponent with HasPaint {
  /// The animation used by the component.
  SpriteAnimation? animation;

  /// If the component should be removed once the animation has finished.
  /// Needs the animation to have `loop = false` to ever remove the component,
  /// since it will never finish otherwise.
  bool removeOnFinish = false;

  /// Whether the animation is paused or playing.
  bool playing;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationComponent({
    Vector2? position,
    Vector2? size,
    int? priority,
    this.animation,
    Paint? paint,
    this.removeOnFinish = false,
    this.playing = true,
  }) : super(position: position, size: size, priority: priority) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  /// Creates a SpriteAnimationComponent from a [size], an [image] and [data]. Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the FlameGame when the animation is finished.
  SpriteAnimationComponent.fromFrameData(
    Image image,
    SpriteAnimationData data, {
    Vector2? position,
    Vector2? size,
    int? priority,
    Paint? paint,
    this.removeOnFinish = false,
    this.playing = true,
  }) : super(position: position, size: size, priority: priority) {
    animation = SpriteAnimation.fromFrameData(image, data);

    if (paint != null) {
      this.paint = paint;
    }
  }

  /// Component will be removed after animation is done and [removeOnFinish] is set.
  ///
  /// Note: [SpriteAnimationComponent] will not be removed automatically if loop property of [SpriteAnimation] is true.
  @override
  bool get shouldRemove =>
      super.shouldRemove || (removeOnFinish && (animation?.done() ?? false));

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animation?.getSprite().render(
          canvas,
          size: size,
          overridePaint: paint,
        );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playing) {
      animation?.update(dt);
    }
  }
}
