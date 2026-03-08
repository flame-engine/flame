import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/sprite_animation_ticker.dart';

/// A version of a component that renders a synchronized animation using
/// an external [animationTicker].
///
/// This allows multiple components to share the same ticker, synchronizing
/// their animations and reducing the count of [update] calls by centralizing
/// the animation logic in a parent or manager.
class UnifiedAnimationChildComponent extends PositionComponent with HasPaint {
  UnifiedAnimationChildComponent({
    required this.animationTicker,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    Paint? paint,
    super.key,
  }) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  /// The shared [SpriteAnimationTicker] used by this component.
  final SpriteAnimationTicker animationTicker;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animationTicker.getSprite().render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }
}
