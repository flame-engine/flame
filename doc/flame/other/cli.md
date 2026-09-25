# Flame CLI

The [flame_cli](https://pub.dev/packages/flame_cli) package provides the `flame` command, which
inspects and controls a Flame game that is running in debug mode, without having to open the
[DevTools](debug.md#devtools-extension).

This is useful for scripts, and for AI coding agents that want to see what the game currently looks
like. The agent can start the game with `flame run`, take a snapshot with `flame snapshot` and then
read the PNG image:

```shell
flame run -d macos
flame pause
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

Prints the component tree of the game, together with the id and the attributes of every
component:

```shell
$ flame tree
MyGame (id: 6126309)
  World (id: 729356887) priority -2147483647
    Player (id: 220731871) position 100,200, size 32,32, anchor center
    Enemy (id: 220731872) position 300,200, size 32,32, angle 1.57, anchor center
  CameraComponent (id: 167418721)
    Viewfinder (id: 429571719)
    MaxViewport (id: 703047016) size 800,600
```

Attributes with their default value, such as an angle of `0` or the `topLeft` anchor, are left
out. The id of a component is its `hashCode`, so it stays the same for as long as the component
exists, but it changes when the game is restarted.

These are the options, in addition to `--uri`:

- `--filter` (`-f`): A regular expression, matched case insensitively against the type of the
  components. Only the matching components are shown, together with their ancestors and their
  children. For example `flame tree --filter enemy` shows all the enemies and where they are in
  the tree.
- `--depth` (`-d`): The number of levels below the game to show, for example `1` shows only the
  direct children of the game.
- `--json`: Prints the tree as JSON instead of text. Every node has an `id`, a `name`, the
  `toString` of the component, its `attributes` and its `children`.


### inspect

Prints the details of a single component:

```shell
$ flame inspect 220731871
type: Player
id: 220731871
parent: 729356887
children: 2
debugMode: false
priority: 0
position: 100.0, 200.0
size: 32.0, 32.0
angle: 0.0
scale: 1.0, 1.0
anchor: center
toString: Player()
```

The position, size, angle, scale and anchor are only shown for a `PositionComponent`. Pass
`--json` to get the same information as JSON.


### set

Changes the attributes of a component and prints its details afterwards:

```shell
flame set 220731871 --position 150,200 --angle 0.5
```

These are the attributes that can be changed:

- `--position`: The position, as `x,y`.
- `--size`: The size, as `width,height`.
- `--angle`: The angle in radians.
- `--scale`: The scale, as `x,y` or as a single number that is used for both.
- `--anchor`: The anchor, as a name like `center` or `bottomRight`, or as `x,y` between 0 and 1.
- `--priority`: The render priority.

The priority can be changed on any component, the other attributes only on a `PositionComponent`.


### pause, resume and step

The game loop can be paused and resumed, and a paused game can be advanced frame by frame:

```shell
flame pause
flame step --frames 60
flame snapshot
flame resume
```

`step` takes `--frames` (`-n`) for the number of frames to advance, and `--time` (`-t`) for the
time in seconds that passes in each frame, which is a sixtieth of a second by default. It pauses
the game first if it is running.

Pausing the game before taking a snapshot makes the snapshot stable, and stepping a fixed number of
frames between snapshots makes the comparison repeatable.


### debug

Shows or changes the debug mode, which renders hitboxes, bounds and other debug information on top
of the components:

```shell
flame debug on
flame snapshot
flame debug off
```

Without `on` or `off` it prints the current state. Pass `--component <id>` to change the debug
mode of a single component instead of the whole game.


### overlays and overlay

`overlays` lists the registered overlays of the game and which of them are shown:

```shell
$ flame overlays
PauseMenu (shown)
Settings
```

`overlay show <name>` and `overlay hide <name>` show or hide a single overlay without affecting
the others, and `overlay only <name>` shows one overlay and hides all the others. Overlays are
Flutter widgets, so they are not part of the images that `snapshot` takes.


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
