import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:meta/meta.dart';

export '../sprite.dart';

/// A [PositionComponent] that renders a single [Sprite] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This a commonly used subclass of [Component].
class SpriteComponent extends PositionComponent
    with HasPaint
    implements SizeProvider {
  /// When set to true, the component is auto-resized to match the
  /// size of underlying sprite.
  late bool _autoResize;

  /// Returns current value of auto resize flag.
  bool get autoResize => _autoResize;

  /// Sets the given value of autoResize flag.
  /// Will update the size if new value is true.
  set autoResize(bool value) {
    _autoResize = value;
    if (value) {
      size.setFrom(sprite?.srcSize ?? Vector2.zero());
    }
  }

  /// The [sprite] to be rendered by this component.
  Sprite? _sprite;

  /// Returns the current sprite rendered by this component.
  Sprite? get sprite => _sprite;

  /// Sets the given sprite as the new [sprite] of this component.
  /// Will update the size is [autoResize] is set to true.
  set sprite(Sprite? value) {
    _sprite = value;

    if (_autoResize) {
      if (value != null) {
        size.setFrom(value.srcSize);
      } else {
        size.setZero();
      }
    }
  }

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
  })  : assert(
          ((size == null) && (autoResize ?? true)) ||
              ((size != null) && !(autoResize ?? false)),
          '''If size is set, autoResize should be false and vice versa or
          size should be null when autoResize is true''',
        ),
        _autoResize = autoResize ?? size == null,
        _sprite = sprite,
        super(size: size ?? sprite?.srcSize) {
    if (paint != null) {
      this.paint = paint;
    }
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
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) : this(
          sprite: Sprite(
            image,
            srcPosition: srcPosition,
            srcSize: srcSize,
          ),
          autoResize: autoResize,
          paint: paint,
          position: position,
          size: size ?? srcSize ?? image.size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );

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
    );
  }
}
