# Flame CLI

The [flame_cli](https://pub.dev/packages/flame_cli) package provides the `flame` command, which
inspects and controls a Flame game that is running in debug mode, without having to open the
[DevTools](debug.md#devtools-extension).

This is useful for scripts, and for AI coding agents that want to see what the game currently looks
like. The agent can create a game with `flame create`, start it with `flame run`, take a snapshot
with `flame snapshot` and then read the PNG image:

```shell
flame create my_game
cd my_game
flame run -d macos
flame pause
flame snapshot --output snapshot.png
```

Every command except `run` also takes `--json`, which prints the result and any error as JSON, see
[using the CLI from scripts and agents](#using-the-cli-from-scripts-and-agents).


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


### Running several instances of one game

A running game is tied to its project, the closest directory with a `pubspec.yaml`. Games started
from different projects never interfere with each other, and that includes separate git checkouts
of the same game: the commands pick the game of the project they are run in.

You can also start the same project several times, for example to test on two devices at once or
to compare two builds of the game:

```shell
flame run -d macos
flame run -d chrome
```

The commands go to the game that was started last, in this case the one in Chrome. When that game
is stopped, the game started before it becomes reachable again, and the [logs](#logs) command
shows the output of whichever game the commands currently go to.

To reach a game that was not started last, address it explicitly. Every `flame run` prints the two
things needed for that when it starts:

```text
flame run: reload, restart, stop and status reach this game on port 50312.
...
A Dart VM Service on macOS is available at: http://127.0.0.1:50300/abc123=/
```

Pass the URI with `--uri` to the commands that talk to the game, and the port with `--port` to
`reload`, `restart`, `stop` and `status`:

```shell
flame snapshot --uri http://127.0.0.1:50300/abc123=/ --output macos.png
flame reload --port 50312
flame stop --port 50312
```

A script that drives several instances can keep the URI and the port of each one and pass them
every time, so that it never depends on which game was started last.


## Commands

Run `flame --help` to list the commands, and `flame help <command>` for the options of a
command.


### create

Creates a new Flame game, the same way `flutter create` creates a new Flutter app: without
questions, with sensible defaults, and with options to change them:

```shell
flame create my_game
cd my_game
flame run
```

It runs `flutter create` for the platform folders and the `pubspec.yaml`, writes the files of the
chosen template on top of it, replaces `flutter_lints` with `flame_lint`, and adds `flame` (and
`flame_test` when the template has tests) with `flutter pub add`, so that the game starts on the
newest versions. The result is a normal Flutter project that `flutter run`, your IDE and the other
`flame` commands all understand.

These are the options:

- `--project-name`: The name of the game, a valid Dart package name. It defaults to the name of
  the output directory, so `flame create my_game` creates the package `my_game`.
- `--org`: The organization in reverse domain name notation, used for the bundle and package
  identifiers, `com.example` by default.
- `--description`: The description in the `pubspec.yaml`.
- `--template` (`-t`): The template to start from, see below. The default is `basics`.
- `--platforms`: The platforms to generate folders for, as a comma separated list such as
  `macos,web`, passed on to `flutter create`. All of them by default.
- `--packages`: Additional Flame packages to add, for example `--packages flame_audio,flame_tiled`.
- `--flame-version`: A version constraint for `flame`, for example `^1.30.0`, instead of the
  newest version.
- `--overwrite`: Replace the files of a game that already exists in the output directory.

These are the templates:

- `simple`: The emptiest possible game, an empty `FlameGame` in a `GameWidget`, for starting from
  scratch.
- `basics`: The structure that most games start from, a world with a component that reacts to
  taps, and a test for it.
- `example`: A complete small game with a world, a camera, keyboard and tap input, collisions, a
  score in the viewport and tests, spread over a few files, to show how the pieces fit together.

Every template comes with `flame_lint` as its analysis options, and the games from the `basics`
and `example` templates pass `flutter analyze` and `flutter test` right after they are created.


### run

Runs the game with `flutter run`, and writes the URI of the Dart VM Service to
`.dart_tool/flame/vm_service_uri` in the project, so that the other commands can find the game:

```shell
flame run -d macos
```

All the arguments are passed on to `flutter run`, and it works just like `flutter run`, including
the keys in the terminal such as `r` for hot reload and `q` to quit. Next to the URI, `flame run`
keeps two more files in `.dart_tool/flame`: `control_port`, through which the [reload and
restart](#reload-and-restart), [stop](#stop) and [status](#status) commands talk to it, and `log`,
which the [logs](#logs) command reads. The URI and the port are removed when the game is stopped,
the log is kept. The `.dart_tool` directory is ignored by version control in Flutter projects, so
the files are never committed.

The files live in the root of the project, the closest directory with a `pubspec.yaml`, no matter
which subdirectory `flame run` was started from. That ties every running game to its project, and
the same project can be started several times, see
[running several instances of one game](#running-several-instances-of-one-game).

When an agent or a script starts the game with `flame run` in the background, the other commands
say that no running game was found until the game has started, so they can be retried until they
succeed, or the script can wait for [status](#status) to succeed. Since `flame run` reads the
terminal input like `flutter run` does, redirect its input from `/dev/null` when it runs in the
background of an interactive shell:

```shell
flame run -d macos < /dev/null > run.log 2>&1 &
```


### reload and restart

Hot reloads or hot restarts a game that was started with `flame run`, and waits for the result:

```shell
$ flame reload
Reloaded 1 of 1097 libraries in 71ms.
```

This is the same as pressing `r` or `R` in the terminal of `flame run`, but it can be done from
another terminal or from a script, and the command only returns when the reload is done. If the
reload fails, for example because of a compile error, the errors are printed and the command exits
with `70`, so an agent can fix the code and try again:

```shell
$ flame reload
lib/main.dart:19:44: Error: Expected ';' after this.
        paint: Paint()..color = Colors.orange
                                       ^^^^^^
Try again after fixing the above error(s).
```

Both commands take `--port` (`-p`) to reach a specific `flame run` when several games were
started from the same project, see [run](#run).

A hot reload swaps the code but keeps the state of the game, so a change to something that was
set when a component was created, such as a paint in its constructor or a position in `onLoad`,
is only visible after a hot restart. Changes to `update` and `render` methods show up right away.
Component ids change with a restart, so run `tree` again afterwards.


### stop

Stops a game that was started with `flame run`, and waits until it has exited:

```shell
$ flame stop
Stopped the game.
```

This is the same as pressing `q` in the terminal of `flame run`. The command returns once
`flutter run` has exited and `flame run` has removed the URI and the port of the game, so the next
`flame run` can be started right away. It takes `--port` (`-p`) like [reload and
restart](#reload-and-restart). If no game is running it exits with `69`, and if `flutter run` does
not exit within two minutes it exits with `70`.


### status

Shows whether the game that was started with `flame run` is running, and whether it can be
reached:

```shell
$ flame status
Running: yes
Project: /path/to/my_game
Control port: 50312
Process id of flutter run: 12345
Dart VM Service URI: ws://127.0.0.1:50300/abc123=/ws
Reachable: yes
Paused: no
```

The command exits with `0` only when the game is running and the Flame game in it can be reached
through the Dart VM Service, and with `69` otherwise. That includes the time while the game is
still starting, so a script that starts the game in the background can wait for it:

```shell
flame run -d macos < /dev/null > run.log 2>&1 &
until flame status > /dev/null; do sleep 1; done
```

These are the options:

- `--json`: Prints the status as JSON instead of text, with the fields `running`,
  `projectDirectory`, `controlPort`, `processId`, `vmServiceUri`, `reachable` and `paused`, and
  an `error` that says why the game is not running or not reachable. Fields that are not known are
  left out.
- `--port` (`-p`): The control port of a specific `flame run`, see [run](#run).
- `--uri` (`-u`): Checks a game that was not started with `flame run` instead, by its Dart VM
  Service URI. Only the URI, whether the game is reachable and whether it is paused are reported
  then.


### logs

Prints the output of the `flutter run` that `flame run` started, which includes everything the
game prints and the exceptions it throws:

```shell
flame logs --lines 50
```

`--lines` (`-n`) is the number of lines from the end to print, 100 by default, and `--follow`
(`-f`) keeps printing new output until the game is stopped. The log is kept after the game has
stopped, so it can still be read after a crash.


### devtools

Opens the Flutter DevTools for the running game in the browser, where the Flame tab holds the
[Flame DevTools extension](debug.md#devtools-extension):

```shell
flame devtools
```

The command checks that the game is reachable and then runs `dart devtools` with the URI of the
game, so it needs the Dart SDK on the `PATH` like the other commands need Flutter, and it keeps
serving the DevTools until it is stopped with `Ctrl+C`. The game is found the same way as by the
other commands, so `--uri` (`-u`) reaches a game that was not started with `flame run`. With
`--no-launch-browser` only the URL of the DevTools is printed, to open it in a browser of your
choice or to hand it to someone else.

The DevTools only show the tab of an extension that is enabled in the `devtools_options.yaml` of
the project, and ask whether to enable it otherwise. The command enables the Flame extension in
that file before it starts the DevTools, creating the file if the project has none and keeping the
other settings in it, so the Flame tab is there right away. The DevTools open on their overview
page, select the Flame tab to get to the extension.


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
- `--world` (`-w`): Renders the whole world directly instead of through the camera, so that
  components that are off screen are visible too. The image covers the bounding rectangle of all
  the position components in the world.
- `--rect` (`-r`): Renders only this part of the world, given as `x,y,width,height` in world
  coordinates, for example `--rect -100,-100,200,200`.
- `--max-size` (`-m`): The maximum length in pixels of the longest side of the image, for example
  `--max-size 1024` to keep the image within the limits of an AI model. The image is rendered with
  a lower pixel ratio when it would be larger, so the aspect ratio is kept and nothing is cropped.
- `--annotate` (`-a`): Draws the outline of every visible position component on the image,
  labeled with its id and type, see [annotated snapshots](#annotated-snapshots).
- `--filter` (`-f`): A regular expression, matched case insensitively against the type of the
  components like for [tree](#tree), so that only the matching components are annotated. It needs
  `--annotate`.

A single component is rendered together with its children, but without the camera. For a
`PositionComponent`, the image covers the component's bounding rectangle, with its anchor, angle
and scale taken into account. For the `World` it covers all the position components in it, like
`--world`. Other components are rendered in a 100x100 image.

```shell
flame snapshot --component 220731871
```

The pixel coordinates of a snapshot of the whole game, at the default pixel ratio, are the same
coordinates that the [input](#input) commands take, so a position found in the image can be
tapped directly.

When `--max-size` lowers the pixel ratio, the command prints the size of the image and the pixel
ratio that it was rendered with before the path. Divide a pixel coordinate by that pixel ratio to
get the canvas coordinate.


#### Annotated snapshots

With `--annotate` the outline of every visible `PositionComponent` is drawn on top of the image,
together with a label that holds the id of the component and its type. The outlines follow the
component through the camera, so they are rotated and scaled with the viewfinder and the viewport,
and they line up with the image in all the modes above, at any pixel ratio. This lets an AI model
match what it sees in the image with the output of [tree](#tree), and then use the ids with
[inspect](#inspect), [set](#set) or `snapshot --component`.

The annotated components are also printed, one per line before the path of the image, with their
bounding box in the pixel coordinates of the image as `x,y,width,height`:

```shell
$ flame snapshot --annotate --filter 'player|enemy'
Player (id: 220731871) box 368,268,64,64
Enemy (id: 220731872) box 568,268,64,64
/path/to/flame_snapshot.png
```

Components that are hidden with `HasVisibility`, that have no size, or that are outside of the
image or the viewport are left out, and the labels are moved apart when they would cover each
other. In a busy game, use `--filter` to only annotate the components you are interested in.


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


### input

Sends taps, drags and key presses to the game, so that it can be played from the terminal:

```shell
flame input tap 400,300
flame input drag 100,300 500,300 --steps 20
flame input key space
flame input key arrowLeft --down
flame input key arrowLeft --up
```

Positions are in canvas coordinates, the same ones as the pixels of a `snapshot` of the whole
game at pixel ratio 1. The events go through the same dispatchers as real input, so they reach the
components with the `TapCallbacks` and `DragCallbacks` mixins, in the same order and with the same
propagation rules. A drag sends a start event, `--steps` update events (10 by default) evenly
spaced between the two positions, and an end event, all at once. If the game has no component
that handles the event, the command fails with exit code `65` and says which mixin is missing.

Instead of a position, a tap or either end of a drag can target a component, which is easier than
finding its pixels in a snapshot:

```shell
$ flame input tap --component 220731871
Tapped component 220731871 at 412.5,300.
$ flame input tap --component 220731871 --anchor topLeft
$ flame input drag --from-component 220731871 600,300
$ flame input drag 100,300 --to-component 81726354
$ flame input drag --from-component 220731871 \
    --to-component 81726354 --to-anchor 0.5,0
```

A component is given by its id, as `tree` prints it, or by the name of its `ComponentKey`, for
example `--component player` for a component created with `key: ComponentKey.named('player')`. A
value that is a number is always used as an id. The component has to be a `PositionComponent`,
and by default its center is targeted. `--anchor` for a tap, and `--from-anchor` and `--to-anchor`
for a drag, target another point of the component, either as an anchor name like `topLeft` or
`bottomCenter`, or as `x,y` between `0` and `1`, where `0,0` is the top left corner.

The game converts the point to canvas coordinates through all the transforms that the component is
rendered with, including the viewfinder and viewport of the camera when the component is in a
world, and the command prints where the event was sent. When several cameras show the world, the
`camera` of the game is used if it is one of them. If the component is not visible on the canvas,
for example because it is outside of the view of the camera, the command fails with exit code `65`
instead of sending the event.

Keys are delivered to the `onKeyEvent` of a game with the `HasKeyboardHandlerComponents` or
`KeyboardEvents` mixin. A key is named like the `LogicalKeyboardKey` constants, for example
`space`, `enter`, `escape`, `arrowLeft`, `a` or `digit1`, and the name is matched without regard
to case, spaces and underscores. By default the key is pressed and released right away. Pass
`--down` to hold it, for example to keep a character walking while stepping the game, and `--up`
to release it again.


### wait

Blocks until a condition holds in the game, or until a timeout is reached, so that a script or an
agent doesn't have to sleep and guess how long something takes. For example, tap a button and wait
until the game over overlay is shown:

```shell
flame input tap 400,300
flame wait overlay GameOver
```

The command checks the condition right away and then again at a fixed interval, all over one
connection to the game. When the condition holds it prints what matched and exits with `0`. When
the timeout is reached first it says what it found instead and exits with `75`, which is also the
case when the game doesn't answer in time, for example because it is stopped at a breakpoint. If
the game stops while waiting it exits with `69` like the other commands.

These are the conditions:

- `wait component <type pattern>`: Waits until a component exists whose type matches the regular
  expression, matched case insensitively like `tree --filter`, and prints the matching components
  with their ids and attributes. `Enemy` also matches `EnemyBullet`, use `^Enemy$` to match only
  the type `Enemy`.
- `wait overlay <name>`: Waits until the overlay is shown, or with `--hidden` until it is hidden.
  An overlay that isn't registered fails right away with `65`.
- `wait paused` and `wait resumed`: Wait until the game loop is paused or running.

The `component` condition takes these options to narrow it down:

- `--id`: Only matches the component with this id. The type pattern can be left out then.
- `--where` (`-w`): Only matches the components with a numeric attribute that compares to a value,
  for example `--where "position.x > 100"`. The attributes are `position.x`, `position.y`,
  `size.x`, `size.y`, `scale.x`, `scale.y`, `angle` and `priority`, and the operators are `<`,
  `<=`, `>`, `>=`, `==` and `!=`. Quote the condition, since the shell would otherwise treat `>`
  and `<` as redirecting input and output. It can be given several times, and all of them have to
  hold.
- `--count` (`-n`): Waits until exactly this number of components match.
- `--at-least`: Waits until at least this number of components match.
- `--gone`: Waits until no components match, for example until a component has been removed.

```shell
flame wait component Enemy --at-least 3
flame wait component --id 220731871 --gone
flame wait component Player --where "position.x >= 500" --timeout 30
```

These options are shared by all the conditions, in addition to `--uri`:

- `--timeout` (`-t`): The number of seconds to wait, 10 by default. With `0` the condition is
  checked once, which works as an assertion in a script.
- `--interval` (`-i`): The number of seconds between two checks, `0.2` by default.
- `--json`: Prints what matched as JSON instead of text. For `component` that is the list of
  matching components, with the same fields as in `tree --json` but without the children, for
  `overlay` the same as `overlays --json`, and for `paused` and `resumed` whether the game is
  paused.

A paused game doesn't change, so a condition that depends on the game loop only holds once the game
is resumed or stepped.


### diff

Compares two PNG images, for example two snapshots, and reports how much and where they differ:

```shell
$ flame diff before.png after.png --output diff.png
4.17% of the pixels differ (20000 of 480000), within the rectangle
300,250 of size 200x100.
/path/to/diff.png
```

The bounding rectangle of the changes makes it easy to tell what moved, even when the difference
is too small to notice by looking at the two images. With `--output` the differing pixels are
written in red on top of a dimmed version of the second image. `--threshold` (`-t`) is how much
a color channel may differ, from 0 to 255, before a pixel counts as different, which helps with
anti-aliasing. `--exit-code` makes the command exit with `1` when the images differ, like
`git diff`, for use in scripts.


## Using the CLI from scripts and agents

Every command that prints a result, which is all of them except `run`, takes `--json`. The result
is then printed as a single JSON value on the standard output instead of as text, so that scripts
and AI coding agents never have to parse prose:

```shell
$ flame snapshot --output snapshot.png --json
{
  "path": "/path/to/my_game/snapshot.png",
  "width": 800,
  "height": 600,
  "pixelRatio": 1.0,
  "bytes": 48213
}
```

When a command that was called with `--json` fails, the error is printed as JSON on the standard
output too, in place of the result, and the command exits with the same exit code as without
`--json`:

```shell
$ flame step --frames 0 --json
{
  "error": {
    "message": "--frames has to be a positive integer.",
    "exitCode": 64,
    "kind": "usage"
  }
}
```

That way the standard output of a command with `--json` always holds exactly one JSON value, and
a script can check the exit code first and then read either the result or the `error` object. The
`kind` is the name of the exit code, see [exit codes](#exit-codes), for example `unavailable` when
no running game was found. Output that is not part of the result, such as the output of
`flutter create` in `flame create`, goes to the standard error.

These are the results of the commands:

- `create`: The `name` of the game, the absolute `path` of its directory and the `template` it was
  created from.
- `reload` and `restart`: Whether the reload succeeded as `ok`, the `message` that `flutter run`
  reported and all the `output` lines that it printed meanwhile. A failed reload is reported in the
  result too, with `ok` set to `false` and the exit code `70`, since the compile errors in the
  `output` are what is needed to fix the code.
- `stop`: The same `ok`, `message` and `output` as `reload`, where `ok` is `false` when
  `flutter run` did not exit in time.
- `status`: The fields that are described in [status](#status). A game that is not running or not
  reachable is reported in the result too, with the exit code `69`.
- `logs`: The `path` of the log and the last `lines` of it. `--follow` cannot be combined with
  `--json`.
- `devtools`: Starts `dart devtools` with `--machine`, so that its output is one JSON object per
  line, such as the `server.started` event with the host and port of the DevTools. This is the only
  command that prints more than one JSON value.
- `snapshot`: The absolute `path` of the image, its `width` and `height` in pixels, the
  `pixelRatio` it was rendered with, which is lower than `--pixel-ratio` when `--max-size` scaled
  it down, and the size of the file in `bytes`. The `width` and `height` are `null` when the image
  that the game returned is not a valid PNG. With `--annotate` it also has the `annotations`, each
  with the `id` and `name` of the component and its `box` as `[x, y, width, height]` in the pixels
  of the image.
- `tree`: The root of the component tree, or `null` when no component matches `--filter`. Every
  node has an `id`, a `name`, the `toString` of the component, its `attributes` and its
  `children`.
- `inspect` and `set`: The details of the component, the same fields as in the text output.
- `pause`, `resume` and `step`: Whether the game is `paused` afterwards. `step` also has the number
  of `frames`, the `frameTime` and `totalTime` in seconds, and whether the game `wasPaused`
  before.
- `debug`: Whether the `debugMode` is on, and the `component` it applies to, or `null` for the
  whole game.
- `overlays`: The names of all the registered `overlays`, and the `active` ones.
- `overlay show`, `hide` and `only`: The `overlay` and whether it is `shown`, and for `only` also
  `othersHidden`.
- `input tap`, `drag` and `key`: The kind of `input` and what was sent, the `position` of a tap,
  the `from` and `to` positions and the `steps` of a drag, and the `key` and `action` of a key
  press. The positions are in canvas coordinates, also when a component was targeted, which is then
  given as `component` for a tap and as `fromComponent` and `toComponent` for a drag, either as
  the number of its id or as the name of its `ComponentKey`.
- `diff`: Whether the images are `identical`, the number of `differingPixels` and `totalPixels`,
  the `percentage` that differs, the `bounds` of the differences with `left`, `top`, `width` and
  `height` or `null` when the images are identical, and the absolute path of the `output` image or
  `null`.

`flame run` passes all its arguments on to `flutter run`, so it has no `--json`. Use the
`--machine` option of `flutter run` for machine readable output of the game itself.


## Exit codes

The commands follow the common Unix conventions for exit codes, so that scripts can tell failures
apart. The exit codes are stable, and with `--json` the name in parentheses is
the `kind` of the error:

- `0` (`success`): The command succeeded.
- `1`: Only from `diff --exit-code`, when the images differ, like `git diff`.
- `64` (`usage`): The command was used incorrectly, for example with an unknown or invalid option,
  or a missing argument.
- `65` (`data`): The game rejected the input, for example because there is no component with the
  given id or no component handles the input, or an input file could not be read or is invalid,
  such as a file that is not a PNG image or a `devtools_options.yaml` that is not valid YAML. It
  is also used when `flame create` would overwrite an existing project.
- `69` (`unavailable`): No running game was found, the game or `flame run` could not be reached,
  the game stopped while the command ran, the game runs a version of Flame that does not support
  the command, or `flutter` or `dart` could not be started.
- `70` (`software`): The game reported an error while running the command, a reload or restart
  failed, `flutter run` did not exit after `stop`, or a `flutter` command that `flame create` runs
  failed.
- `73` (`cantCreate`): The output file could not be written.
- `75` (`tempFail`): The condition of `wait` did not hold before the timeout.

`flame run` and `flame devtools` exit with the exit code of `flutter run` and `dart devtools`
once those have started.


## Compatibility

The commands use the [service extensions](debug.md#service-extensions) that Flame registers for its
DevTools extension. If the game runs an older version of Flame that does not have the service
extension that a command needs, the command says so and exits with `69`, update Flame in that case.
