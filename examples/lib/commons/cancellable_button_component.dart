import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Convenience class to fix the current lack of [onTapCancel]
/// in [AdvancedButtonComponent].
class CancellableButtonComponent extends AdvancedButtonComponent {
  CancellableButtonComponent({
    super.onPressed,
    super.onReleased,
    super.onChangeState,
    super.defaultSkin,
    super.downSkin,
    super.hoverSkin,
    super.disabledSkin,
    super.defaultLabel,
    super.disabledLabel,
    super.size,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  @override
  void onTapCancel(TapCancelEvent event) {
    if (isDisabled) {
      return;
    }
    isPressed = false;
    updateState();
  }
}
