# flame_cli example

Install the `flame` command:

```shell
dart pub global activate flame_cli
```

Create a new game from the Flame template and start it in debug mode:

```shell
flame create my_game
cd my_game
flame run -d macos
```

From another terminal in the same directory, list the components of the running game, render it
to an image and hot reload it after changing the code:

```shell
flame tree
flame snapshot --output snapshot.png
flame reload
```

Run `flame --help` for all the commands and options.
