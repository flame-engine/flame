# 2. Scaffolding

In this section we will use broad strokes to outline the main elements of the
game. This includes the main game class, and the general layout.


## KlondikeGame

In Flame universe, the **FlameGame** class is the cornerstone of most games.
This class runs the game loop, dispatches events, owns all the components that
comprise the game (the component tree), and usually also serves as the central
repository for the game's state.

So, create a new file called `klondike_game.dart` inside the `lib/` folder, and
declare the `KlondikeGame` class inside:

```dart
import 'package:flame/game.dart';

class KlondikeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');
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

I am loading the image into the global `Flame.images` cache here. An alternative
approach is to load it into the `Game.images` cache instead, but then it would
have been more difficult to access that image from other classes.

Also note that I am `await`ing the image to finish loading before initializing
anything else in the game. This is for convenience: it means that by the time
all other components are initialized, they can assume the spritesheet is already
loaded. We can even add a helper function to extract a sprite from the common
spritesheet:

```dart
Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
```

This helper function won't be needed in this chapter, but will be used
extensively in the next.

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

So far we have the main `KlondikeGame` class, and now we need to create objects
that we will add to the game. In Flame these objects are called *components*,
and when added to the game they form a "game component tree". All entities that
exist in the game must be components.

As we already mentioned in the previous chapter, our game mainly consists of
`Card` components. However, since drawing the cards will take some effort, we
will defer implementation of that class to the next chapter.

For now, let's create the container classes, as shown on the sketch. These are:
`Stock`, `Waste`, `Pile` and `Foundation`. In your project directory create a
sub-directory `components`, and then the file `components/stock.dart`. In that
file write

```dart
import 'package:flame/components.dart';

class Stock extends PositionComponent {
  @override
  bool get debugMode => true;
}
```

Here we declare the `Stock` class as a `PositionComponent` (which is a component
that has a position and size). We also turn on the debug mode for this class so
that we can see it on the screen even though we don't have any rendering logic
yet.

Likewise, create three more classes `Foundation`, `Pile` and `Waste`, each in
its corresponding file. For now all four classes will have exactly the same
logic inside, we'll be adding more functionality into those classes in
subsequent chapters.

At this moment the directory structure of your game should look like this:

```text
klondike/
 ├─assets/
 │  └─images/
 │     └─klondike-sprites.png
 ├─lib/
 │  ├─components/
 │  │  ├─foundation.dart
 │  │  ├─pile.dart
 │  │  ├─stock.dart
 │  │  └─waste.dart
 │  ├─klondike_game.dart
 │  └─main.dart
 ├─analysis_options.yaml
 └─pubspec.yaml
```


## Game structure

Once we have some basic components, they need to be added to the game. It is
time to make a decision about the high-level structure of the game.

There exist multiple approaches here, which differ in their complexity,
extendability, and overall philosophy. The approach that we will be taking in
this tutorial is based on using the [World] component, together with a [Camera].

The idea behind this approach is the following: imagine that your game **world**
exists independently from the device, that it exists already in our heads, and
on the sketch, even though we haven't done any coding yet. This world will have
a certain size, and each element in the world will have certain coordinates. It
is up to us to decide what will be the size of the world, and what is the unit
of measurement for that size. The important part is that the world exists
independently from the device, and its dimensions likewise do not depend on the
pixel resolution of the screen.

All elements that are part of the world will be added to the `World` component,
and the `World` component will be then added to the game.

The second part of the overall structure is a **camera** (`CameraComponent`).
The purpose of the camera is to be able to look at the world, to make sure that
it renders at the right size on the screen of the user's device.

Thus, the overall structure of the component tree will look approximately like
this:

```text
KlondikeGame
 ├─ World
 │   ├─ Stock
 │   ├─ Waste
 │   ├─ Foundation (×4)
 │   └─ Pile (×7)
 └─ CameraComponent
```

```{note}
The **Camera** system described in this tutorial is different from the
"official" camera available as a property of the `FlameGame` class. The latter
may become deprecated in the future.
```

For this game I've been drawing my image assets having in mind the dimension of
a single card at 1000×1400 pixels. So, this will serve as the reference size for
determining the overall layout. Another important measurement that affects the
layout is the inter-card distance. It seems like it should be somewhere between
150 to 200 units (relative to the card width), so we will declare it as a
variable `cardGap` that can be adjusted later if needed. For simplicity, both
the vertical and horizontal inter-card distance will be the same, and the
minimum padding between the cards and the edges of the screen will also be equal
to `cardGap`.

Alright, let's put all this together and implement our `KlondikeGame` class.

First, we declare several global constants which describe the dimensions of a
card and the distance between cards. We declare them as constants because we are
not planning to change these values during the game:

```dart
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
```

Next, we will create a `Stock` component, the `Waste`, four `Foundation`s and
seven `Pile`s, setting their sizes and positions in the world. The positions
are calculated using simple arithmetics. This should all happen inside the
`onLoad` method, after loading the spritesheet:

```dart
    final stock = Stock()
      ..size = cardSize
      ..position = Vector2(cardGap, cardGap);
    final waste = Waste()
      ..size = cardSize
      ..position = Vector2(cardWidth + 2 * cardGap, cardGap);
    final foundations = List.generate(
      4,
      (i) => Foundation()
        ..size = cardSize
        ..position =
            Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
    );
    final piles = List.generate(
      7,
      (i) => Pile()
        ..size = cardSize
        ..position = Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
    );
```

Then we create the main `World` component, add to it all the components that
we just created, and finally add the `world` to the game.

```dart
    final world = World()
      ..add(stock)
      ..add(waste)
      ..addAll(foundations)
      ..addAll(piles);
    add(world);
```

```{note}
You may be wondering when you need to `await` the result of `add()`, and when
you don't. The short answer is: usually you don't need to wait, but if you want
to, then it won't hurt either.

If you check the documentation for `.add()` method, you'll see that the returned
future only waits until the component is finished loading, not until it is
actually mounted to the game. As such, you only have to wait for the future from
`.add()` if your logic requires that the component is fully loaded before it can
proceed. This is not very common.

If you don't `await` the future from `.add()`, then the component will be added
to the game anyways, and in the same amount of time.
```

Lastly, we create a camera object to look at the `world`. Internally, the camera
consists of two parts: a **viewport** and a **viewfinder**. The default viewport
is `MaxViewport`, which takes up the entire available screen size -- this is
exactly what we need for our game, so no need to change anything. The
viewfinder, on the other hand, needs to be set up to properly take the
dimensions of the underlying world into account.

We want the entire card layout to be visible on the screen without the need to
scroll. In order to accomplish this, we specify that we want the entire world
size (which is `7*cardWidth + 8*cardGap` by `4*cardHeight + 3*cardGap`) to be
able to fit into the screen. The `.visibleGameSize` setting ensures that no
matter the size of the device, the zoom level will be adjusted such that the
specified chunk of the game world will be visible.

The game size calculation is obtained like this: there are 7 cards in the
tableau and 6 gaps between them, add 2 more "gaps" to account for padding, and
you get the width of `7*cardWidth + 8*cardGap`. Vertically, there are two rows
of cards, but in the bottom row we need some extra space to be able to display
a tall pile -- by my rough estimate, thrice the height of a card is sufficient
for this -- which gives the total height of the game world as
`4*cardHeight + 3*cardGap`.

Next, we specify which part of the world will be in the "center" of the
viewport. In this case I specify that the "center" of the viewport should
be at the top center of the screen, and the corresponding point within
the game world is at coordinates `[(7*cardWidth + 8*cardGap)/2, 0]`.

The reason for such choice for the viewfinder's position and anchor is
because of how we want it to respond if the game size becomes too wide or
too tall: in case of too wide we want it to be centered on the screen,
but if the screen is too tall, we want the content to be aligned at the
top.

```dart
    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera);
```

If you run the game now, you should see the placeholders for where the various
components will be. If you are running the game in the browser, try resizing the
window and see how the game responds to this.

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step2
:show: popup code
```

And this is it with this step -- we've created the basic game structure upon
which everything else will be built. In the next step, we'll learn how to render
the card objects, which are the most important visual objects in this game.

[World]: ../../flame/camera_component.md#world
[Camera]: ../../flame/camera_component.md#cameracomponent
