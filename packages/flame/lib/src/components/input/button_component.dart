import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:meta/meta.dart';

/// The [ButtonComponent] bundles two [PositionComponent]s, one that shows while
/// the button is being pressed, and one that shows otherwise.
///
/// Note: You have to set the [button] in [onLoad] if you are not passing it in
/// through the constructor.
class ButtonComponent extends PositionComponent with Tappable {
  late final PositionComponent? button;
  late final PositionComponent? buttonDown;

  /// Callback for what should happen when the button is pressed.
  /// If you want to interact with [onTapCancel] it is recommended
  /// to extend [ButtonComponent].
  void Function()? onPressed;

  /// Callback for what should happen when the button is released.
  /// If you want to interact with [onTapCancel] it is recommended
  /// to extend [ButtonComponent].
  void Function()? onReleased;

  ButtonComponent({
    this.button,
    this.buttonDown,
    this.onPressed,
    this.onReleased,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : super(
          size: size ?? button?.size,
        );

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
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
    button?.removeFromParent();
    buttonDown?.changeParent(this);
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
    buttonDown?.removeFromParent();
    button?.changeParent(this);
    return false;
  }
}
