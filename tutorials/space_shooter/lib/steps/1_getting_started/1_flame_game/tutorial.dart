const tutorial = ['''
# Getting Started

This tutorial will guide you on the development of a full Flame game, starting from the ground,
step by step. By the end of it, you will have build a classic Space Shooter game, featuring
animations, gesture, mouse and keyboard controls, collision detections and so on.

This first part will introduce you to: 
 - `FlameGame`: The base class for games using the Flame Component system.
 - `GameWidget`: The Widget that will insert your game into the Flutter widget tree
 - `PositionComponent`: One of the most basic Flame components which is a component that has both
a position and dimensions in the game space.

Lets start by creating our game class and the `GameWidget` that will run it.

''','''
```
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class SpaceShooterGame extends FlameGame {
}

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
```
''','''
That is it! If you run this, you will only see an empty black screen for now, but now we have the
bare-bones needed to start implementing our game.

Next, we can add our player component, to do so, we will create a new class based on Flame's
`PositionComponent`, this component is the base for all components that has a postion and dimension
on the game. For now, our component will render a white square, such component could be implemented
as the follow:
''','''```
import 'package:flame/components.dart';

class Player extends PositionComponent {
  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), Paint()..color = Colors.white);
  }
}
```
''','''
Now we need to add our new component to our game. Any component addition on game start up should be
done on the `onLoad` method, so lets override `FlameGame.onLoad` and add our logic, the modified
source will like the follow:
''','''```
class SpaceShooterGame extends FlameGame {
  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    add(
      Player()
        ..x = size.x / 2
        ..y = size.y / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}
```''','''
If you run this, you will now see a white retangle being rendered in the center of the screen, a
couple of points worth commenting at this point:

 - Always call `await super.onLoad()` as the first instruction of your custom `onLoad` method.
 - `size` is a `Vector2` variable from game and it holds the current dimension of the game area,
where `x` is the horizontal dimension, or the width, and `y` the vertical, or the height.
 - By the default, Flame follows Flutter canvas anchor, which means that (0, 0) is anchored on the
top left of the canvas, so the game and all components uses that same anchor by default, we can
change this by changing our component `anchor` attribute to center, which will make our life way
easier to put the component on the center of the screen.

And that is it for this first part, on this first step we learned the basics on how to create a
game class, insert it into the Flutter widget tree, and render a simple component.
''',
];
