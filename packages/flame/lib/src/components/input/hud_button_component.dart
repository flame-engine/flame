import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

/// The [HudButtonComponent] bundles two [PositionComponent]s, one that shows
/// when the button is being pressed, and one that shows otherwise.
///
/// Note: You have to set the [button] in [onLoad] if you are not passing it in
/// through the constructor.
class HudButtonComponent extends ButtonComponent
    with HasGameRef, ComponentViewportMargin {
  HudButtonComponent({
    super.button,
    super.buttonDown,
    EdgeInsets? margin,
    Function()? super.onPressed,
    Function()? super.onReleased,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : super(
          size: size ?? button?.size,
        ) {
    this.margin = margin;
  }
}
