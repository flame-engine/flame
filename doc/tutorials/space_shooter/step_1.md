# Getting Started

This tutorial will guide you on the development of a full Flame game, starting from the ground up,
step by step. By the end of it, you will have built a classic Space Shooter game, featuring
animations, input using gestures, mouse and keyboard controls, collision detections, and so on.

This first part will introduce you to:

- `FlameGame`: The base class for games using the Flame Component System.
- `GameWidget`: The `Widget` that will insert your game into the Flutter widget tree.
- `PositionComponent`: One of the most basic Flame components holds both a position and
dimension in the game space.

Let's start by creating our game class and the `GameWidget` that will run it.

```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class SpaceShooterGame extends FlameGame {
}

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
```

That is it! If you run this, you will only see an empty black screen for now, from that, we can
start implementing our game.

Next, let's create our player component. To do so, we will create a new class based on Flame's
`PositionComponent`. This component is the base for all components that have a position and a size
on the game screen. For now, our component will only render a white square; it could be
implemented as follows:

```dart
import 'package:flame/components.dart';

class Player extends PositionComponent {
  static final _paint = Paint()..color = Colors.white;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
```

Now, let's add our new component to the game. Adding any component on game startup should be done
in the `onLoad` method, so let's override `FlameGame.onLoad` and add our logic there. The modified
code will look like the following:

```dart
class SpaceShooterGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}
```

If you run this, you will now see a white rectangle being rendered in the center of the screen.

A couple of points worth commenting:

- `size` is a `Vector2` variable from the game class and it holds the current dimension of the game
area, where `x` is the horizontal dimension or the width, and `y` is the vertical dimension or the
height.
- By default, Flame follows Flutter's canvas anchoring, which means that (0, 0) is anchored on the
top left corner of the canvas. So the game and all components use that same anchor by default. We
can change this by changing our component's `anchor` attribute to `Anchor.center`, which will make
our life way easier if you want to center the component on the screen.

And that is it for this first part! In this first step, we learned the basics of how to create a
game class, insert it into the Flutter widget tree, and render a simple component.

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step1
:show: popup code
```
