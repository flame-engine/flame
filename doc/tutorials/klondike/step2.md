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

For now this class is empty, which means it provides exactly the same 
functionality as the base `FlameGame`, but we'll be adding more stuff inside
very soon.

Let's incorporate this class into the project so that it isn't orphaned. Open
the `main.dart` find the line which says `final game = FlameGame();` and replace
the `FlameGame` with `KlondikeGame`. You will need to import the class too.
After all is done, the file should look like this:

```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'klondike_game.dart';

void main() {
  final game = KlondikeGame();
  runApp(GameWidget(game: game));
}
```



```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step2
:show: popup
```
