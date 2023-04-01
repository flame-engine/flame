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
  Map<T, Sprite>? sprites;

  /// When set to true, the component is auto-resized to match the
  /// size of current sprite.
  bool _autoResize;

  /// Creates a component with an empty animation which can be set later
  SpriteGroupComponent({
    this.sprites,
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
  })  : assert(
          (size == null) == (autoResize ?? size == null),
          '''If size is set, autoResize should be false or size should be null when autoResize is true.''',
        ),
        _current = current,
        _autoResize = autoResize ?? size == null,
        super(size: size ?? sprites?[current]?.srcSize) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  Sprite? get sprite => sprites?[current];

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
  /// Will update the [size] to fit srcSize of
  /// current [sprite] if set to  true.
  set autoResize(bool value) {
    _autoResize = value;
    _resizeToSprite();
  }

  @override
  @mustCallSuper
  void onMount() {
    assert(
      sprites != null,
      'You have to set the sprites in either the constructor or in onLoad',
    );
    assert(
      current != null,
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
      if (sprite != null) {
        size.setFrom(sprite!.srcSize);
      } else {
        size.setZero();
      }
    }
  }
}
