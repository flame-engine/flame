# Flame CLI command reference

Every command except `run` takes `--json`. The commands that talk to the game take `--uri` (`-u`)
for a game that was not started with `flame run`, or that was not the one started last.


## create

`flame create <directory>` creates a new game.

- `--project-name`: The Dart package name, the name of the directory by default.
- `--org`: The organization in reverse domain name notation, `com.example` by default.
- `--description`: The description in the `pubspec.yaml`.
- `--template` (`-t`): `simple`, `basics` (default) or `example`.
- `--platforms`: A comma separated list such as `macos,web`, all platforms by default.
- `--packages`: Additional Flame packages, for example `flame_audio,flame_tiled`.
- `--flame-version`: A version constraint for `flame` instead of the newest version.
- `--overwrite`: Replace the files of an existing game in the directory.

JSON result: `name`, `path` and `template`.


## run

`flame run [flutter run arguments]` runs `flutter run` and writes the VM Service URI, the control
port and the log to `.dart_tool/flame` in the project root. It has no `--json`. Never pass
`--machine` on to `flutter run`: `flame run` controls `flutter run` through its terminal input,
which `--machine` replaces with JSON requests, so `reload`, `restart` and `stop` stop working. Use
the `--json` output of the other commands instead.


## reload and restart

`flame reload` hot reloads and `flame restart` hot restarts a game started with `flame run`, and
wait for the result.

- `--port` (`-p`): The control port of a specific `flame run`.
- `--merge` (`-m`), `reload` only: Also apply changes to constructors and `onLoad` methods to the
  live components, as a three way merge between two shadows with the old code, one with the new
  code and the live game.
- `--keep-runtime`, with `--merge`: Keep the live value when it and the code both changed.

JSON result: `ok`, `message` and the `output` lines of `flutter run`. With `--merge` there is also
a `merge` field with the lists `updated`, `added`, `removed`, `conflicts`, `skipped` and
`warnings`. A failed reload exits with `70` and has the compile errors in `output`.


## stop

`flame stop` stops a game started with `flame run` and waits until `flutter run` has exited. Takes
`--port`. Exits with `69` when no game is running and with `70` when `flutter run` did not exit
within two minutes.


## status

`flame status` exits with `0` only when the game runs and can be reached, and with `69` otherwise.
Takes `--port` and `--uri`.

JSON result: `running`, `projectDirectory`, `controlPort`, `processId`, `vmServiceUri`,
`reachable`, `paused` and an `error` when it is not running or not reachable.


## logs

`flame logs` prints the output of the `flutter run` that `flame run` started.

- `--lines` (`-n`): The number of lines from the end, 100 by default.
- `--follow` (`-f`): Keep printing new output until the game stops. Not combinable with `--json`.

JSON result: the `path` of the log and its last `lines`.


## devtools

`flame devtools` enables the Flame extension in `devtools_options.yaml` and opens the Flutter
DevTools for the game. It keeps serving until stopped with `Ctrl+C`.

- `--no-launch-browser`: Only print the URL.

With `--json` it prints the `dart devtools --machine` events, one JSON object per line.


## snapshot

`flame snapshot` renders the game, through the camera, to a PNG image and prints its absolute path.

- `--output` (`-o`): The file to write, `flame_snapshot.png` by default.
- `--pixel-ratio` (`-p`): Render in a higher resolution, for example `2`.
- `--component` (`-c`): The id of one component to render with its children, without the camera.
- `--world` (`-w`): Render the whole world, also the parts outside of the camera.
- `--rect` (`-r`): Render this part of the world, as `x,y,width,height` in world coordinates.
- `--max-size` (`-m`): The longest side of the image in pixels. The pixel ratio is lowered to fit,
  and the new pixel ratio is printed.
- `--annotate` (`-a`): Outline and label every visible position component with its id and type,
  and print each box as `x,y,width,height` in image pixels.
- `--filter` (`-f`): A case insensitive regular expression on the type, to only annotate the
  matching components. Needs `--annotate`.

JSON result: `path`, `width`, `height`, `pixelRatio`, `bytes`, and with `--annotate` the
`annotations`, each with `id`, `name` and `box` as `[x, y, width, height]`.


## tree

`flame tree` prints the component tree with the id and the non default attributes of every
component.

- `--filter` (`-f`): A case insensitive regular expression on the type. Shows the matches with
  their ancestors and children.
- `--depth` (`-d`): The number of levels below the game to show.

JSON result: the root node, or `null` when nothing matches. Every node has `id`, `name`,
`toString`, `attributes` and `children`.


## inspect

`flame inspect <id>` prints the type, id, parent, number of children, `debugMode`, priority and
`toString` of a component, and for a `PositionComponent` also its position, size, angle, scale and
anchor.


## set

`flame set <id> [options]` changes a component and prints its details afterwards.

- `--position`: As `x,y`.
- `--size`: As `width,height`.
- `--angle`: In radians.
- `--scale`: As `x,y`, or one number for both.
- `--anchor`: A name like `center` or `bottomRight`, or `x,y` between 0 and 1.
- `--priority`: The render priority, the only one that works on any component.


## pause, resume and step

`flame pause` and `flame resume` pause and resume the game loop. `flame step` pauses the game when
it runs and advances it.

- `--frames` (`-n`): The number of frames to advance.
- `--time` (`-t`): The seconds that pass in each frame, a sixtieth of a second by default.

JSON result: `paused`, and for `step` also `frames`, `frameTime`, `totalTime` and `wasPaused`.


## debug

`flame debug [on|off]` shows or changes the debug rendering of hitboxes and bounds. Without an
argument it prints the current state.

- `--component`: Change only this component instead of the whole game.

JSON result: `debugMode` and the `component` it applies to, or `null` for the whole game.


## overlays and overlay

- `flame overlays`: Lists the registered overlays and which ones are shown. JSON result:
  `overlays` and `active`.
- `flame overlay show <name>` and `flame overlay hide <name>`: Show or hide one overlay.
- `flame overlay only <name>`: Show one overlay and hide all the others.


## input

Positions are canvas coordinates. A component is given by its id or by the name of its
`ComponentKey`, has to be a visible `PositionComponent`, and is targeted at its center by default.

- `flame input tap <x,y>` or `flame input tap --component <id or key>`, with `--anchor` for
  another point of the component, as a name like `topLeft` or as `x,y` between 0 and 1.
- `flame input drag <from x,y> <to x,y>`, where either end can be replaced with
  `--from-component` or `--to-component`, with `--from-anchor` and `--to-anchor`. `--steps` is the
  number of update events, 10 by default.
- `flame input key <name>`, where the name is a `LogicalKeyboardKey` constant such as `space`,
  `enter`, `escape`, `arrowLeft`, `a` or `digit1`. `--down` holds the key and `--up` releases it.
  Keys reach games with `HasKeyboardHandlerComponents` or `KeyboardEvents`.

Fails with `65` when no component handles the input or the targeted component is not visible.


## wait

Blocks until a condition holds. Exits with `75` on timeout and `69` when the game stops.

- `flame wait component <type pattern>`: A component whose type matches the case insensitive
  regular expression exists. Use `^Enemy$` to not also match `EnemyBullet`.
  - `--id`: Only this component, the type pattern can then be left out.
  - `--where` (`-w`): A comparison like `"position.x > 100"` on `position.x`, `position.y`,
    `size.x`, `size.y`, `scale.x`, `scale.y`, `angle` or `priority`, with `<`, `<=`, `>`, `>=`,
    `==` or `!=`. Can be repeated, and all of them have to hold.
  - `--count` (`-n`): Exactly this number of components match.
  - `--at-least`: At least this number of components match.
  - `--gone`: No component matches.
- `flame wait overlay <name>`: The overlay is shown, or with `--hidden` hidden.
- `flame wait paused` and `flame wait resumed`: The game loop is paused or running.

Shared options:

- `--timeout` (`-t`): Seconds to wait, 10 by default. `0` checks once.
- `--interval` (`-i`): Seconds between checks, `0.2` by default.


## diff

`flame diff <first.png> <second.png>` compares two images and reports the share of differing
pixels and their bounding rectangle.

- `--output`: Write the differing pixels in red on top of a dimmed second image.
- `--threshold` (`-t`): How much a color channel may differ, from 0 to 255, before a pixel counts.
- `--exit-code`: Exit with `1` when the images differ.

JSON result: `identical`, `differingPixels`, `totalPixels`, `percentage`, `bounds` with `left`,
`top`, `width` and `height` or `null`, and `output`.
