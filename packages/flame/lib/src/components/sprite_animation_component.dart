import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/sprite_animation_ticker.dart';
import 'package:meta/meta.dart';

export '../sprite_animation.dart';

class SpriteAnimationComponent extends PositionComponent with HasPaint {
  /// The animation ticker used for updating [animation].
  SpriteAnimationTicker? _animationTicker;

  /// Returns the animation ticker for current [animation].
  SpriteAnimationTicker? get animationTicker => _animationTicker;

  /// If the component should be removed once the animation has finished.
  /// Needs the animation to have `loop = false` to ever remove the component,
  /// since it will never finish otherwise.
  bool removeOnFinish;

  /// Whether the animation is paused or playing.
  bool playing;

  /// Whether to reset the animation when the component is removed from the
  /// component tree.
  bool resetOnRemove;

  /// When set to true, the component is auto-resized to match the
  /// size of current animation sprite.
  bool _autoResize;

  /// Creates a component with an empty animation which can be set later
  SpriteAnimationComponent({
    SpriteAnimation? animation,
    bool? autoResize,
    this.removeOnFinish = false,
    this.playing = true,
    this.resetOnRemove = false,
    Paint? paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : assert(
         (size == null) == (autoResize ?? size == null),
         '''If size is set, autoResize should be false or size should be null when autoResize is true.''',
       ),
       _autoResize = autoResize ?? size == null,
       _animationTicker = animation?.createTicker() {
    if (paint != null) {
      this.paint = paint;
    }

    /// Register a listener to differentiate between size modification done by
    /// external calls v/s the ones done by [_resizeToSprite].
    size.addListener(_handleAutoResizeState);
    _resizeToSprite();
  }

  /// Creates a SpriteAnimationComponent from a [size], an [image] and [data].
  /// Check [SpriteAnimationData] for more info on the available options.
  ///
  /// Optionally [removeOnFinish] can be set to true to have this component be
  /// auto removed from the FlameGame when the animation is finished.
  SpriteAnimationComponent.fromFrameData(
    Image image,
    SpriteAnimationData data, {
    bool? autoResize,
    bool removeOnFinish = false,
    bool playing = true,
    bool resetOnRemove = false,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    double nativeAngle = 0,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    ComponentKey? key,
  }) : this(
         animation: SpriteAnimation.fromFrameData(image, data),
         autoResize: autoResize,
         removeOnFinish: removeOnFinish,
         playing: playing,
         resetOnRemove: resetOnRemove,
         paint: paint,
         position: position,
         size: size,
         scale: scale,
         angle: angle,
         nativeAngle: nativeAngle,
         anchor: anchor,
         children: children,
         priority: priority,
         key: key,
       );

  /// Returns current value of auto resize flag.
  bool get autoResize => _autoResize;

  /// Sets the given value of autoResize flag. Will update the [size]
  /// to fit srcSize of current sprite if set to  true.
  set autoResize(bool value) {
    _autoResize = value;
    _resizeToSprite();
  }

  /// This flag helps in detecting if the size modification is done by
  /// some external call vs [_autoResize]ing code from [_resizeToSprite].
  bool _isAutoResizing = false;

  /// Returns the current [SpriteAnimation].
  SpriteAnimation? get animation => _animationTicker?.spriteAnimation;

  /// Sets the given [value] as current [animation].
  set animation(SpriteAnimation? value) {
    if (animation != value) {
      if (value != null) {
        _animationTicker = value.createTicker();
      } else {
        _animationTicker = null;
      }
      _resizeToSprite();
    }
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    _animationTicker?.getSprite().render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }

  @mustCallSuper
  @override
  void update(double dt) {
    if (playing) {
      _animationTicker?.update(dt);
      _resizeToSprite();
    }
    if (removeOnFinish && (_animationTicker?.done() ?? false)) {
      removeFromParent();
    }
  }

  /// Updates the size to current [animation] sprite's srcSize if
  /// [autoResize] is true.
  void _resizeToSprite() {
    if (_autoResize) {
      _isAutoResizing = true;

      final newX = _animationTicker?.getSprite().srcSize.x ?? 0;
      final newY = _animationTicker?.getSprite().srcSize.y ?? 0;

      // Modify only if changed.
      if (size.x != newX || size.y != newY) {
        size.setValues(newX, newY);
      }

      _isAutoResizing = false;
    }
  }

  /// Turns off [_autoResize]ing if a size modification is done by user.
  void _handleAutoResizeState() {
    if (_autoResize && (!_isAutoResizing)) {
      _autoResize = false;
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    if (resetOnRemove) {
      _animationTicker?.reset();
    }
  }
}
