# flame_flutter3d

**flame_flutter3d** puts a [flutter3d] scene under a Flame game. Flame keeps running the game and
drawing its own layer: components, effects, collisions, input, overlays. flutter3d draws the 3D
layer beneath it, with its own renderer and post-processing chain. Neither engine reimplements the
other, and both run on Flame's clock.

flutter3d draws through Flutter GPU (Impeller) on desktop and mobile, through WebGL2 or WebGPU in a
browser, and through a software rasterizer when there is no GPU at all, which is what the package's
tests use.


## One game, two layers

Mix `HasFlutter3d` into the game and show it with `Flutter3dFlameWidget` instead of `GameWidget`:

```dart
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart';

class MyGame extends FlameGame with HasFlutter3d {
  @override
  void onOpen3d() {
    scene.add(LightNode(name: 'sun'));
    world.add(
      Object3dComponent(
        node: MeshNode(crateMesh, crateMaterial),
        scene: scene,
        plane: BridgePlane.ground(),
      ),
    );
  }
}

// In the widget tree:
Flutter3dFlameWidget(game: MyGame())
```

`Flutter3dFlameWidget` stacks Flame's `GameWidget` over a flutter3d `SceneSurface`. Flame is on top
because it needs raw input, and `HasFlutter3d` gives the game a transparent background so the 3D
layer shows through. The game owns its `scene`, `camera3d`, `device` and `renderer`, and builds the
world in `onOpen3d`, which runs once after the game has loaded.


## One loop

There is no second ticker. A `BridgeClock` component sits in the game and draws the 3D frame after
Flame's components have updated, so a `MoveEffect` that moved a component this frame is drawn in 3D
this frame. `BridgePriority` names the order the bridge's own components run in: input, actors,
physics, your components, Flame's camera, the camera sync, sound, and the clock last.

`HasFixedStep` runs a game's own logic in fixed steps, so the same second of play gives the same
result at 30 and at 120 frames per second. The physics and the actor system step inside those
steps, and bodies are drawn between two steps rather than jumping from one to the next.


## Where a Flame point is in 3D

`BridgePlane` is the one place a Flame `Vector2` and a flutter3d `Vector3` mean the same point.
`BridgePlane.ground()` lays Flame's world flat for a top-down game, where Flame's `y` becomes the
scene's `z`; `BridgePlane.backdrop()` stands it up for a side-scroller. `CurvilinearSpace` bends it
along a road, and `WrapSpace` makes its edges meet.

`Object3dComponent` keeps a Flame `PositionComponent` and a scene node in step, in whichever
direction a `SyncDirection` names. Position, angle, scale, visibility, opacity and a tint cross, and
Flame's effects, hitboxes and children work on it as on any other component. A component that did
not move writes nothing, so a still prop does not trigger a shadow redraw.

Other components cover what a game usually needs next:

- `InstancedObject3dComponent` draws many components of one shape as one draw call.
- `Node3dComponent` is a component in full 3D, moved by `Move3dEffect`, `Rotate3dEffect` and
  `Scale3dEffect`.
- `SpriteBillboardComponent` stands a Flame `Sprite` or `SpriteAnimation` in the scene facing the
  camera.
- `RigidBodyComponent`, `ActorComponent` and `CharacterBodyComponent` carry a flutter3d body or
  actor across, and `CollisionBridge` reports its contacts through Flame's own
  `CollisionCallbacks`.
- `Object3dComponent.follows` takes any Flame position provider, so a `flame_forge2d` body can be
  drawn in 3D.
- `TiledWorld3d` stands a Tiled map, the one `flame_tiled` reads, up in 3D.
- `ChaseCamera` and `CameraSyncController` move the 3D camera; given an `eyeOffset`, Flame's own
  camera (`follow`, `setBounds`, zoom) drives a perspective one.
- `ProjectedViewfinder` and `Tap3dCallbacks` make Flame's taps land on what the player sees under a
  perspective camera.


## Post-processing

The 3D layer renders in HDR and goes through a post-processing chain before it is composited under
Flame. `HasFlutter3d.renderSettings` is read before every frame, so a game turns effects on and off
by returning different settings:

```dart
class MyGame extends FlameGame with HasFlutter3d {
  bool cinematic = false;

  @override
  RenderSettings renderSettings() => RenderSettings(
    fog: fog3d,
    tonemapCurve: TonemapCurve.agx,
    bloom: const BloomSettings(intensity: 0.08),
    ambientOcclusion: const AmbientOcclusionSettings(
      enabled: true,
      method: AmbientOcclusionMethod.gtao,
    ),
    antiAlias: const AntiAliasSettings(
      enabled: true,
      temporal: TemporalSettings(enabled: true),
    ),
    depthOfField: DepthOfFieldSettings(enabled: cinematic),
  );
}
```

What is available: tone mapping (Neutral, ACES, AgX, Reinhard), exposure and auto exposure, local
exposure, bloom, SSAO and GTAO, screen-space reflections, contact shadows, light shafts, volumetric
fog, depth of field, motion blur, temporal anti-aliasing, color grading through a LUT, and spatial
upscaling. Each setting is documented in the [flutter3d API reference].


## Running on the web

A web build draws through WebGL2. To try WebGPU first and fall back to WebGL2 where the browser has
no adapter, build with:

```shell
flutter build web --dart-define=FLUTTER3D_WEBGPU=true
```

The flag is off by default because it adds the WebGPU backend to the bundle, which costs about
368 KiB of JavaScript.

On desktop and mobile, Flutter GPU has to be enabled for the platform, or the 3D layer draws
nothing: `FLTEnableFlutterGPU` and `FLTEnableImpeller` in `Info.plist` on macOS and iOS, and
`io.flutter.embedding.android.EnableFlutterGPU` in `AndroidManifest.xml` on Android.


## Examples

- [The package example](https://github.com/flame-engine/flame/tree/main/packages/flame_flutter3d/example):
  a Flame HUD over a 3D yard, a cube Flame steers, and a crate whose landing Flame hears.
- The `flame_flutter3d` stories in the [Flame examples](https://examples.flame-engine.org):
  post-processing, the shared loop, and a Tiled map in 3D.
- [River Sortie](https://github.com/flame-engine/flame/tree/main/examples/games/river_sortie): a
  small River Raid-style game built on the bridge.

[flutter3d]: https://pub.dev/packages/flutter3d
[flutter3d API reference]: https://flutter3d.pleion.dev/docs
