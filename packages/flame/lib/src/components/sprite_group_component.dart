import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';

export '../sprite_animation.dart';

/// A [PositionComponent] that can have multiple [Sprite]s and render
/// the one mapped with the [current] key.
class SpriteGroupComponent<T> extends PositionComponent
    with HasPaint
    implements SizeProvider {
  /// Key with the current playing animation
  T? _current;

  /// Map with the available states for this sprite group
  Map<T, Sprite>? _sprites;

  /// When set to true, the component is auto-resized to match the
  /// size of current sprite.
  bool _autoResize;

  /// Creates a component with an empty animation which can be set later
  SpriteGroupComponent({
    Map<T, Sprite>? sprites,
    T? current,
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
    super.key,
  })  : assert(
          (size == null) == (autoResize ?? size == null),
          '''If size is set, autoResize should be false or size should be null when autoResize is true.''',
        ),
        _current = current,
        _sprites = sprites,
        _autoResize = autoResize ?? size == null,
        super(size: size ?? sprites?[current]?.srcSize) {
    if (paint != null) {
      this.paint = paint;
    }

    /// Register a listener to differentiate between size modification done by
    /// external calls v/s the ones done by [_resizeToSprite].
    this.size.addListener(_handleAutoResizeState);
  }

  Sprite? get sprite => _sprites?[current];

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

  /// Returns the sprites map.
  Map<T, Sprite>? get sprites => _sprites;

  /// Sets the given [value] as sprites map.
  set sprites(Map<T, Sprite>? value) {
    if (_sprites != value) {
      _sprites = value;
      _resizeToSprite();
    }
  }

  /// Sets the given value of autoResize flag.
  ///
  /// Will update the [size] to fit srcSize of
  /// current [sprite] if set to  true.
  set autoResize(bool value) {
    _autoResize = value;
    _resizeToSprite();
  }

  /// This flag helps in detecting if the size modification is done by
  /// some external call vs [_autoResize]ing code from [_resizeToSprite].
  bool _isAutoResizing = false;

  @override
  @mustCallSuper
  void onMount() {
    assert(
      _sprites != null,
      'You have to set the sprites in either the constructor or in onLoad',
    );
    assert(
      _current != null,
      'You have to set current in either the constructor or in onLoad',
    );
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    sprite?.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }

  /// Updates the size to current [sprite]'s srcSize if [autoResize] is true.
  void _resizeToSprite() {
    if (_autoResize) {
      _isAutoResizing = true;

      final newX = sprite?.srcSize.x ?? 0;
      final newY = sprite?.srcSize.y ?? 0;

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
