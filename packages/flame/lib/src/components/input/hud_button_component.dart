import 'package:flutter/rendering.dart' show EdgeInsets, VoidCallback;
import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../extensions.dart';
import '../../../input.dart';
import '../../gestures/events.dart';

class HudButtonComponent extends HudMarginComponent with Tappable {
  late final PositionComponent button;
  late final PositionComponent? buttonDown;

  /// Callback for what should happen when the button is pressed.
  /// If you want to interact with [onTapUp] or [onTapCancel] it is recommended
  /// to extend [HudButtonComponent].
  VoidCallback? onPressed;

  HudButtonComponent({
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
    add(button);
  }

  @override
  @mustCallSuper
  bool onTapDown(TapDownInfo info) {
    if (buttonDown != null) {
      children.remove(button);
      add(buttonDown!);
    }
    onPressed?.call();
    return false;
  }

  @override
  @mustCallSuper
  bool onTapUp(TapUpInfo info) {
    onTapCancel();
    return true;
  }

  @override
  @mustCallSuper
  bool onTapCancel() {
    if (buttonDown != null) {
      children.remove(buttonDown!);
      add(button);
    }
    return false;
  }
}
