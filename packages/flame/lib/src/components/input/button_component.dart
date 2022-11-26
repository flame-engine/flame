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
  void Function()? onPressed;

  /// Callback for what should happen when the button is released.
  void Function()? onReleased;

  /// Callback for what should happen when the button is cancelled.
  void Function()? onCancelled;

  ButtonComponent({
    this.button,
    this.buttonDown,
    this.onPressed,
    this.onReleased,
    this.onCancelled,
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
    if (!contains(button!)) {
      add(button!);
    }
  }

  @override
  @mustCallSuper
  bool onTapDown(TapDownInfo info) {
    if (buttonDown != null) {
      button!.removeFromParent();
      buttonDown!.parent = this;
    }
    onPressed?.call();
    return false;
  }

  @override
  @mustCallSuper
  bool onTapUp(TapUpInfo info) {
    if (buttonDown != null) {
      buttonDown!.removeFromParent();
      button!.parent = this;
    }
    onReleased?.call();
    return true;
  }

  @override
  @mustCallSuper
  bool onTapCancel() {
    if (buttonDown != null) {
      buttonDown!.removeFromParent();
      button!.parent = this;
    }
    onCancelled?.call();
    return false;
  }
}
