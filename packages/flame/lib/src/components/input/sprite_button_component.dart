import 'package:flame/components.dart';

enum _ButtonState {
  up,
  down,
}

/// The [SpriteButtonComponent] bundles two [Sprite]s, one that shows while
/// the button is being pressed, and one that shows otherwise.
///
/// Note: You have to set the [button] in [onLoad] if you are not passing it in
/// through the constructor.
class SpriteButtonComponent extends SpriteGroupComponent<_ButtonState>
    with Tappable {
  /// Callback for what should happen when the button is pressed.
  void Function()? onPressed;

  Sprite? button;
  Sprite? buttonDown;

  SpriteButtonComponent({
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
          current: _ButtonState.up,
          position: position,
          size: size ?? button?.originalSize,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );

  @override
  void onMount() {
    assert(
      button != null,
      'The button sprite has to be set either in onLoad or in the constructor',
    );
    sprites = {_ButtonState.up: button!};
    sprites![_ButtonState.down] = buttonDown ?? button!;
    super.onMount();
  }

  @override
  bool onTapDown(_) {
    current = _ButtonState.down;
    return false;
  }

  @override
  bool onTapUp(_) {
    onTapCancel();
    return false;
  }

  @override
  bool onTapCancel() {
    current = _ButtonState.up;
    onPressed?.call();
    return false;
  }
}
