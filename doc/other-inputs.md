# Other inputs

This includes documentation for input methods besides keyboard and mouse.

For other input documents, see also:

- [Gesture Input](gesture-input.md): for mouse and touch pointer gestures
- [Keyboard Input](keyboard-input.md): for keystrokes

## Joystick

Flame provides a component capable of creating a virtual joystick for taking input for your game.
To use this feature, you need to create a `JoystickComponent`, configure it the way you want, and
add it to your game.

Check this example to get a better understanding:

```dart
class MyGame extends FlameGame with HasDraggableComponents {

  MyGame() {
    joystick.addObserver(player);
    add(player);
    add(joystick);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    final joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2.all(100),
      ),
      background: SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2.all(150),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    final player = Player(joystick);
    add(player);
    add(joystick);
  }
}

class JoystickPlayer extends SpriteComponent with HasGameRef {
  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick)
      : super(
          size: Vector2.all(100.0),
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('layers/player.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.velocity * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
}
```

So in this example, we create the classes `MyGame` and `Player`. `MyGame` creates a joystick which is
passed to the `Player` when it is created. In the `Player` class we act upon the current state of
the joystick.

The joystick has a few fields that change depending on what state it is in.
These are the fields that should be used to know the state of the joystick:
 - `intensity`: The percentage [0.0, 1.0] that the knob is dragged from the epicenter to the edge of
  the joystick (or `knobRadius` if that is set).
 - `delta`: The absolute amount (defined as a `Vector2`) that the knob is dragged from its epicenter.
 - `velocity`: The percentage, presented as a `Vector2`, and direction that the knob is currently
  pulled from its base position to a edge of the joystick.

If you want to create buttons to go with your joystick, check out
[`MarginButtonComponent`](#HudButtonComponent).

A full examples of how to use it can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/joystick.dart).
And it can be seen running [here](https://examples.flame-engine.org/#/Controls_Joystick).

## HudButtonComponent

A `HudButtonComponent` is a button that can be defined with margins to the edge of the `Viewport`
instead of with a position. It takes two `PositionComponent`s. `button` and `buttonDown`, the first
is used for when the button is idle and the second is shown when the button is being pressed. The
second one is optional if you don't want to change the look of the button when it is pressed, or if
you handle this through the `button` component.

As the name suggests this button is a hud by default, which means that it will be static on your
screen even if the camera for the game moves around. You can also use this component as a non-hud by
setting `hudButtonComponent.isHud = false;`.

If you want to act upon the button being pressed (which would be the common thing to do) you can either pass in
a callback function as the `onPressed` argument, or you extend the component and override
`onTapDown`, `onTapUp` and/or `onTapCancel` and implement your logic in there.

## Gamepad

Flame has a separate plugin to support external game controllers (gamepads), checkout
[here](https://github.com/flame-engine/flame_gamepad) for more information.
