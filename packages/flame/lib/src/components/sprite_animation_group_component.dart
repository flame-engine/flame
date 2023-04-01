import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';

export '../sprite_animation.dart';

class SpriteAnimationGroupComponent<T> extends PositionComponent
    with HasPaint
    implements SizeProvider {
  /// Key with the current playing animation
  T? _current;

  /// Map with the mapping each state to the flag removeOnFinish
  final Map<T, bool> removeOnFinish;

  /// Map with the available states for this animation group
  Map<T, SpriteAnimation>? animations;

  /// Whether the animation is paused or playing.
  bool playing;

  /// When set to true, the component is auto-resized to match the
  /// size of current animation sprite.
  bool _autoResize;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationGroupComponent({
    this.animations,
    T? current,
    bool? autoResize,
    this.playing = true,
    this.removeOnFinish = const {},
    Paint? paint,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
  })  : assert(
          (size == null) == (autoResize ?? size == null),
          '''If size is set, autoResize should be false or size should be null when autoResize is true.''',
        ),
        _current = current,
        _autoResize = autoResize ?? size == null,
        super(size: size ?? animations?[current]?.getSprite().srcSize) {
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
    bool? autoResize,
    bool playing = true,
    Map<T, bool> removeOnFinish = const {},
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
          autoResize: autoResize,
          removeOnFinish: removeOnFinish,
          playing: playing,
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  SpriteAnimation? get animation => animations?[current];

  /// Returns the current group state.
  T? get current => _current;

  /// The the group state to given state.
  ///
  /// Will update [size] if [autoResize] is true.
  set current(T? value) {
    _current = value;
    _resizeToSprite();
  }

  /// Returns current value of auto resize flag.
  bool get autoResize => _autoResize;

  /// Sets the given value of autoResize flag.
  ///
  /// Will update the [size] to fit srcSize of current animation sprite if set
  /// to  true.
  set autoResize(bool value) {
    _autoResize = value;
    _resizeToSprite();
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

  @mustCallSuper
  @override
  void update(double dt) {
    if (playing) {
      animation?.update(dt);
      _resizeToSprite();
    }
    if ((removeOnFinish[current] ?? false) && (animation?.done() ?? false)) {
      removeFromParent();
    }
  }

  /// Updates the size to current animation sprite's srcSize if
  /// [autoResize] is true.
  void _resizeToSprite() {
    if (_autoResize) {
      if (animation != null) {
        size.setFrom(animation!.getSprite().srcSize);
      } else {
        size.setZero();
      }
    }
  }
}
