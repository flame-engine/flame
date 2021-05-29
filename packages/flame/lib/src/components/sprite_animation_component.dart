import 'dart:ui';

import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'position_component.dart';

export '../sprite_animation.dart';

class SpriteAnimationComponent extends PositionComponent {
  SpriteAnimation? animation;
  Paint? overridePaint;
  bool removeOnFinish = false;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationComponent({
    Vector2? position,
    Vector2? size,
    int? priority,
    this.animation,
    this.overridePaint,
    this.removeOnFinish = false,
  }) : super(position: position, size: size, priority: priority);

  /// Creates a SpriteAnimationComponent from a [size], an [image] and [data]. Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the BaseGame when the animation is finished.
  SpriteAnimationComponent.fromFrameData(
    Image image,
    SpriteAnimationData data, {
    Vector2? position,
    Vector2? size,
    int? priority,
    this.removeOnFinish = false,
  }) : super(position: position, size: size, priority: priority) {
    animation = SpriteAnimation.fromFrameData(image, data);
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
          overridePaint: overridePaint,
        );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation?.update(dt);
  }
}
