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
  SpriteButtonComponent({
    Sprite? button,
    Sprite? buttonDown,
    this.onPressed,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : _button = button,
       _buttonDown = buttonDown,
       super(
         current: ButtonState.up,
         size: size ?? button?.originalSize,
       );

  /// Callback for what should happen when the button is pressed.
  void Function()? onPressed;

  Sprite? _button;
  Sprite? _buttonDown;

  Sprite get button => _button!;
  Sprite get buttonDown => _buttonDown ?? button;

  set button(Sprite value) {
    _button = value;
    if (isLoaded) {
      updateSprite(ButtonState.up, value);
    }
  }

  set buttonDown(Sprite value) {
    _buttonDown = value;
    if (isLoaded) {
      updateSprite(ButtonState.down, value);
    }
  }

  @override
  void onMount() {
    assert(
      _button != null,
      'The button sprite has to be set either in onLoad or in the constructor',
    );
    if (size.isZero()) {
      size = _button!.originalSize;
    }
    sprites = {
      ButtonState.up: _button!,
      ButtonState.down: buttonDown,
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
