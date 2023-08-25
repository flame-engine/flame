import 'package:flame/components.dart';
import 'package:flame/events.dart';
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
    with TapCallbacks {
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
    sprites = {
      ButtonState.up: button!,
      ButtonState.down: buttonDown ?? button!,
    };
    super.onMount();
  }

  @override
  @mustCallSuper
  void onTapDown(_) {
    current = ButtonState.down;
  }

  @override
  @mustCallSuper
  void onTapUp(_) {
    current = ButtonState.up;
    onPressed?.call();
  }

  @override
  @mustCallSuper
  void onTapCancel(_) {
    current = ButtonState.up;
  }
}
