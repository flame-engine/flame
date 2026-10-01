# flame_flutter3d

A bridge to the [Flame](https://pub.dev/packages/flame) 2D game engine. Flame
runs the game and draws its own layer; flutter3d draws the 3D one under it.
This package keeps the two in agreement on transforms, lifecycle, physics
contacts, input, the camera and the actor system, and neither engine drives
the other's renderer.

```dart
class MyGame extends FlameGame with HasFlutter3d {
  late final JetComponent jet;

  @override
  void onOpen3d() {
    scene.add(LightNode(name: 'sun'));
    jet = JetComponent(node: SceneNode(), scene: scene);
    add(jet);
    add(ChaseCameraComponent(ChaseCamera(
      camera: camera3d,
      target: jet,
      offset: Vector3(0, 10, 10),
      lookOffset: Vector3(0, 0, -8),
    )));
  }
}

// In the widget tree:
Flutter3dFlameWidget(game: myGame)
```


## One clock, two layers

`Flutter3dFlameWidget` puts a flutter3d `SceneSurface` under Flame's own
`GameWidget` in one `Stack`. Flame is on top because it needs raw input.
Neither renderer is reimplemented. A `BridgeClock`, added once to the game,
calls back every frame after Flame's components have updated, and the 3D
frame is drawn from there. A bridged game runs on Flame's clock and no
other.

A game with the `HasFlutter3d` mixin owns its 3D world. Its `scene`,
`device`, `camera3d`, `renderer` and `projector` are fields of the game; it
builds the world in `onOpen3d` and uses the renderer in `onRenderer3d`, each
once, after the game has loaded. The widget then needs only the game. A game
without the mixin passes a `camera` and a `buildScene` instead, as before.

The world lives as long as the game, as Flame's components do: a game shown
again on a tab that comes back draws what it kept. `close3d()` lets the
device go, and `dispose()` calls it. A paused game is not drawn by itself,
and `redraw3d()` draws it once, for a pause menu that changes the sky.


## One plane, everywhere a point crosses

`BridgePlane` is the one place a Flame `Vector2` and a flutter3d `Vector3`
are the same point. `BridgePlane.ground(height:)` is for a top-down game,
where Flame's `y` becomes flutter3d's `z`; `BridgePlane.backdrop(depth:)` is
for a side-scroller, where it stays `y`. Every bridged component takes one.


## What crosses

`Object3dComponent` keeps a Flame `PositionComponent` and a scene node in
one place, in the direction a `SyncDirection` names. Flame's effects reach
the scene in the frame they happen, and a component nested under another
lands where Flame draws it. `elevation` lifts it off the plane; scale,
visibility, `opacity` and a `tint` cross as well, and a component under a
hidden parent is hidden in 3D too. A flipped component turns the way Flame
draws it, nested or not, and `TintEffect` moves the tint as Flame's
`ColorEffect` would a sprite's paint. A component that did not move writes
nothing, so it causes no shadow redraw. `visual` is a node under it that
the game turns and the bridge leaves alone.

For many small things of one shape, `InstancedObject3dComponent` takes a
slot in a shared `InstancedMeshNode`, so a hundred shots are one draw.

`ChaseCamera` follows a bridged component in perspective through
`flutter3d_sim`'s `CameraRig`, which can also shake it.
`CameraSyncController` keeps an orthographic camera and Flame's
`Viewfinder` framed the same; given an `eyeOffset`, it lets Flame's own
camera drive a perspective one, so `follow`, `setBounds` and zoom work as
in a flat game. A split screen is `viewport3d` and `moreViews3d` on the
game, and a `BridgeProjector` for each half.

`BridgeProjector` says where a scene point is drawn, for a score over a
target, and which point of the plane is under a touch. Under a perspective
camera Flame's own tap test misses what the player sees, so a component
with `Tap3dCallbacks` hears a tap on its drawing, and the finger lifting or
held still, and `Taps3dComponent` hands each tap to the one the ray meets
first. An instance of a batch is tapped the same way. `debugHitboxes3d` draws every hitbox in
the scene, round its craft.

`FlameInputBridge` translates Flame's keys, drags, touch stick
(`followJoystick`) and buttons (`bindButton`) into `flutter3d_game`'s
`Bindings` and `InputState`, the objects a native game's input writes.

`RigidBodyComponent` and `ActorComponent` carry a body across.
`PhysicsStepComponent` and `ActorSystemComponent` step the shared world
once, in fixed steps, the game's own when it has `HasFixedStep`, and a
component handed its stepper is drawn between two steps. A body can be
`teleport`ed, and taken out of the world with its component.
`CollisionBridge` re-fires contacts as Flame's
`CollisionCallbacks`, and `ColliderRegistry` says which component a
collider belongs to.

`ChunkStreamer` builds the pieces of a world that come into view and lets
go of those that leave it. `Particles3dComponent` runs a
`flutter3d_particles` pool on Flame's clock, additive for fire and
darkening for smoke.

Beyond the plane, `Node3dComponent` is a Flame component in full 3D, moved
by `Move3dEffect`, `Rotate3dEffect` and `Scale3dEffect` on Flame's own
effect controllers; `SpriteBillboardComponent` stands a Flame `Sprite` or
`SpriteAnimation` in the scene facing the camera, or a line of Flame's
`TextPaint` written into a sprite by `BillboardAtlas.spriteOfText`; and an
`Object3dComponent`
that `follows` a `flame_forge2d` body draws Flame's own physics in 3D.

A level drawn in Tiled is stood up by `TiledWorld3d`, each tile layer a
`CellGridComponent`, drawn as instances and given Flame hitboxes as its
properties say; `GridMover` walks a maze a cell at a time.
`KinematicBodyComponent` is a lift Flame's effects move, carrying whoever
stands on it, and `PlayerInputs` shares one keyboard between players.

For whole genres there is more. `HasFixedStep` runs a game's own logic in
fixed steps, so a second of play comes out the same at any frame rate.
`ProjectedViewfinder` makes Flame's own events and conversions land on the
plane under the finger. `WrapSpace` is a world whose edges meet, with
ghosts drawn and hit across the seam; `CurvilinearSpace` bends Flame's
straight world along a road; `AtmosphereComponent` turns a day;
`CellGridComponent` is a shield worn away where it is hit;
`TrailComponent` draws a line behind a missile; `ModelAnimationComponent`
plays a model's clips; and `CharacterBodyComponent` steps a platformer's
runner.

`BridgePriority` names the order all of this updates in, and the
components take it by default.

Sound is in [`flame_flutter3d_audio`](https://pub.dev/packages/flame_flutter3d_audio),
a package of its own so that a game without sound does not carry SoLoud.


## Post-processing and the web

The 3D layer is drawn in HDR, through flutter3d's post-processing chain:
bloom, SSAO and GTAO, screen-space reflections, depth of field, motion
blur, light shafts, volumetric fog, temporal anti-aliasing, a LUT and
four tone-mapping curves. `HasFlutter3d.renderSettings` is read before
every frame, so a game switches any of it on Flame's clock.

A web build draws through WebGL2; built with
`--dart-define=FLUTTER3D_WEBGPU=true` it tries WebGPU first and falls back
to WebGL2.


## Examples

`example/` is the smallest hybrid game. `examples/games/river_sortie` in
the Flame repository, a River Raid-style game, uses most of this package,
and the `flame_flutter3d` stories in Flame's examples show post-processing,
the shared loop and a Tiled map in 3D. The [documentation] says more.

[documentation]: https://docs.flame-engine.org/latest/bridge_packages/flame_flutter3d/flame_flutter3d.html
