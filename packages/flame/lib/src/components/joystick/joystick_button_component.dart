import 'package:flutter/widgets.dart' show EdgeInsets;

import '../../../components.dart';
import '../../../extensions.dart';
import '../../gestures/events.dart';
import 'joystick_element.dart';

class JoystickButtonComponent extends PositionComponent
    with Tappable, HasGameRef {
  @override
  final bool isHud = true;

  final JoystickElement button;
  JoystickElement? buttonPressed;
  JoystickElement? background;

  JoystickButtonComponent({
    required this.button,
    this.buttonPressed,
    this.background,
    EdgeInsets margin = const EdgeInsets.only(left: 100, bottom: 100),
    Vector2? position,
    double? size,
    Anchor anchor = Anchor.center,
  }) : super(
          size: background?.size ?? Vector2.all(size ?? 0),
          position: position,
          anchor: anchor,
        ) {
    if (position == null) {
      final x = margin.right != 0
          ? margin.right
          : gameRef.viewport.effectiveSize.x - margin.right;
      final y = margin.top != 0
          ? margin.top
          : gameRef.viewport.effectiveSize.y - margin.bottom;
      this.position.setValues(x, y);
    }
    if (background != null) {
      addChild(background!);
    }
    addChild(button);
  }

  @override
  bool onTapCancel() {
    if (buttonPressed != null) {
      children.remove(buttonPressed!);
    }
    children.add(button);
    return true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    children.remove(button);
    if (buttonPressed != null) {
      children.add(buttonPressed!);
    }
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    onTapCancel();
    return true;
  }
}
