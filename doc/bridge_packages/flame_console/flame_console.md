# flame_console

Flame Console is a terminal overlay for Flame games which allows developers to debug and interact
with their games.

It offers an overlay that can be plugged in to your `GameWidget` which when activated will show a
terminal-like interface written with Flutter widgets where commands can be executed to see
information about the running game and components, or perform actions.

It comes with a set of built-in commands, but it is also possible to add custom commands.


## Usage

Flame Console is an overlay, so to use it, you will need to register it in your game widget.

Then, showing the overlay is up to you, below we see an example of a floating action button that will
show the console when pressed.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: GameWidget(
      game: _game,
      overlayBuilderMap: {
        'console': (BuildContext context, MyGame game) => FlameConsoleView(
              game: game,
              onClose: () {
                _game.overlays.remove('console');
              },
            ),
      },
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'console_button',
      onPressed: () {
        _game.overlays.add('console');
      },
      child: const Icon(Icons.developer_mode),
    ),
  );
}
```


## Built-in commands

- `help` - List available commands and their usage.
- `ls` - List components.
- `rm` - Remove components.
- `debug` - Toggle debug mode on components.
- `pause` - Pauses the game loop.
- `resume` -Resumes the game loop.


## Custom commands

 Custom commands can be created by extending the `FlameConsoleCommand` class and adding them to the
 the `customCommands` list in the `ConsoleView` widget.

 ```dart
class MyCustomCommand extends FlameConsoleCommand<MyGame> {
  @override
  String get name => 'my_command';

  @override
  String get description => 'Description of my command';

  // The execute method should return a tuple where the first
  // element is an error message (in case of failure), and the second
  // element is the output of the command.
  @override
  (String?, String) execute(MyGame game, ArgResults args) {
    // do something on the game
    return (null, 'Hello World');
  }
}
```

Then when creating the `ConsoleView` widget, add the custom command to the `customCommands` list.

```dart
ConsoleView(
  game: game,
  customCommands: [MyCustomCommand()],
  onClose: () {
    _game.overlays.remove('console');
  },
),
```


## Customizing the console UI

The console look and feel can also be customized. When creating the `ConsoleView` widget, there are
a couple of properties that can be used to customize it:

- `containerBuilder`: It is used to created the decorated container where the history and the
command input is displayed.
- `cursorBuilder`: It is used to create the cursor widget.
- `historyBuilder`: It is used to create the scrolling element of the history, by default a simple
`SingleChildScrollView` is used.
- `cursorColor`: The color of the cursor. Can be used when just wanting to change the color
of the cursor.
- `textStyle`: The text style of the console.

