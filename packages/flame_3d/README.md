<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds 3D support for <a href="https://github.com/flame-engine/flame">Flame</a> using the <a href="https://github.com/flutter/flutter/wiki/Flutter-GPU">Flutter GPU</a>.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_3d" ><img src="https://img.shields.io/pub/v/flame_3d.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---

<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->

# flame_3d

This package provides an experimental implementation of 3D support for Flame.
The main focus is to explore the potential capabilities of 3D for Flame while
providing a familiar API to existing Flame developers.

Supported platforms:

| Platform | Supported |
| -------- | --------- |
| Android  | ✅        |
| iOS      | ✅        |
| macOS    | ✅        |
| Windows  | ❌        |
| Linux    | ❌        |
| Web      | ⚠️¹       |

⚠️¹ Web support is experimental, see [Web support](#web-support-experimental)
below.


## Prologue

**STOP**, we know you are hyped up and want to start coding some funky 3D stuff
but we first have to set your expectations and clarify some things. So turn down
your music, put away the coffee and make some tea instead because you have to do
some reading first!

This package provides 3D support for Flame but it depends on the still
experimental [Flutter GPU](https://github.com/flutter/flutter/wiki/Flutter-GPU),
which in turn depends on Impeller.

Therefore, this package is also experimental; you can check our
[Roadmap](https://github.com/flame-engine/flame/blob/main/packages/flame_3d/ROADMAP.md)
for more details on our plans and what is currently supported.

This package does not guarantee that it will follow correct
[semver](https://semver.org/) versioning rules, nor does it assure that its APIs
won't break. Be ready to constantly have to refactor your code if you are
planning on using this package, and potentially to have to contribute with
improvements and fixes. Please do not use this for production environments.

Documentation and tests might be lacking for quite a while because of the
potential constant changes of the API. Where possible, we will try to provide
in-code documentation and code examples to help developers but our main goal for
now is to enable the usage of 3D rendering within a Flame ecosystem.


## Prerequisites

In order to use flame_3d, you will need to ensure a few things. Firstly, the
only platforms that we have explicitly tested so far for support were Android,
iOS, and macOS.

Then, you need to enable Impeller, if not already enabled by default. For
example, for macOS, add the following to the generated `macos/runner/Info.plist`
directory:

```xml
<dict>
  ...
  <key>FLTEnableImpeller</key>
  <true/>
  <key>FLTEnableFlutterGPU</key>
  <true/>
</dict>
```

Alternatively, you can run Flutter with this flag instead:

```bash
flutter run --enable-flutter-gpu
```

Now everything is set up you can start doing some 3D magic! You can check out
the
[example](https://github.com/flame-engine/flame/tree/main/packages/flame_3d/example)
to see how you can set up a simple 3D environment using Flame.

Also check our more advanced examples,
[Collect the Donut](https://github.com/luanpotter/collect_the_donut) and
[Defend the Donut](https://github.com/flame-engine/defend_the_donut).


## Web support (experimental)

Flame 3D also runs on the web, though this is **even more experimental** than
the rest of the package. Flutter GPU does not run in the browser (for now), so
on web `flame_3d` renders through the browser's native
[WebGPU](https://developer.mozilla.org/en-US/docs/Web/API/WebGPU_API) API
instead, via a separate rendering backend. If you want to run on web add the
following before your `runApp` call in `main.dart`:

```dart
await GpuBackend.initialize();
```


## Rendering

`flame_3d` records the draws of every visible `Object3D` while the world is
traversed, then submits them in an order that is cheap for the GPU:

- Opaque draws are grouped by pipeline, material and surface, then roughly
  ordered front to back. Consecutive draws of the same `Surface` with the same
  `Material` instance become a single instanced draw, so components sharing a
  `Mesh` cost one draw call per surface, however many there are.
- Translucent draws come after all opaque ones, back to front; consecutive
  translucent draws of the same `Surface` and `Material` are batched too.

Each component can give its draws a per-instance color (`MeshComponent.color`)
that materials may use; the built-in materials multiply their base color by it.
It can also give them four floats of per-instance data
(`MeshComponent.instanceData`, zero by default) that materials are free to
interpret: `StylizedMaterial` reads an emissive boost, a highlight, a wind
strength and a fade from them. Materials must not change their values between
the draws of one frame to vary objects: they are applied when the draws are
submitted, not when they are recorded. Use the per-instance color and data, or
distinct materials.

A material declares how it is drawn with its `renderState`:

```dart
final glow = UnlitMaterial()..renderState = RenderState.additive;

final glass = UnlitMaterial(albedoColor: const Color(0x80FFFFFF))
  ..renderState = const RenderState(
    blend: BlendState.alpha,
    depthWrite: false,
  );

final floor = SpatialMaterial()
  ..renderState = const RenderState(cullMode: CullMode.backFace);
```

Front faces are counter-clockwise on screen. The winding flips automatically
when the camera mirrors the scene, or when an object's transform mirrors it
(an odd number of negative scales), so back-face culling stays right.

A surface can be built straight from typed arrays, with its own interleaved
vertex layout. Its attributes feed the vertex shader inputs of the same name:

```dart
final surface = Surface.fromBuffers(
  vertices: positionsAndColors, // a Float32List, 7 floats per vertex
  indices: indices, // a Uint16List, or a Uint32List for large surfaces
  layout: VertexLayout(const [
    VertexAttribute('vertexPosition', 3),
    VertexAttribute('vertexColor', 4),
  ]),
  material: myVertexColorMaterial,
);
```

The statistics of the last rendered frame (passes, draw calls, instances,
triangles, pipeline and state changes, uploads, particles, shadow passes and
their draw calls) are available from `FlameGame3D.renderStats`.
`World3D.renderScale` renders the world at a fraction of the device pixels.
The images of the render passes are drawn by Flutter straight from textures
that each render target creates once and takes turns rendering into.


## Materials and lighting

`flame_3d` ships four materials:

- `SpatialMaterial`, physically based (metallic and roughness);
- `UnlitMaterial`, without lighting;
- `ShadowCatcherMaterial`, for invisible surfaces that show only the shadows
  falling on them (see [Shadows](#shadows));
- `StylizedMaterial`, for stylized, vertex-colored art without textures: its
  vertices carry a color, a baked ambient occlusion and masks for the
  per-instance tint, an accent color, emission, gloss and wind sway. It is lit
  by a soft hemisphere ambient, suns and point lights, with highlights, a rim
  light and up to two MatCap textures (a sheen above a gloss threshold, and
  one for gems). Objects vary through their per-instance data: a glow boost, a
  highlight, a wind strength (the wind may sway in each object's model space)
  and a fade, for translucent previews. `StylizedMaterial.buildSurface` builds
  surfaces in its vertex layout, and it draws standard surfaces too. It is not
  available on the web yet.

All of them multiply their color by the vertex color and by the per-instance
color (`StylizedMaterial` by the latter only where its tint mask says; the
shadow catcher by the latter only).

Lights are components of the world:

```dart
world.addAll([
  LightComponent.hemisphere(
    skyColor: const Color(0xFF9CC2F0),
    groundColor: const Color(0xFF7A6A50),
  ),
  LightComponent.directional(direction: Vector3(-0.5, -0.8, -0.3)),
  LightComponent.point(position: Vector3(0, 2, 0), intensity: 2, range: 5),
]);
```

`AmbientLight`, `HemisphereLight`, up to four `DirectionalLight`s (oriented by
an explicit direction or by the component's rotation) and up to eight
`PointLight`s (with an inverse-square falloff, or fading out at a `range`) are
supported. Textures have sampler options (`TextureSampler`: nearest or linear
filtering, clamp, repeat or mirror wrapping), optional mipmaps, and
`ImageTexture.create` shares an image's GPU memory where it can.

See the [Materials and Lighting][materials-docs] documentation for the
details.

[materials-docs]: https://docs.flame-engine.org/latest/bridge_packages/flame_3d/materials.html


## Particles

`ParticleSystem3D` (`package:flame_3d/particles.dart`) spawns particles from
emitters (rates, bursts and trails; point, sphere, box, disc or ring, and cone
shapes), simulates them on the CPU without allocating (gravity, drag, wind,
curl-noise turbulence, attractors, a ground they bounce off with a callback for
each hit; size, color, opacity, spin and rotation over their life) and draws
all of them with one instanced draw, depth tested against the scene:

```dart
final sparks = ParticleSystem3D(
  capacity: 512,
  material: ParticleMaterial(
    billboard: ParticleBillboard.velocity,
    renderState: RenderState.additive,
  ),
  emitters: [
    ParticleEmitter3D(
      shape: const ConeEmitterShape3D(angle: 0.6),
      speed: (3, 6),
      lifespan: (0.4, 0.8),
      size: (0.04, 0.06),
    ),
  ],
  gravity: Vector3(0, -9.8, 0),
  ground: ParticleGround3D(),
  velocityStretch: 0.05,
  opacityOverLife: ParticleCurve(1, 0),
);
world.add(sparks);
sparks.burst(40, at: hitPoint);
```

`ParticleMaterial` draws camera-facing quads (spherical, cylindrical, stretched
along the velocity, or flat), with a soft circle or a soft blob computed in the
shader or a texture with flipbook frames, blended additively, with alpha or
premultiplied alpha (sorted back to front). With a `mesh` instead, particles are
small meshes (coins, debris, confetti) drawn with any instanced material.
`ParticlePresets3D` builds sparks, smoke, dust puffs, confetti and coin bursts.
When `World3D.depthPrepassEnabled` is active, `ParticleMaterial.softDepthFade`
fades billboards smoothly against opaque geometry.
See the [Particles][particles-docs] documentation.

[particles-docs]: https://docs.flame-engine.org/latest/bridge_packages/flame_3d/particles.html


## Shadows

A directional light casts real-time shadows when it is given `ShadowSettings`:

```dart
world.addAll([
  LightComponent.hemisphere(skyColor: const Color(0xFF9CC2F0)),
  LightComponent.directional(
    direction: Vector3(-0.4, -1, -0.3),
    shadows: ShadowSettings(
      strength: 0.85,
      color: const Color(0xFF2E3A66), // tinted rather than black shadows
    ),
  ),
  ...buildings,
]);
```

Before the main pass, the objects that cast shadows are rendered from the
light into a shadow map (1024 by 1024 texels by default), fitted to what the
camera sees and aligned with its texels so that shadows do not shimmer as the
camera moves; skinned and instanced draws cast as they are drawn. Opaque
materials cast shadows and translucent ones do not, unless their
`castsShadows` says otherwise, and `Object3D.castsShadows` turns them off per
object. `StylizedMaterial` receives shadows with soft edges: they take away the
light's own light, by their `strength` and `color`, and ambient light stays.
`ShadowCatcherMaterial` on an invisible ground lets a `Scene3DComponent` cast
shadows onto the 2D art below it.

The shadow pass costs one more render pass per cascade, with one draw call per
caster surface (`ShadowSettings(cascades: 2)` packs near and far cascades into
one shadow atlas, and `SpotLight(shadows: ...)` casts perspective cone
shadows). Both `StylizedMaterial` and `SpatialMaterial` receive PCF shadows on
native backends; `UnlitMaterial` and web do not receive shadows yet. See the
[Shadows](https://docs.flame-engine.org/latest/bridge_packages/flame_3d/shadows.html)
documentation for the details.


## Embedding 3D in a 2D game

A `Scene3DComponent` shows a 3D scene as one layer of an ordinary 2D Flame
game, at its priority among the 2D components, seen through the 2D camera. A
`Scene3DProjection` maps the scene to the component's local coordinates, for
example as the parallel projection of isometric 2D art, and the layer lines up
with the 2D art pixel for pixel at every zoom and pan:

```dart
final layer = Scene3DComponent(
  projection: Scene3DProjection.affine(
    xAxis: Vector2(44, 22), // where the scene's unit vectors land in 2D
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -54),
    towardsViewer: Vector3(1, 1, 1),
    near: -50,
    far: 50,
  ),
  priority: 1,
);
world.add(layer);
layer.world.add(MeshComponent(mesh: house, position: Vector3(3, 4, 0)));

// A 2D label above the house, and a tap turned into a 3D ray.
layer.add(TextComponent(text: 'Inn')
  ..position = layer.scenePointToLocal(Vector3(3, 4, 1.5)));
// tapInWorld: camera.globalToLocal(event.canvasPosition)
final ray = layer.localPointToRay(layer.absoluteToLocal(tapInWorld));
```

Each frame the layer renders only the part of the screen its scene covers, at
the device's resolution, in one render pass; the bounds of the scene are kept up
to date as its objects move, and render targets and their textures are reused
from frame to frame. See the
[documentation](https://docs.flame-engine.org/latest/bridge_packages/flame_3d/embedding.html)
and the `houses` scenario of the example.


## Building shaders

If you are using the materials provided by `flame_3d`, you do not need to worry
about shaders.

That being said, you can write your own shaders and use them on custom
materials. Currently, Flutter does not do the bundling of shaders for us so this
package provides a simple Dart script. Create your fragment and vertex shader in
a `shaders` directory, make sure the file names are identical. Like so:

- `my_custom_shader`.frag
- `my_custom_shader`.vert

You can then run `dart pub run flame_3d:build_shaders` to bundle the shaders.
They will automatically be placed in `assets/shaders`.

For [web support](#web-support-experimental), also pass `--with-web-gpu` to
build the WebGPU shader bundles. That step needs the `naga` CLI on your `PATH`
(`cargo install naga-cli`).

Shaders can also reuse shared GLSL through `#include`. An
`#include <package_name/file.glsl>` resolves against the `shaders/` directory of
any package in your dependency graph, so chunks can be shared across packages.
Including ones that `flame_3d` itself ships:

- `#include <flame_3d/instancing.glsl>` declares the per-instance inputs
  (`instanceModel0` to `instanceModel3`, the model matrix columns,
  `instanceColor` and `instanceData`) and `instanceModelMatrix()`. A vertex
  shader that declares the model columns is drawn instanced; one that does not
  gets its model matrix from uniforms set by its material, one draw per
  object.
- `#include <flame_3d/camera.glsl>` declares the `CameraMatrices` block
  (`view`, `projection`, `viewProjection`), filled once per render pass.
- `#include <flame_3d/skinning.glsl>` for vertex skinning; the joint matrices of
  skinned draws are filled by `flame_3d`.
- `#include <flame_3d/lights.glsl>` declares the light blocks (`AmbientLight`,
  `Lights`, `DirectionalLights` and `HemisphereLight`).
- `#include <flame_3d/shadows.glsl>` declares the `Shadows` block and the
  `shadowMap` sampler, and `shadowVisibility()` to receive shadows.

Uniform blocks named `CameraMatrices`, `Camera`, `AmbientLight`, `Lights`,
`DirectionalLights`, `HemisphereLight` and `Shadows`, and the `shadowMap`
sampler, are filled by `flame_3d` once per render pass, and your own blocks
and textures can be added with `RenderContext3D.registerPassUniform` and
`RenderContext3D.registerPassTexture`. A shader must use every vertex input
it declares, or `impellerc` rejects it; surfaces must provide every input the
shader declares, except the per-instance ones.

You can check out the
[default shaders](https://github.com/flame-engine/flame/tree/main/packages/flame_3d/shaders)
if you want to have some examples.


## Contributing

Have you found a bug or have a suggestion of how to enhance the 3D APIs? Open an
issue and we will take a look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just make sure to
create it from the correct branch (main) and follow the
[checklist](.github/pull_request_template.md) which will appear when you open
the PR.

For bigger changes, or if in doubt, make sure to talk about your contribution to
the team. Either via an issue, GitHub discussion, or reach out to the team using
the [Discord server](https://discord.gg/pxrBmy4).
