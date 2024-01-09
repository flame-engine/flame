# Other Inputs and Helpers

This includes documentation for input methods besides keyboard and mouse.

For other input documents, see also:

- [Gesture Input](gesture_input.md): for mouse and touch pointer gestures
- [Keyboard Input](keyboard_input.md): for keystrokes


## Joystick

Flame provides a component capable of creating a virtual joystick for taking input for your game.
To use this feature, you need to create a `JoystickComponent`, configure it the way you want, and
add it to your game.

Check this example to get a better understanding:

```dart
class MyGame extends FlameGame with HasDraggables {

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
  JoystickPlayer(this.joystick)
    : super(
        anchor: Anchor.center,
        size: Vector2.all(100.0),
      );

  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('layers/player.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
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
[`HudButtonComponent`](#hudbuttoncomponent).

A full examples of how to use it can be found
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_example.dart).
And it can be seen running [here](https://examples.flame-engine.org/#/Input_Joystick).

There is also a more advanced example
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_advanced_example.dart)
which is running [here](https://examples.flame-engine.org/#/Input_Joystick%20Advanced).


## HudButtonComponent

A `HudButtonComponent` is a button that can be defined with margins to the edge of the `Viewport`
instead of with a position. It takes two `PositionComponent`s. `button` and `buttonDown`, the first
is used for when the button is idle and the second is shown when the button is being pressed. The
second one is optional if you don't want to change the look of the button when it is pressed, or if
you handle this through the `button` component.

As the name suggests this button is a hud by default, which means that it will be static on your
screen even if the camera for the game moves around. You can also use this component as a non-hud by
setting `hudButtonComponent.respectCamera = true;`.

If you want to act upon the button being pressed (which would be the common thing to do) and released,
you can either pass in callback functions as the `onPressed` and `onReleased` arguments, or you can
extend the component and override `onTapDown`, `onTapUp` and/or `onTapCancel` and implement your
logic there.


## SpriteButtonComponent

A `SpriteButtonComponent` is a button that is defined by two `Sprite`s, one that represents
when the button is pressed and one that represents when the button is released.


## ButtonComponent

A `ButtonComponent` is a button that is defined by two `PositionComponent`s, one that represents
when the button is pressed and one that represents when the button is released. If you only want
to use sprites for the button, use the [](#spritebuttoncomponent) instead, but this component can be
good to use if you for example want to have a `SpriteAnimationComponent` as a button, or anything
else which isn't a pure sprite.


## Gamepad

Flame has a separate plugin to support external game controllers (gamepads), check
[here](https://github.com/flame-engine/flame_gamepad) for more information.


## AdvancedButtonComponent

The `AdvancedButtonComponent` have separate states for each of the different pointer phases.
The skin can be customized for each state and each skin is represented by a `PositionComponent`.

These are the fields that can be used to customize the looks of the `AdvancedButtonComponent`:

- `defaultSkin`: Component that will be displayed by default on the button.
- `downSkin`: Component displayed when the button is clicked or tapped.
- `hoverSkin`: Component displayed when the button is hovered. (desktop and web).
- `defaultLabel`: Component shown on top of skins. Automatically aligned to center.
- `disabledSkin`: Component displayed when button is disabled.
- `disabledLabel`: Component shown on top of skins when button is disabled.


## ToggleButtonComponent

The [ToggleButtonComponent] is an [AdvancedButtonComponent] that can switch between selected
and not selected.

In addition to the already existing skins, the [ToggleButtonComponent] contains the following skins:

- `defaultSelectedSkin`: The component to display when the button is selected.
- `downAndSelectedSkin`: The component that is displayed when the selectable button is selected and
  pressed.
- `hoverAndSelectedSkin`: Hover on selectable and selected button (desktop and web).
- `disabledAndSelectedSkin`: For when the button is selected and in the disabled state.
- `defaultSelectedLabel`: Component shown on top of the skins when button is selected.


## IgnoreEvents mixin

If you don't want a component subtree to receive events, you can use the `IgnoreEvents` mixin.
Once you have added this mixin you can turn off events to reach a component and its descendants by
setting `ignoreEvents = true` (default when the mixin is added), and then set it to `false` when you
want to receive events again.

This can be done for optimization purposes, since all events currently go through the whole
component tree.
