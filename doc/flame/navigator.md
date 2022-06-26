
```{flutter-app}
:sources: ../flame/examples
:page: navigator
:show: widget code infobox

This example app shows the use of the `Navigator` component to move across multiple screens within
the game. In addition, the "pause" button stops time and applies visual effects to the content of
the page below it.
```


# Navigator

The **Navigator** is a component whose job is to manage navigation across multiple screens within
the game. It is similar in spirit to Flutter's [Navigator][Flutter Navigator] class, except that it
works with Flame components instead of Flutter widgets.

A typical game will usually consists of multiple pages: the splash screen, the starting menu page,
the settings page, credits, the main game page, several pop-ups, etc. The `Navigator` will organize
all these destinations and allow you to transition between them.

Internally, the `Navigator` contains a stack of pages. When you request it to show a page, that
page will be placed on top of all other pages in the stack. Later you can `popPage()` to remove the
topmost page from the stack. The pages of the Navigator are addressed by their unique names.

Each Page in the Navigator can be either transparent or opaque. If a page is opaque, then the pages
below it in the stack are not rendered, and do not receive pointer events (such as taps or drags).
On the contrary, if a page is transparent, then the page below it will be rendered and receive
events normally. Such transparent pages are useful for implementing modal dialogs, inventory or
dialogue UIs, etc.


Usage example:
```dart
class MyGame extends FlameGame {
  late final Navigator navigator;

  @override
  Future<void> onLoad() async {
    navigator = Navigator(
      pages: {
        'home': Page(builder: HomePageComponent()),
        'level-selector': Page(builder: LevelSelectorPageComponent()),
        'settings': Page(builder: SettingsPageComponent(), transparent: true),
        'pause': PausePage(),
      },
      initialPage: 'home',
    );
  }
}
```

[Flutter Navigator]: https://api.flutter.dev/flutter/widgets/Navigator-class.html


## Page

The **Page** component holds information about the content of a particular screen. `Page`s are
mounted as children to the `Navigator`.

The main property of a `Page` is its `builder` -- the function that creates the component which is
the content of this page.
