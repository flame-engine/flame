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
    PositionComponent? button,
    PositionComponent? buttonDown,
    EdgeInsets? margin,
    Function()? onPressed,
    Function()? onReleased,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) : super(
          button: button,
          buttonDown: buttonDown,
          position: position,
          onPressed: onPressed,
          onReleased: onReleased,
          size: size ?? button?.size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        ) {
    this.margin = margin;
  }
}
