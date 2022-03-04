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
  @override
  Future<void> onLoad() async {
    await Images.load('klondike-sprites.png');
  }
}
```

For now we only declared the `onLoad` method, which is a special handler that
is called when the game instance is attached to the Flutter widget tree for the
first time. You can think of it as a delayed asynchronous constructor. 
Currently, the only thing that `onLoad` does is that it loads the sprites image
into the game; but we will be adding more soon. Any image or other resource that
you want to use in the game needs to be loaded first, which is a relatively slow
I/O operation, hence the need for `await` keyword.

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


## Layout




```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step2
:show: popup
```
