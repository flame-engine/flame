import 'package:flutter/rendering.dart' show EdgeInsets, VoidCallback;
import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../extensions.dart';
import '../../../input.dart';
import '../../gestures/events.dart';

/// The [HudButtonComponent] bundles two [PositionComponent]s, one that shows
/// when the button is being pressed, and one that shows otherwise.
///
/// Note: if you are setting the [button] in [onLoad] instead of passing it in
/// through the constructor, be sure that you add it to the component too by
/// simply doing `add(button);` and that you also set the [button] variable to
/// your [PositionComponent] with `button = yourPositionComponent;`.
class HudButtonComponent extends HudMarginComponent with Tappable {
  late final PositionComponent? button;
  late final PositionComponent? buttonDown;

  /// Callback for what should happen when the button is pressed.
  /// If you want to interact with [onTapUp] or [onTapCancel] it is recommended
  /// to extend [HudButtonComponent].
  VoidCallback? onPressed;

  HudButtonComponent({
    this.button,
    this.buttonDown,
    EdgeInsets? margin,
    this.onPressed,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          margin: margin,
          position: position,
          size: size ?? button?.size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (button != null) {
      add(button!);
    }
  }

  @override
  @mustCallSuper
  bool onTapDown(TapDownInfo info) {
    if (buttonDown != null) {
      if (button != null) {
        remove(button!);
      }
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
      remove(buttonDown!);
      if (button != null) {
        add(button!);
      }
    }
    return false;
  }
}
