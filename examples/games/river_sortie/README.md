# River Sortie

A jet up a river that never ends, in 3D. A homage to River Raid, which
Carol Shaw wrote for the Atari 2600 in 1982, and a Flame game from end to
end: Flame runs it, and [`flame_flutter3d`](../../../packages/flame_flutter3d)
draws it in 3D.

```shell
# WebGL2
flutter run -d chrome
# WebGPU, or WebGL2 if the browser has none
flutter run -d chrome --dart-define=FLUTTER3D_WEBGPU=true
# Start on a later level
flutter run -d chrome --dart-define=RIVER_LEVEL=3
# Draw every hitbox round its craft
flutter run -d chrome --dart-define=RIVER_HITBOXES=true
```

A web build draws through WebGL2 unless it is built with
`FLUTTER3D_WEBGPU=true`. Then it asks the browser for a WebGPU adapter first
and falls back to WebGL2 when there is none. The flag is off by default
because it puts the WebGPU backend into the bundle, about 1.3 MB more of
`main.dart.js` for this game.

Only the web platform folder is kept here. `flutter create --platforms=macos .`
adds another; on macOS, iOS and Android the game draws through Flutter GPU,
which has to be switched on for the platform (see the `flame_flutter3d`
example's `pubspec.yaml`).

Arrows or WASD steer; up and down open and close the throttle. Space fires.
On a phone, Flame's own stick and a fire button do the same.


## The game

The river winds, narrows and splits round islands. Tankers and helicopters
wait on it, jets cut across it, and the tank runs dry unless the jet flies
low over a fuel depot. A bridge ends every stretch and has to be shot down
to pass; lose a jet and the next starts past the last bridge brought down.
A tanker is 30 points, a helicopter 60, a depot 80, a jet 100 and a bridge
500, and every ten thousand points is another jet in reserve.

The river is the same every run, because a seeded generator lays it out a
stretch at a time (`lib/src/course.dart`), the way the cartridge's river was
the same every time it was switched on.


## Levels and tasks

Five levels, then an open river that goes on for ever
(`lib/src/levels.dart`). Each level is a few bridges long, has its own mix
of targets, speeds and islands, and gives the pilot a task:

| Level       | Bridges | Task                                               |
|-------------|---------|----------------------------------------------------|
| Shakedown   | 2       | Bring down both bridges                            |
| Supply Line | 3       | Sink six tankers                                   |
| Rotor Alley | 3       | Down five helicopters; some fire back              |
| Jet Stream  | 3       | Shoot down three jets                              |
| Long Haul   | 4       | Eight tankers and four helicopters, on little fuel |

The last bridge of a level is shielded until its task is done. Glowing
rails show it; a shot throws sparks and the panel says what is still
wanted. Bringing it down pays the level's bonus.


## Flame runs it, flutter3d draws it

`lib/src/river_game.dart` is an ordinary Flame game. Every moving thing is a
Flame component on a flat map of the river; Flame's collision detection
decides what hit what, `onCollisionStart` says so, and Flame paints the
instrument panel. Each of those components is an `Object3dComponent`, which
writes its Flame position into a scene node every frame, and
`Flutter3dFlameWidget` puts the 3D layer under Flame's and runs both from
Flame's clock.

The one thing not done with hitboxes is the banks: the river's edge is a
curve the course can answer for any point, so the jet asks whether it is
over water.

`lib/river_sortie.dart` is the game as a library: `RiverScreen` is the game
on a screen of its own, for an app that has other screens, and `RiverApp`
is what `lib/main.dart` runs.


## Sound

This copy is silent. The game still decides what to say and where: an
engine that climbs with the throttle, a shot, a hit, a depot filling the
tank, a low-fuel alarm, a finished level. It says it into
`flutter3d_audio_core`'s silent backend, and the sound test listens to that.
A real backend is `flutter3d_audio`'s SoLoud one, which needs a newer
Flutter than Flame supports, so it stays out of Flame's examples. The
original River Sortie in the [flutter3d repository] plays all of it.

The two Flame components that connect the sound to the game are in
`lib/src/audio/`. They are published as `flame_flutter3d_audio`, but its
releases are built against Flame 1.x, so the game carries its own copy.

[flutter3d repository]: https://github.com/pleiondev/flutter3d/tree/v0.8.4/apps/flutter3d_demo_river


## Models

The jets, the helicopter and the tankers are free models, unchanged; who
made each and under what licence is in `assets/models/LICENSES.md`.

- `jet_player.glb` and `jet_enemy.glb`: "Jet" by Poly by Google, from
  [Poly Pizza](https://poly.pizza), under
  [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
- `helicopter.glb`: "Helicopter" by kazuma, from Poly Pizza, under CC0 1.0.
- `tanker_a.glb`, `tanker_b.glb` and `Textures/colormap.png`: from Kenney's
  [Watercraft Kit](https://kenney.nl/assets/watercraft-kit), under CC0 1.0.

The valley, trees, houses, bridges, depots and effects are built in code
(`lib/src/models.dart`), which also draws primitive stand-ins until the
model files have loaded.


## Tests

The tests cover the course, the rules, the campaign, the sound, a frame
drawn on the CPU backend, and the game itself: the real `FlameGame`, loaded
and stepped the way Flame's own test harness does it, with every hit found
by Flame's collision detection.
