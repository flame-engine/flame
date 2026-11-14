---
name: flame-cli
description: >-
  Use the flame command line tool from package:flame_cli to create Flame games,
  and to run, look at, inspect, control and play a running game. Use it when
  creating a new Flame project, and whenever a change to a Flame game should be
  checked in the running game, for example by taking a snapshot of what it
  shows, reading its component tree, sending taps and key presses, or waiting
  for something to happen in it.
---

# Flame CLI

The `flame` command creates Flame games and talks to a game that runs in debug mode through the
Dart VM Service. It lets you see what the game shows, find and change its components and play it
from the terminal, without opening the DevTools.

Install it once, globally:

```shell
dart pub global activate flame_cli
```

If the pub cache `bin` directory is not on the `PATH`, add `flame_cli` as a development dependency
with `dart pub add dev:flame_cli` instead and replace `flame` with `dart run flame_cli` in all of
the commands below.

Run `flame --help` for the list of commands and `flame help <command>` for the options of one. A
condensed reference of every command and option is in
[references/commands.md](references/commands.md).


## Guidelines

- Always start the game with `flame run` from the project directory, so that the other commands
  find it without a `--uri`. Run every other command from the same project directory or one of its
  subdirectories.
- When running in the background, always redirect the input of `flame run` from `/dev/null` and
  its output to a file, then wait with a bounded number of retries until `flame status` succeeds
  and a component that the game adds in `onLoad` exists, see
  [run the game and wait for it](#run-the-game-and-wait-for-it).
- Always pass `--json` when you are going to read the result of a command programmatically. The
  standard output then holds exactly one JSON value, either the result or an `error` object, with
  two exceptions: `flame devtools --json` prints one JSON event per line, and some failures are
  reported in the normal result instead of an `error` object. A failed `reload` or `restart`, and
  a `stop` that timed out, have `ok: false` and the compile errors or output in `output`. A game
  that is not running or not reachable is reported by `status` with `running` or `reachable`
  set to `false` and the reason in `error`. Always check the exit code first.
- Check the exit code of every command, see [exit codes](#exit-codes). Never guess what happened
  from text output.
- Pause the game with `flame pause` before taking snapshots that are compared or read, and advance
  it with `flame step --frames <n>` so that the result is repeatable.
- Pass `--max-size 1024` to `flame snapshot` when the image is going to be read by an AI model.
- Use `flame snapshot --annotate` to connect what is seen in an image to the component ids, and
  narrow it down with `--filter` in a busy game.
- Component ids are hash codes that change on every restart. Run `flame tree` again after
  `flame restart`, and prefer giving components that you need to target a
  `ComponentKey.named('player')` key, which `flame input` accepts instead of an id.
- Use `flame wait` instead of `sleep` to wait for something to happen in the game.
- After changing code, reload it. When the reload exits with `70`, read the compile errors in its
  output, fix them and reload again.
- A plain `flame reload` does not change components that already exist. For changes to
  constructors, field initializers and `onLoad` methods, run `flame reload --merge` instead of a
  plain reload, never after it, or `flame restart` to start over.
- Overlays are Flutter widgets and are never part of a snapshot. Check them with `flame overlays`
  and `flame wait overlay <name>` instead.
- Always run `flame stop` when you are done, so that no game is left running.


## Create a new game

```shell
flame create my_game
cd my_game
```

`flame create` runs `flutter create`, writes a Flame template on top of it, replaces
`flutter_lints` with `flame_lint` and adds the newest `flame`, and `flame_test` when the template
has tests. Pick the template with `--template`:

- `simple`: An empty `FlameGame` in a `GameWidget`.
- `basics`: The default. A world with a component that reacts to taps, and a test for it.
- `example`: A small complete game with a world, a camera, keyboard and tap input, collisions, a
  score in the viewport and tests, spread over a few files.

Add bridge packages and limit the platforms right away:

```shell
flame create space_shooter --template example --platforms macos,web \
  --packages flame_audio,flame_tiled
```

Pass `--org` with your organization in reverse domain name notation when the game will be
published, since it is used for the bundle and package identifiers.

The `basics` and `example` games pass `flutter analyze` and `flutter test` right after they are
created, so run both after your first change to see that nothing broke.


## Run the game and wait for it

In an interactive terminal, `flame run` works exactly like `flutter run` and takes the same
arguments. From a script or an agent, run it in the background, and wait for it with a limit on
the retries, so that a build error or a crash is reported instead of waiting forever:

```shell
flame run -d macos < /dev/null > run.log 2>&1 &
run_pid=$!
for attempt in $(seq 300); do
  flame status > /dev/null && break
  kill -0 "$run_pid" 2> /dev/null || break
  sleep 1
done
if ! flame wait component Player --timeout 60 > /dev/null; then
  tail -n 50 run.log
  exit 1
fi
```

The first build of a project can take a few minutes, hence the long limit. The loop stops early
when `flame run` has exited, for example because the build failed.

`flame status` exits with `0` as soon as a `FlameGame` has been created and can be reached, which
is before its components have loaded. That is why the script also waits for a component that the
game adds in `onLoad`, here `Player`, before it sends any other command. Replace it with a type
from your game. When the game never got that far, `flame wait` fails, with `69` when no game is
running, and the end of the log shows why. Use `flame logs --lines 50` to read what the game
printed, including exceptions. The log is kept after the game has stopped or crashed.

Pick a desktop device such as `macos`, `linux` or `windows` when you can, since it starts fastest
and does not need an emulator. Use `flutter devices` to see which devices are available.


## See what the game shows

```shell
flame pause
flame snapshot --output snapshot.png --max-size 1024 --json
```

Then read the image at the printed `path`. Other ways to render:

- `--annotate --filter 'player|enemy'`: Draws the outline, id and type of every matching visible
  component, and prints each box in image pixels.
- `--component <id>`: Renders only one component and its children, without the camera.
- `--world`: Renders the whole world instead of what the camera sees, so off screen components are
  visible too.
- `--rect x,y,width,height`: Renders a part of the world, in world coordinates.

Compare two snapshots to find out whether and where something changed:

```shell
flame snapshot --output before.png
flame step --frames 30
flame snapshot --output after.png
flame diff before.png after.png --output diff.png --json
```

`diff` reports the share of differing pixels and their bounding rectangle. Pass `--exit-code` to
make it exit with `1` when the images differ.


## Find and inspect components

```shell
flame tree --filter enemy
flame tree --depth 2 --json
flame inspect 220731871
```

`tree` prints the id, type and attributes of every component, leaving out attributes that have
their default value. `--filter` is a case insensitive regular expression on the type, and the
matches are shown with their ancestors and children.

Change a component in place to try something out without editing code:

```shell
flame set 220731871 --position 150,200 --angle 0.5 --anchor center
flame debug on
```

`flame debug on` turns on the debug rendering of hitboxes and bounds for the whole game, or for one
component with `--component <id>`. Changes made with `set` are lost on restart, so move the values
that work into the code afterwards.


## Change the code and see the result

1. Edit the code.
2. Pick one way to load it:
   - `flame reload --json` when only method bodies like `update` and `render` changed. Those
     changes show up right away.
   - `flame reload --merge --json` when constructors, field initializers or `onLoad` methods
     changed. Run it instead of a plain reload, not after one: the merge compares shadows built
     with the old code to shadows built with the new code, so after a plain reload it finds
     nothing to change.
   - `flame restart --json` to rebuild the game from scratch.
3. When the command exits with `70`, fix the errors from its `output` and run it again.
4. Take a new snapshot, and run `flame tree` again after a restart since the ids have changed.

`flame reload --merge` builds copies of the game, called shadows, with the constructor of the game
class that takes no arguments, and runs their `onLoad` methods. Guard side effects such as playing
music or network calls with `if (!isHotReloadShadow)` in the game. The live components keep the
values that the code did not change. When the code and the running game both changed a value, the
value from the code wins and is reported as a conflict, unless you pass `--keep-runtime`. Values
that differ between two runs of the same code, like random positions, are never written to the
live game.


## Play the game

Positions are canvas coordinates, the same as the pixels of a whole game snapshot at pixel ratio 1.
When `--max-size` lowered the pixel ratio, divide the pixel coordinates by the printed pixel ratio
first.

```shell
flame input tap 400,300
flame input tap --component player
flame input drag --from-component 220731871 600,300 --steps 20
flame input key space
flame input key arrowLeft --down
flame step --frames 60
flame input key arrowLeft --up
```

Tapping a component by id or `ComponentKey` name is more reliable than tapping pixels: the game
converts the point through the camera for you, and the command fails with `65` when the component
is not visible. A failure with `65` that names a missing mixin means that no component handles that
kind of input, for example because the component has no `TapCallbacks`.

Wait for the result instead of sleeping:

```shell
flame resume
flame input tap --component startButton
flame wait overlay GameOver --timeout 20
flame wait component Enemy --at-least 3
flame wait component Player --where "position.x >= 500"
flame wait component --id 220731871 --gone
```

`wait` exits with `75` when the condition did not hold before the timeout. With `--timeout 0` the
condition is checked once, which works as an assertion. A paused game never changes, so resume it
or step it before waiting for something that depends on the game loop.


## Check a change end to end

A repeatable check that a feature works, for example after implementing a jump. Start the game and
wait for it as in [run the game and wait for it](#run-the-game-and-wait-for-it), then:

```shell
flame pause
flame snapshot --output before.png --max-size 1024
flame input key space --down
flame step --frames 20
flame input key space --up
flame snapshot --output after.png --max-size 1024 --annotate --filter player
flame wait component Player --where "position.y < 0" --timeout 0
result=$?
flame stop
exit "$result"
```

The key is held with `--down` while the game is stepped and released with `--up` afterwards. A
plain `flame input key space` presses and releases the key right away, so a game that reads the
pressed keys in `update` would never see it pressed in any of the stepped frames. The exit code of
the assertion is kept while the game is stopped, so a failed check also fails the script.

Look at both images as well as relying on the `wait` assertion, since a component can be at the
right position and still be drawn wrongly. Turn behavior that should keep working into a test with
`flame_test` as described in the `flame-best-practices` skill.


## Debug a problem

- `flame logs --lines 100` or `flame logs --follow`: The output and exceptions of the game.
- `flame debug on` and `flame snapshot`: Hitboxes and bounds, to find collision and size problems.
- `flame tree --filter <type>`: Whether a component was added at all, and where in the tree it is.
  A component that is missing from the tree usually threw in `onLoad`, which is printed in the log.
- `flame snapshot --world`: Whether a component that is not visible is just outside of the camera.
- `flame devtools`: Opens the Flutter DevTools with the Flame tab for a visual component tree.


## Several instances and other ways of starting

A running game belongs to its project, the closest directory with a `pubspec.yaml`, so games from
different projects and checkouts never interfere. When one project runs several times, the
commands go to the instance started last. `flame run` prints the control port and the VM Service
URI of each instance, so address another one with `--uri <vm service uri>` and, for `reload`,
`restart`, `stop` and `status`, with `--port <control port>`.

For a game started from an IDE or with `flutter run`, pass the VM Service URI that `flutter run`
prints with `--uri`, or add `--vmservice-out-file=.dart_tool/flame/vm_service_uri` to the
arguments of `flutter run` so that the commands find it on their own. The `reload`, `restart`,
`stop` and `logs` commands only work with `flame run`.


## Exit codes

| Code | Kind          | Meaning                                                               |
| ---- | ------------- | --------------------------------------------------------------------- |
| `0`  | `success`     | The command succeeded.                                                |
| `1`  |               | Only from `diff --exit-code`, the images differ.                      |
| `64` | `usage`       | Unknown or invalid option, or a missing argument.                     |
| `65` | `data`        | The game rejected the input, like an unknown id or unhandled input.   |
| `69` | `unavailable` | No running game was found or it could not be reached.                 |
| `70` | `software`    | The game reported an error, or a reload, restart or `flutter` failed. |
| `73` | `cantCreate`  | The output file could not be written.                                 |
| `75` | `tempFail`    | The condition of `wait` did not hold before the timeout.              |

With `--json`, a failure is usually printed as `{"error": {"message", "exitCode", "kind"}}` on the
standard output. The exceptions are a failed `reload` or `restart` and a `stop` that timed out,
which print their normal result with `ok: false`, and `status`, which prints its normal result with
the reason in `error` when the game is not running or not reachable. When a command exits with `69`
while the game is starting, retry it a limited number of times, and when it says that the game runs
a Flame version without support for the command, update `flame`.
