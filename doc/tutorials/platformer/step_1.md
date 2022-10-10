# 1. Preparation

Before you begin any kind of game project, you need an idea of what you want to
make and I like to then give it a **name**. For this tutorial and game, I got
inspiration from @spydon's tweet about the Flame game engine GitHub repository
reaching 7000 stars and I thought, excellent! Ember will be on a quest to gather
as many stars as possible and I will call the game, `Ember Quest`.

Now it is time to get started but first, you need to go to the tutorial and
complete the necessary setup steps. When you come back, you should already have
the `main.dart` file with the following content:

```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = FlameGame();
  runApp(GameWidget(game: game));
}
```


## Planning

Like in the [klondike](../klondike/klondike.md) tutorial, starting a new game
can feel overwhelming. Starting with a simple sketch (it doesn't have to be
perfect as mine is very rough) is the best way to get an understanding of what
will need to be accomplished. Take for instance the below sketch, we know we will
need the following:

- Player Class
- Player Data Class (this will handle health and coin count)
- Coin Class
- Platform Class
- Enemy Class
- HUD Controls Class

![Sketch of Ember Escapades](../../images/tutorials/emberescapades-sketch.png)

All of these will be brought together in `EmberQuestGame` derived from `FlameGame`.
