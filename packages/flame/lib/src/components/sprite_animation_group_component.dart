import 'dart:ui';

import 'package:meta/meta.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'mixins/has_paint.dart';
import 'position_component.dart';

export '../sprite_animation.dart';

class SpriteAnimationGroupComponent<T> extends PositionComponent with HasPaint {
  /// Key with the current playing animation
  T? current;

  /// Map with the mapping each state to the flag removeOnFinish
  final Map<T, bool> removeOnFinish;

  /// Map with the available states for this animation group
  Map<T, SpriteAnimation>? animations;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationGroupComponent({
    this.animations,
    this.current,
    Map<T, bool>? removeOnFinish,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : removeOnFinish = removeOnFinish ?? const {},
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  /// Creates a SpriteAnimationGroupComponent from a [size], an [image] and
  /// [data].
  /// Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be mapped to true to have this component
  /// be auto removed from the FlameGame when the animation is finished.
  SpriteAnimationGroupComponent.fromFrameData(
    Image image,
    Map<T, SpriteAnimationData> data, {
    T? current,
    Map<T, bool>? removeOnFinish,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : this(
          animations: data.map((key, value) {
            return MapEntry(
              key,
              SpriteAnimation.fromFrameData(
                image,
                value,
              ),
            );
          }),
          current: current,
          removeOnFinish: removeOnFinish,
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  SpriteAnimation? get animation => animations?[current];

  /// Component will be removed after animation is done and the current state
  /// is true on [removeOnFinish].
  ///
  /// Note: [SpriteAnimationGroupComponent] will not be removed automatically if loop
  /// property of [SpriteAnimation] of the current state is true.
  @override
  bool get shouldRemove {
    final stateRemoveOnFinish = removeOnFinish[current] ?? false;
    return super.shouldRemove ||
        (stateRemoveOnFinish && (animation?.done() ?? false));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    animation?.getSprite().render(
          canvas,
          size: size,
          overridePaint: paint,
        );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation?.update(dt);
  }
}
