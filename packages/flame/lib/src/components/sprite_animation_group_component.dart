import 'dart:ui';

import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'sprite_animation_component.dart';

export '../sprite_animation.dart';

class SpriteAnimationGroupComponent<T> extends SpriteAnimationComponent {
  /// Key with the current playing animation
  T? current;

  /// Map with the available states for this animation group
  late Map<T, SpriteAnimation> animations;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationGroupComponent({
    required this.animations,
    Vector2? position,
    Vector2? size,
    this.current,
    Paint? overridePaint,
    bool removeOnFinish = false,
  }) : super(
          position: position,
          size: size,
          overridePaint: overridePaint,
          removeOnFinish: removeOnFinish,
        );

  /// Creates a SpriteAnimationGroupComponent from a [size], an [image] and [data]. Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be auto removed from the BaseGame when the animation is finished.
  SpriteAnimationGroupComponent.fromFrameData(
    Image image,
    Map<T, SpriteAnimationData> data, {
    this.current,
    Vector2? position,
    Vector2? size,
    Paint? overridePaint,
    bool removeOnFinish = false,
  }) : super(
          position: position,
          size: size,
          overridePaint: overridePaint,
          removeOnFinish: removeOnFinish,
        ) {
    animations = data.map((key, value) {
      return MapEntry(
        key,
        SpriteAnimation.fromFrameData(
          image,
          value,
        ),
      );
    });
  }

  @override
  SpriteAnimation? get animation {
    if (current != null) {
      return animations[current];
    }

    return null;
  }
}
