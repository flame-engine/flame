
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
topmost page from the stack.


[Flutter Navigator]: https://api.flutter.dev/flutter/widgets/Navigator-class.html
