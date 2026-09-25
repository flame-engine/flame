# Flame CLI

The [flame_cli](https://pub.dev/packages/flame_cli) package provides the `flame` command, which
inspects and controls a Flame game that is running in debug mode, without having to open the
[DevTools](debug.md#devtools-extension).

This is useful for scripts, and for AI coding agents that want to see what the game currently looks
like. The agent can start the game with `flame run`, take a snapshot with `flame snapshot` and then
read the PNG image:

```shell
flame run -d macos
flame snapshot --output snapshot.png
```


## Installation

The CLI is a pure Dart package, so it can be activated globally once and then used for all of your
projects:

```shell
dart pub global activate flame_cli
```

After that the `flame` command is available, as long as the pub cache `bin` directory is on your
`PATH`.

You can also add it as a development dependency of your project instead:

```shell
dart pub add dev:flame_cli
```

and then run it with `dart run flame_cli` instead of `flame`, for example
`dart run flame_cli snapshot`.


## Connecting to a game

The commands connect to the game through the Dart VM Service, so the game has to be running in
debug mode. The URI of the service contains a random secret, so it can't be guessed and has to come
from the tool that started the game.

The easiest way is to start the game with [flame run](#run) from your project directory. The other
commands then find the game on their own, as long as they are run from the project directory or
one of its subdirectories.

If you start the game in another way, for example from your IDE, pass the URI of the service to
the commands with the `--uri` (`-u`) option. `flutter run` prints it when the game has started:

```text
A Dart VM Service on macOS is available at: http://127.0.0.1:50300/abc123=/
```

Both the `http` URI above and the `ws` URI of the service are accepted. You can also let your IDE
write the URI to the same file that `flame run` uses, by adding
`--vmservice-out-file=.dart_tool/flame/vm_service_uri` to the arguments that it passes to
`flutter run`. The commands then find the game without `--uri`.

If you have multiple games in your app, only the last one created is connected, see
`DevToolsService.initWithGame` to change it.


## Commands

Run `flame --help` to list the commands, and `flame help <command>` for the options of a
command.


### run

Runs the game with `flutter run`, and writes the URI of the Dart VM Service to
`.dart_tool/flame/vm_service_uri` in the project, so that the other commands can find the game:

```shell
flame run -d macos
```

All the arguments are passed on to `flutter run`, and it works just like `flutter run`, including
hot reload from the terminal. The file is removed again when the game is stopped. The `.dart_tool`
directory is ignored by version control in Flutter projects, so the file is never committed.

When an agent or a script starts the game with `flame run` in the background, the other commands
say that no running game was found until the game has started, so they can be retried until they
succeed.


### snapshot

Renders the whole game to a PNG image:

```shell
flame snapshot --output snapshot.png
```

The game is rendered through the camera and with the game's background color, the same way that it
is currently shown on the screen. Flutter overlays are not part of the game canvas, so they are not
included in the image. The command prints the absolute path of the written image.

These are the options:

- `--uri` (`-u`): The Dart VM Service URI of the running game, not needed when the game was
  started with `flame run`.
- `--output` (`-o`): The file that the PNG image is written to, by default `flame_snapshot.png`.
- `--pixel-ratio` (`-p`): Renders the image in a higher resolution, for example `2` renders an
  800x600 game to a 1600x1200 image.
- `--component` (`-c`): The id of a single component to render instead of the whole game, see the
  [tree](#tree) command for how to find the id.

A single component is rendered together with its children, but without the camera. For a
`PositionComponent`, the image covers the component's bounding rectangle, with its anchor, angle
and scale taken into account. Other components are rendered in a 100x100 image.

```shell
flame snapshot --component 220731871
```


### tree

Prints the component tree of the game, together with the id of every component:

```shell
$ flame tree
MyGame (id: 6126309)
  World (id: 729356887)
    Player (id: 220731871)
  CameraComponent (id: 167418721)
    Viewfinder (id: 429571719)
    MaxViewport (id: 703047016)
```

It takes the same `--uri` option as `snapshot`. The id of a component is its `hashCode`, so it
stays the same for as long as the component exists, but it changes when the game is restarted.


## Exit codes

The commands follow the common Unix conventions for exit codes, so that scripts can tell failures
apart. `flame run` exits with the exit code of `flutter run`, and the other commands use these:

- `0`: The command succeeded.
- `64`: The command was used incorrectly, for example with an invalid option.
- `65`: The game rejected the input, for example because there is no component with the given
  id.
- `69`: No running game was found, the game could not be reached, or it runs a version of Flame
  that does not support the command.
- `70`: The game reported an error while running the command.
- `73`: The output file could not be written.


## Compatibility

The commands use the [service extensions](debug.md#service-extensions) that Flame registers for its
DevTools extension. If the game runs an older version of Flame that does not have the service
extension that a command needs, the command says so and exits with `69`, update Flame in that case.
