import 'package:flame/components.dart';
import 'package:meta/meta.dart';

enum ButtonState {
  up,
  down,
}

/// The [SpriteButtonComponent] bundles two [Sprite]s, one that shows while
/// the button is being pressed, and one that shows otherwise.
///
/// Each of the two [Sprite]s correspond to one of the two [ButtonState]s.
/// If needed, state of the button can be manually changed by modifying
/// [current].
///
/// Note: You have to set the [button] in [onLoad] if you are not passing it in
/// through the constructor.
class SpriteButtonComponent extends SpriteGroupComponent<ButtonState>
    with Tappable {
  /// Callback for what should happen when the button is pressed.
  void Function()? onPressed;

  Sprite? button;
  Sprite? buttonDown;

  SpriteButtonComponent({
    this.button,
    this.buttonDown,
    this.onPressed,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : super(
          current: ButtonState.up,
          size: size ?? button?.originalSize,
        );

  @override
  void onMount() {
    assert(
      button != null,
      'The button sprite has to be set either in onLoad or in the constructor',
    );
    sprites = {ButtonState.up: button!};
    sprites![ButtonState.down] = buttonDown ?? button!;
    super.onMount();
  }

  @override
  @mustCallSuper
  bool onTapDown(_) {
    current = ButtonState.down;
    return false;
  }

  @override
  @mustCallSuper
  bool onTapUp(_) {
    onTapCancel();
    return false;
  }

  @override
  @mustCallSuper
  bool onTapCancel() {
    current = ButtonState.up;
    onPressed?.call();
    return false;
  }
}
