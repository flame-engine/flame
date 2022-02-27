# 1. Preparation

Before you begin any kind of game project, you need to give it a **name**. For
this tutorial the name will be simply `klondike`.

Having this name in mind, please head over to the [](../bare_flame_game.md) 
tutorial and complete the necessary set up steps. When you come back, you should
already have the `main.dart` file with the following content:

```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = FlameGame();
  runApp(GameWidget(game: game));
}
```

## Planning

The start of any project usually feels overwhelming. Where even to begin?
I always find it useful to create a rough sketch of what I am about to code,
so that it can serve as a reference point. My sketch for the Klondike game is
shown below:

![](../../images/tutorials/klondike-sketch.webp)

Here you can see both the general layout of the game, as well as names of
various objects. These names are the [standard terminology] for solitaire games.
Which is really lucky, because normally figuring out good names for various
classes is a quite challenging task.

Looking at this sketch, we can already imagine the high-level overview of the
game. Obviously, there will be a `Card` class, but also the `Stock` class, the
`Waste` class, a `Tableau` containing seven `Pile`s, and 4 `Foundation`s. There
may also be a `Deck`. All of these components will be tied together via the
`KlondikeGame` derived from the `FlameGame`.


[standard terminology]: https://en.wikipedia.org/wiki/Solitaire_terminology
