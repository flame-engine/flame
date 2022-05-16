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
  /// If you want to interact with [onTapUp] or [onTapCancel] it is recommended
  /// to extend [ButtonComponent].
  void Function()? onPressed;

  ButtonComponent({
    this.button,
    this.buttonDown,
    this.onPressed,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) : super(
          position: position,
          size: size ?? button?.size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
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
