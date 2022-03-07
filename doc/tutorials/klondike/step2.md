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


## Other classes

So far we have the main `KlondikeGame` class, so now we need to create objects
that we will add to the game. In Flame these objects are called _components_,
and when added to the game they form a "game component tree". All entities that
exist in the game must be components.

As we already mentioned in the previous chapter, our game mainly consists of
`Card` components. However, since drawing the cards will take some effort, we
will defer implementation of that class to the next chapter.

For now, let's create the container classes, as shown on the sketch. These are:
`Stock`, `Waste`, `Pile` and `Foundation`. In your project directory create a
sub-directory "components", and then the file `components/stock.dart`. In that
file write

```dart
import 'package:flame/components.dart';

class Stock extends PositionComponent {
  bool get debugMode => true;
}
```

Here we declare the `Stock` class as a `PositionComponent` (which is a component
that has a position and size). We also turn on the debug mode for this class so
that we can see it on the screen even though we don't have any rendering logic
yet.

Likewise, create three more files `components/foundation.dart`,
`components/pile.dart`, and `components/waste.dart`. For now all 4 classes will
have exactly the same logic inside, we'll be adding more functionality into 
those classes in subsequent chapters.

Once the classes are created, we should add those objects into the game. In 
order to do that, open the `KlondikeGame` class and add the following:

```dart
class KlondikeGame extends FlameGame {
  late final Stock stock;
  late final Waste waste;
  late final List<Foundation> foundations;
  late final List<Pile> piles;

  @override
  Future<void> onLoad() async {
    await images.load('klondike-sprites.png');
    stock = Stock();
    waste = Waste();
    foundations = [for (var i = 0; i < 4; i++) Foundation()];
    piles = [for (var i = 0; i < 7; i++) Pile()];

    add(stock);
    add(waste);
    addAll(foundations);
    addAll(piles);
  }
}
```

If you run the game at this point, you won't see much difference: it will still
be a black canvas, although with a small squiggle in the top left corner. This
is because even though we added the `Stock` etc components to the game, we 
haven't given them any _layout_ -- and by default the size and position of every
component is zero. Such components will hardly be visible, even when the debug
mode is on.


## Layout

So, how do we create a layout?


```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step2
:show: popup
```
