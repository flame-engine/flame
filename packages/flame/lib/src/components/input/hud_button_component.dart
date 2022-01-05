import 'package:flutter/rendering.dart' show EdgeInsets;
import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../input.dart';

/// The [HudButtonComponent] bundles two [PositionComponent]s, one that shows
/// when the button is being pressed, and one that shows otherwise.
///
/// Note: You have to set the [button] in [onLoad] if you are not passing it in
/// through the constructor.
class HudButtonComponent extends HudMarginComponent with Tappable {
  late final PositionComponent? button;
  late final PositionComponent? buttonDown;

  /// Callback for what should happen when the button is pressed.
  /// If you want to directly interact with [onTapUp], [onTapDown] or
  /// [onTapCancel] it is recommended to extend [HudButtonComponent].
  void Function()? onPressed;

  /// Callback for what should happen when the button is released.
  /// If you want to directly interact with [onTapUp], [onTapDown] or
  /// [onTapCancel] it is recommended to extend [HudButtonComponent].
  void Function()? onReleased;

  HudButtonComponent({
    this.button,
    this.buttonDown,
    EdgeInsets? margin,
    this.onPressed,
    this.onReleased,
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
  @mustCallSuper
  void onMount() {
    assert(
      button != null,
      'The button has to either be passed in as an argument or set in onLoad',
    );
    final idleButton = button;
    if (idleButton != null && !contains(idleButton)) {
      add(idleButton);
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
    onReleased?.call();
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
