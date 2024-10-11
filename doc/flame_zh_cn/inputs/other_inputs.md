# Other Inputs and Helpers

这包括键盘和鼠标以外的输入方法的文档。

有关其他输入文档，请参见：

- [手势输入](gesture_input.md)：用于鼠标和触控指针手势
- [键盘输入](keyboard_input.md)：用于按键输入


## Joystick

Flame 提供了一个组件，可以创建一个虚拟操纵杆，用于接收游戏输入。

要使用此功能，你需要创建一个 `JoystickComponent`，根据你的需求进行配置，然后将其添加到你的游戏中。

查看以下示例，以便更好地理解：

```dart
class MyGame extends FlameGame {

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

class Player extends SpriteComponent with HasGameRef {
  Player(this.joystick)
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
      position.add(joystick.relativeDelta  * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
}
```

在这个示例中，我们创建了 `MyGame` 和 `Player` 类。`MyGame` 创建了一个操纵杆，并在创建 `Player` 时将其传递给 `Player`。在 `Player` 类中，我们根据操纵杆的当前状态进行操作。

操纵杆有几个字段，根据其状态而变化。

以下字段应用于了解操纵杆的状态：

- `intensity`：从中心到操纵杆边缘（或设置的 `knobRadius`）拖动旋钮的百分比 [0.0, 1.0]。
- `delta`：旋钮从其中心点拖动的绝对量（定义为 `Vector2`）。
- `relativeDelta`：表示为 `Vector2` 的百分比和方向，旋钮当前从其基准位置拉动到操纵杆边缘。

如果你想创建与操纵杆配合使用的按钮，可以查看 [`HudButtonComponent`](#hudbuttoncomponent)。

要查看实现操纵杆的完整代码，请参见 [操纵杆示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_example.dart)。

你还可以查看 [JoystickComponent 的实际效果](https://examples.flame-engine.org/#/Input_Joystick)，以查看操纵杆输入功能集成到游戏中的实时示例。

作为额外挑战，可以探索 [高级操纵杆示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_advanced_example.dart)。

查看高级功能在 [实时演示](https://examples.flame-engine.org/#/Input_Joystick_Advanced) 中可以做些什么。


## HudButtonComponent

`HudButtonComponent` 是一个按钮，可以使用与 `Viewport` 边缘的边距来定义位置，而不是直接设置位置。它接受两个 `PositionComponent`：`button` 和 `buttonDown`，第一个用于按钮处于静止状态时，第二个在按钮被按下时显示。如果不想在按钮被按下时更改外观，或者如果通过 `button` 组件处理这种情况，第二个组件是可选的。

顾名思义，这个按钮默认是一个 HUD，这意味着即使游戏的相机移动，它也会在屏幕上保持静止。你也可以通过设置 `hudButtonComponent.respectCamera = true;` 将该组件用作非 HUD。

如果你希望在按钮被按下（这是常见的做法）和释放时执行某些操作，可以将回调函数作为 `onPressed` 和 `onReleased` 参数传递，或者可以扩展该组件，重写 `onTapDown`、`onTapUp` 和/或 `onTapCancel` 并在其中实现你的逻辑。


## SpriteButtonComponent

`SpriteButtonComponent` 是一个按钮，由两个 `Sprite` 定义，一个表示按钮被按下时的状态，另一个表示按钮释放时的状态。


## ButtonComponent

`ButtonComponent` 是一个按钮，由两个 `PositionComponent` 定义，一个表示按钮被按下时的状态，另一个表示按钮释放时的状态。

如果你只想使用精灵作为按钮，请使用 [](#spritebuttoncomponent)，但如果你想要将 `SpriteAnimationComponent` 或其他非纯精灵的组件用作按钮，这个组件将是一个不错的选择。


## Gamepad

Flame 有一个专门的插件来支持外部游戏控制器（游戏手柄）。有关更多信息，请查看 [Gamepads repository](https://github.com/flame-engine/gamepad)。


## AdvancedButtonComponent

`AdvancedButtonComponent` 为每种不同的指针阶段提供了独立的状态。每个状态的外观可以自定义，每种外观由一个 `PositionComponent` 表示。

以下字段可用于自定义 `AdvancedButtonComponent` 的外观：

- `defaultSkin`：默认情况下在按钮上显示的组件。
- `downSkin`：按钮被点击或触摸时显示的组件。
- `hoverSkin`：按钮被悬停时显示的组件（适用于桌面和网页）。
- `defaultLabel`：显示在外观上方的组件。自动居中对齐。
- `disabledSkin`：按钮禁用时显示的组件。
- `disabledLabel`：按钮禁用时显示在外观上方的组件。


## ToggleButtonComponent

[ToggleButtonComponent] 是一个 [AdvancedButtonComponent]，可以在选中和未选中之间切换。

除了已有的外观， [ToggleButtonComponent] 还包含以下外观：

- `defaultSelectedSkin`：按钮被选中时显示的组件。
- `downAndSelectedSkin`：当可选择的按钮被选中并按下时显示的组件。
- `hoverAndSelectedSkin`：在可选择且已选中的按钮上悬停时显示的组件（适用于桌面和网页）。
- `disabledAndSelectedSkin`：当按钮被选中并处于禁用状态时显示的组件。
- `defaultSelectedLabel`：按钮被选中时显示在外观上方的组件。


## IgnoreEvents mixin

如果你不希望组件子树接收事件，可以使用 `IgnoreEvents` 混入。一旦添加了这个混入，你可以通过设置 `ignoreEvents = true`（添加混入时的默认值）来关闭到达组件及其子组件的事件，然后在想要重新接收事件时将其设置为 `false`。

这样做可以出于优化目的，因为所有事件当前都需要经过整个组件树。
