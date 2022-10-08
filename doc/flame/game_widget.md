# Game Widget

The `GameWidget` is a Flutter `Widget` that is used to insert a [`Game`](game.md) inside the Flutter
widget tree.

It can directly receive a `Game` instance in its default constructor or it can receive a
`GameFactory` function on the `controlled` constructor that will be used to create the game once the
`GameWidget` is inserted in the widget tree.


## Examples

Directly in `runApp`, with either:

```dart
void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}
```

Or:

```dart
void main() {
  runApp(GameWidget.controlled(gameFactory: MyGame.new));
}
```

In a `StatefulWidget`:

```dart
class MyGamePage extends StatefulWidget {
  @override
  State createState() => _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {
  late final MyGame _game;
  
  @override
  void initState() {
    super.initState();
    _game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
```

In a `StatelessWidget` with the `gameFactory` argument:

```dart
class MyGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(gameFactory: MyGame.new);
  }
}
```

Do note that if the `GameWidget.controlled` constructor is used, the `GameWidget.game` field will
always be null.
