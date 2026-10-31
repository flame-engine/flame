import 'package:flame/components.dart' as flame;
import 'package:flame_studio/component_editor/widgets/preview/dashed_outline.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview_position_component.dart';
import 'package:flutter/painting.dart';

/// {@template preview_sprite_component}
/// The Flame component that previews a sprite component.
///
/// Flame's `SpriteComponent` asserts that it has a sprite when it is
/// mounted, but here the image may not be picked or decoded yet, or may be
/// missing. Until there is a [sprite] it is outlined like a
/// [PreviewPositionComponent], so it stays visible.
/// {@endtemplate}
class PreviewSpriteComponent() extends flame.PositionComponent {
  /// {@macro preview_sprite_component}
  this;

  /// The sprite drawn, filling the size of the component.
  flame.Sprite? sprite;

  static final _outlinePaint = Paint()
    ..color = PreviewPositionComponent.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    final sprite = this.sprite;
    if (sprite != null) {
      sprite.render(canvas, size: size);
      return;
    }
    final rect = size.toRect();
    drawDashedPolygon(canvas, [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ], _outlinePaint);
  }
}
