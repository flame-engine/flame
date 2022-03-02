# 2. Scaffolding

In this section we will use broad strokes in order to outline the main elements
of the game. This includes the main game class, and the general layout.

## KlondikeGame

In Flame universe, the `Game` class is the cornerstone of any game. This class
runs the game loop, dispatches events, owns all the components that comprise 
the game (the component tree), and usually also serves as the central
repository for the game's state.

So, create a new file called `klondike_game.dart` inside the `lib/` folder, and
declare the `KlondikeGame` class inside:

```dart
import 'package:flame/game.dart';

class KlondikeGame extends FlameGame {
  
}
```

```{flutter-app}
:sources: ../tutorials/klondike/app
```
