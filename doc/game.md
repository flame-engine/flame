# Game Loop

The Game Loop module is a simple abstraction over the game loop concept. Basically most games are built upon two methods:

* The render method takes the canvas ready for drawing the current state of the game.
* The update method receives the delta time in seconds since last update and allows you to move to the next state.

The class `Game` can be subclassed and will provide both these methods for you to implement. In return it will provide you with a `widget` property that returns the game widget, that can be rendered in your app.

You can either render it directly in your `runApp`, or you can have a bigger structure, with routing, other screens and menus for your game.

To start, just add your game widget directly to your runApp, like this:

```dart
    main() {
        Game game = MyGameImpl();
        runApp(game.widget);
    }
```

Instead of implementing the low level `Game` class, you should probably use the more full-featured `BaseGame` class, or the `Box2DGame` class if you want to use a physics engine.

The `BaseGame` implements a `Component` based `Game` for you; basically it has a list of `Component`s and passes the `update` and `render` calls appropriately. You can still extend those methods to add custom behavior, and you will get a few other features for free, like the passing of `resize` methods (every time the screen is resized the information will be passed to the resize methods of all your components) and also a basic camera feature. The `BaseGame.camera` controls which point in coordinate space should be the top-left of the screen (defaults to [0,0] like a regular `Canvas`).

A very simple `BaseGame` implementation example can be seen below:

```dart
    class MyCrate extends SpriteComponent {

        // creates a component that renders the crate.png sprite, with size 16 x 16
        MyCrate() : super.fromSprite(16.0, 16.0, new Sprite('crate.png'));

        @override
        void resize(Size size) {
            // we don't need to set the x and y in the constructor, we can set then here
            this.x = (size.width - this.width)/ 2;
            this.y = (size.height - this.height) / 2;
        }
    }

    class MyGame extends BaseGame {
        MyGame() {
            add(new MyCrate()); // this will call resize the first time as well
        }
    }
```

To remove components from the list on a `BaseGame` the `markToRemove` method can be used.

## Flutter Widgets and Game instances

Since a Flame game is a widget itself, it is quite easy to use Flutter widgets and Flame game together. But to make it even easier, Flame provides a `mixin` called `HasWidgetsOverlay` which will enable any Flutter widget to be show on top of your game instance, this makes it very easy to create things like a pause menu, or an inventory screen for example.

To use it, simple add the `HasWidgetsOverlay` `mixin` on your game class, by doing so, you will have two new methods available `addWidgetOverlay` and `removeWidgetOverlay`, like the name suggests, they can be used to add or remove widgets overlay above your game. They can be used as shown below:

```dart
addWidgetOverlay(
  "PauseMenu", // Your overlay identifier
  Center(child:
      Container(
          width: 100,
          height: 100,
          color: const Color(0xFFFF0000),
          child: const Center(child: const Text("Paused")),
      ),
  ) // Your widget, this can be any Flutter widget
);

removeWidgetOverlay("PauseMenu"); // Use the overlay identifier to remove the overlay
```

Under the hood, Flame uses a [Stack widget](https://api.flutter.dev/flutter/widgets/Stack-class.html) to display the overlay, so it is important to __note that the order which the overlays are added matters__, where the last added overlay, will be in the front of those added before.

Here you can see a [working example](/doc/examples/with_widgets_overlay) of this feature.

## BaseGame debug mode

Flame's `BaseGame` class provides a method called `debugMode`, which by default returns false. It can however, be overridden to enable debug features over the components of the game. __Be aware__ that the state returned by this method is passed through its component when they added to the game, so if you change the `debugMode` in runtime, it may not affect already added components.

To see more about debugMode on Flame, please refer to the [Debug Docs](/doc/debug.md)


