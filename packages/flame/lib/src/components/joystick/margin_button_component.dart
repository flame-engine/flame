import 'package:flutter/rendering.dart' show EdgeInsets, VoidCallback;

import '../../../components.dart';
import '../../../extensions.dart';
import '../../gestures/events.dart';
import 'margin_hud_component.dart';

class MarginButtonComponent extends MarginHudComponent with Tappable {
  late final PositionComponent button;
  late final PositionComponent? buttonDown;

  /// Callback for what should happen when the button is pressed.
  /// If you want to interact with [onTapUp] or [onTapCancel] it is recommended
  /// to extend [MarginButtonComponent].
  VoidCallback? onPressed;

  MarginButtonComponent({
    required this.button,
    this.buttonDown,
    EdgeInsets? margin,
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    this.onPressed,
  }) : super(
          margin: margin,
          position: position,
          size: size ?? button.size,
          anchor: anchor,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addChild(button);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (buttonDown != null) {
      children.remove(button);
      addChild(buttonDown!);
    }
    onPressed?.call();
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    onTapCancel();
    return true;
  }

  @override
  bool onTapCancel() {
    if (buttonDown != null) {
      children.remove(buttonDown!);
      addChild(button);
    }
    return false;
  }
}
