
```{flutter-app}
:sources: ../flame/examples
:page: router
:show: widget code infobox

This example app shows the use of the `RouterComponent` to move across multiple screens within
the game. In addition, the "pause" button stops time and applies visual effects to the content of
the page below it.
```


# RouterComponent

The **RouterComponent**'s job is to manage navigation across multiple screens within the game. It is
similar in spirit to Flutter's [Navigator][Flutter Navigator] class, except that it works with Flame 
components instead of Flutter widgets.

A typical game will usually consists of multiple pages: the splash screen, the starting menu page,
the settings page, credits, the main game page, several pop-ups, etc. The router will organize
all these destinations and allow you to transition between them.

Internally, the `RouterComponent` contains a stack of routes. When you request it to show a route,
it will be placed on top of all other pages in the stack. Later you can `popPage()` to remove the
topmost page from the stack. The pages of the router are addressed by their unique names.

Each page in the router can be either transparent or opaque. If a page is opaque, then the pages
below it in the stack are not rendered, and do not receive pointer events (such as taps or drags).
On the contrary, if a page is transparent, then the page below it will be rendered and receive
events normally. Such transparent pages are useful for implementing modal dialogs, inventory or
dialogue UIs, etc.

Usage example:
```dart
class MyGame extends FlameGame {
  late final RouterComponent navigator;

  @override
  Future<void> onLoad() async {
    add(
      router = RouterComponent(
        routes: {
          'home': Route(builder: HomePage()),
          'level-selector': Route(builder: LevelSelectorPage()),
          'settings': Route(builder: SettingsPage(), transparent: true),
          'pause': PauseRoute(),
        },
        initialRoute: 'home',
      ),
    );
  }
}
```

[Flutter Navigator]: https://api.flutter.dev/flutter/widgets/Navigator-class.html


## Route

The **Route** component holds information about the content of a particular page. `Route`s are
mounted as children to the `RouterComponent`.

The main property of a `Route` is its `builder` -- the function that creates the component with
the content of its page.
