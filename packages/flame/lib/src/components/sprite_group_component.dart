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
  T? current;

  /// Map with the available states for this sprite group
  Map<T, Sprite>? sprites;

  /// Creates a component with an empty animation which can be set later
  SpriteGroupComponent({
    this.sprites,
    this.current,
    Paint? paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  Sprite? get sprite => sprites?[current];

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
}
