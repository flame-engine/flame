import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

export '../sprite.dart';

/// A [PositionComponent] that renders a single [Sprite] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This a commonly used subclass of [Component].
class SpriteComponent extends PositionComponent with HasPaint {
  /// When set to true, the component is auto-resized to match the
  /// size of underlying sprite.
  bool _autoResize;

  /// The [sprite] to be rendered by this component.
  Sprite? _sprite;

  /// Creates a component with an empty sprite which can be set later
  SpriteComponent({
    Sprite? sprite,
    bool? autoResize,
    Paint? paint,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    this.bleed,
    super.key,
  })  : assert(
          (size == null) == (autoResize ?? size == null),
          '''If size is set, autoResize should be false or size should be null when autoResize is true.''',
        ),
        _autoResize = autoResize ?? size == null,
        _sprite = sprite,
        super(size: size ?? sprite?.srcSize) {
    if (paint != null) {
      this.paint = paint;
    }

    /// Register a listener to differentiate between size modification done by
    /// external calls v/s the ones done by [_resizeToSprite].
    this.size.addListener(_handleAutoResizeState);
  }

  SpriteComponent.fromImage(
    Image image, {
    Vector2? srcPosition,
    Vector2? srcSize,
    bool? autoResize,
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
    double? bleed,
  }) : this(
          sprite: Sprite(
            image,
            srcPosition: srcPosition,
            srcSize: srcSize,
          ),
          autoResize: autoResize,
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          nativeAngle: nativeAngle,
          anchor: anchor,
          children: children,
          priority: priority,
          bleed: bleed,
          key: key,
        );

  /// Returns current value of auto resize flag.
  bool get autoResize => _autoResize;

  /// Sets the given value of autoResize flag. Will update the [size]
  /// to fit srcSize of [sprite] if set to  true.
  set autoResize(bool value) {
    _autoResize = value;
    _resizeToSprite();
  }

  /// This flag helps in detecting if the size modification is done by
  /// some external call vs [_autoResize]ing code from [_resizeToSprite].
  bool _isAutoResizing = false;

  /// Returns the current sprite rendered by this component.
  Sprite? get sprite => _sprite;

  /// Sets the given sprite as the new [sprite] of this component.
  /// Will update the size if [autoResize] is set to true.
  set sprite(Sprite? value) {
    _sprite = value;
    _resizeToSprite();
  }

  double? bleed;

  @override
  @mustCallSuper
  void onMount() {
    assert(
      sprite != null,
      'You have to set the sprite in either the constructor or in onLoad',
    );
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    sprite?.render(
      canvas,
      size: size,
      overridePaint: paint,
      bleed: bleed,
    );
  }

  /// Updates the size [sprite]'s srcSize if [autoResize] is true.
  void _resizeToSprite() {
    if (_autoResize) {
      _isAutoResizing = true;

      final newX = _sprite?.srcSize.x ?? 0;
      final newY = _sprite?.srcSize.y ?? 0;

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
}
