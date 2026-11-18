# Particles

`ParticleSystem3D` (from `package:flame_3d/particles.dart`) is a particle system for the 3D world:
it spawns particles, simulates them on the CPU and draws all of them with one instanced draw, depth
tested against the rest of the scene. Sparks, coins, smoke and dust pass behind and in front of
models as they should, in a `FlameGame3D` as in a `Scene3DComponent` layer of a 2D game.


## A first system

A system draws billboards with a `ParticleMaterial`, or small meshes (see
[Mesh particles](#mesh-particles)). Its emitters say when, where and how particles spawn; the system
says how they move and change over their life:

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
      colors: const [Color(0xFFFFC870)],
    ),
  ],
  gravity: Vector3(0, -9.8, 0),
  ground: ParticleGround3D(restitution: 0.35),
  velocityStretch: 0.05,
  sizeOverLife: ParticleCurve(1, 0.4),
  opacityOverLife: ParticleCurve(1, 0),
);
world.add(sparks);

// Where something hits:
sparks.burst(40, at: hitPoint);
```

All the state lives in struct-of-arrays typed lists allocated with the system, for `capacity`
particles, so simulating and drawing allocate nothing. Particles spawned while the system is full
are dropped, or replace live ones in turn with `overflow: ParticleOverflow.recycle`. The system's
`random` generator is seeded (`seed`), so a system fed the same time steps produces the same
particles.

The curves over a particle's life (`ParticleCurve`, `ColorRamp`), the ranges of per-particle values
(`(min, max)` records) and the bursts (`EmitterBurst`) are the ones of Flame's 2D particles.


## Emitters

A `ParticleEmitter3D` is an immutable description that any number of systems can share:

- when: a continuous `rate` (particles per second), `bursts` at times on its timeline, a
  `duration` and `loop`, and `ratePerDistance`, particles per unit of distance the system travels,
  spread along the way, for trails behind moving objects;
- where: its `shape` and `offset`. The shapes are `PointEmitterShape3D`, `SphereEmitterShape3D`
  (volume or surface, optionally the upper half), `BoxEmitterShape3D`, `DiscEmitterShape3D` (a disc,
  a ring with `innerRadius`, moving up or `radial` along the ground) and `ConeEmitterShape3D` (from
  its apex, or from a base disc). Shapes are described around the local `+y` axis and oriented by
  the system's transform; subclass `EmitterShape3D` for custom ones;
- how: `speed` along the shape's direction, randomized within a cone of `spread`, plus a constant
  `velocity` and a fraction of the system's own velocity (`inheritVelocity`); `lifespan`, `size`
  and `aspect` (height over width), `rotation` and `spin`, `gravityScale`, and the `colors` each
  particle picks from.

Besides the emitters' timelines (paused with `stop`, resumed with `start`), particles can be
spawned on demand:

```dart
// With the spawn rules of the first emitter, or of another one:
smoke.burst(12, at: chimneyTop);
dust.burst(6, at: footPosition, color: groundColor);

// One particle with explicit values:
system.spawn(
  position: Vector3(0, 1, 0),
  velocity: Vector3(0, 2, 0),
  lifespan: 0.8,
  size: 0.1,
  color: const Color(0xFFFFFFFF),
);
```

`density` scales the number of particles the emitters and `burst` spawn, for graphics quality
settings.


## Simulation

Particles live in the world (`ParticleSpace.world`): once spawned they no longer follow the system,
so a moving system leaves a trail. With `ParticleSpace.local` they move, turn and scale with it.
Forces and the ground are in that same space.

Each step, particles are pulled by `gravity` (scaled per particle by the emitter's
`gravityScale`) and `wind`, swirled by `turbulence`, drawn to `attractors`, and slowed by `drag`.
Long frames are simulated in steps of at most `maxStep` seconds.

- `ParticleTurbulence3D` is curl noise: a smooth, divergence-free flow that swirls particles about
  without gathering them in clumps, changing over time at its `speed`.
- `ParticleGround3D` is a plane particles bounce off (`restitution`, `friction`), slide on and come
  to rest on (`slideDrag`, `restSpeed`). `sizeOffset` keeps them above the plane by a fraction of
  their size, `killOnHit` kills them when they hit it (rain), and `settleRotation` turns resting
  particles back to a rotation of zero, so that a coin modelled lying flat comes to rest lying flat.
  Each bounce calls the system's `onGroundHit` with the point and the speed of the hit, after the
  simulation step, so the callback can spawn particles (splashes) or play sounds.
- `ParticleAttractor3D` pulls particles to a `target` (that can move); particles that come within
  its `arrivalRadius` arrive, are removed when `consumeOnArrival`, and are counted to `onArrived`:
  coins flying into a purse.

Over its life, a particle's size follows `sizeOverLife`, its color `colorOverLife` (multiplying its
spawn color) and `opacityOverLife`, its spin `spinOverLife`, and `rotationOverLife` adds to its
rotation. `flipbook` picks the frame of a textured material over the life, at a frame rate or at
random.

`paused` freezes a system (its particles are still drawn), `clear` removes its particles, `reset`
also restarts its timelines, and `prewarm` simulates some seconds at once, so that a fire is already
burning when it appears. `isFinished` tells when every emitter finished its timeline and no particle
is left; with `removeOnFinish` the system then removes itself.


## Billboards

A `ParticleMaterial` draws each particle as a quad built in the vertex shader. Its `billboard`
decides how the quad faces the camera:

- `spherical`: parallel to the screen, upright on screen, turned by the particle's rotation;
- `cylindrical`: upright along the material's `axis`, turning about it only (flames, beams);
- `velocity`: stretched along the particle's velocity as seen on screen, by
  `1 + speed * velocityStretch` (at most `maxStretch`) times its height, the leading edge half a
  size ahead of the particle (sparks, rain, streaks);
- `flat`: in the plane perpendicular to the `axis`, whatever the camera (ripples, shock rings).

Quads stay upright and unmirrored on screen even when the projection mirrors the scene, as the
projections of 2D art often do.

A quad shows its `sprite`, multiplied by the material's `texture`, its `color` and the particle's
color: `ParticleSprite.softCircle` (a disc with a soft edge, `softness`) and
`ParticleSprite.softBlob` (a lumpy puff whose outline and inside vary from particle to particle,
`lumpiness`, for smoke and dust) need no texture; `ParticleSprite.texture` shows the texture alone.
A texture can be a flipbook of `flipbookColumns` by `flipbookRows` frames (`frameCount` of them),
read left to right and top to bottom, with `frameBlending` between frames. Textures hold
premultiplied alpha, as the images Flutter decodes do; give them a `TextureSampler.linear` sampler.

The material's `renderState` decides how particles blend:

- `RenderState.premultipliedAlphaBlend` (the default) and `RenderState.alphaBlend`: blended, depth
  tested, without depth writes; the system sorts its particles back to front;
- `RenderState.additive`: added to what is behind, depth tested, without depth writes and without
  sorting. Added light covers nothing, so in a `Scene3DComponent` glowing particles over an empty
  part of the scene add their color to the 2D art behind the layer;
- an opaque state with an `alphaCutoff`: cut-out particles that write depth.

`ParticleSystem3D.sort` overrides the sorting. The whole system is ordered among the other
translucent draws of the scene by the center of its bounds.

When `World3D.depthPrepassEnabled` is `true`, setting `ParticleMaterial(softDepthFade: 0.12)` fades
billboard alpha smoothly (`smoothstep`) near intersections with opaque walls and floors using the
half-resolution clip-depth prepass, eliminating hard billboard clipping lines.


## Mesh particles

With a `mesh` instead of a material, each particle is a copy of the mesh, scaled by its size and
turned about its spin axis (one of its own chosen at random, or the system's `spinAxis`), drawn with
the materials of the mesh's surfaces: any material drawn instanced, such as `StylizedMaterial`,
`SpatialMaterial` or `UnlitMaterial`. The particle's color is the per-instance color, and the
system's `instanceData` is copied into the per-instance data of every particle (a
`StylizedMaterial` reads a glow, a highlight, a wind strength and a fade from it). The system's
rotation is the base orientation of every particle.

```dart
final coins = ParticleSystem3D(
  capacity: 128,
  mesh: coinMesh, // a coin modelled lying flat in its xz plane
  emitters: [
    ParticleEmitter3D(
      shape: const ConeEmitterShape3D(angle: 0.5),
      speed: (3, 5),
      lifespan: (2.2, 2.8),
      size: (0.1, 0.12),
      rotation: (0, 2 * pi),
      spin: (-16, 16),
    ),
  ],
  gravity: Vector3(0, -9.8, 0),
  ground: ParticleGround3D(restitution: 0.45, settleRotation: true),
);
```

All the particles of a system are one instanced draw per surface of the mesh, so coins tumble
behind buildings and in front of them, lit like the rest of the scene.


## Presets

`ParticlePresets3D` builds ready-made systems: `sparks`, `smoke`, `dustPuff`, `confetti` and
`coinBurst` (the last two mesh particles). Each has one emitter that spawns nothing on its own
unless given a `rate`; `burst` releases particles where the effect happens. Sizes and speeds are in
meters for a `scale` of 1, and `up` is the scene's up direction:

```dart
// A scene measured in cells, with z up.
final coins = ParticlePresets3D.coinBurst(up: Vector3(0, 0, 1), scale: 0.5);
layer.world.add(coins);
coins.burst(14, at: Vector3(3.5, 4.5, 0.2));
```


## Bounds and statistics

The world-space `aabb` of a system covers its particles and their size, and is kept up to date as
they move. The system is culled with it like any `Object3D`, and it is part of the bounds of the
world, so a `Scene3DComponent` renders the part of the screen its particles cover.

`RenderStats.particles` counts the particles drawn in a frame (in `FlameGame3D.renderStats` and
`Scene3DComponent.renderStats`), besides their draw calls and instances. Particles are drawn into a
shadow map only when their material (or one of their mesh's materials) casts shadows: translucent
and additive billboards are not, and their system skips the shadow pass, sorting nothing.


## 3D ribbons and strokes

`RibbonMaterial3D`, `StrokeBatch3D` and `RibbonTrail3D` draw continuous camera-facing 3D polylines
with shared miter/join tangents in a single instanced GPU draw call (no CPU view-dependent mesh
rebuild when the camera orbits or pans):

- `StrokeBatch3D` collects one or more static or per-frame 3D polylines (`beginStroke` / `addPoint`
  / `endStroke`, or `addPolyline`) for laser beams, trajectory arcs, lightning and spell paths.
- `RibbonTrail3D` samples its own world position (or an explicit `target` component, such as a
  `BoneSocket3D` on a sword tip or a flying projectile) into a pre-allocated ring buffer over
  `lifetime` seconds, tapering width and opacity via `widthOverLife` and `opacityOverLife`.

```dart
final trail = RibbonTrail3D(
  target: projectile,
  lifetime: 0.4,
  width: 0.18,
  color: const Color(0xFF40E0FF),
  material: RibbonMaterial3D(edgeSoftness: 0.35), // additive glow by default
);
world.add(trail);
```


## Drawing instances of your own

The systems record their draws with `RenderContext3D.drawInstances`, which other objects that build
their own instance data can use too: one instanced draw of a surface whose instances are read from
a `Float32List`, 24 floats each, laid out as the per-instance inputs (see
`flame_3d/instancing.glsl`). The material's vertex shader must declare the four `instanceModel`
columns; what they mean is up to it.

The vertex shader of `ParticleMaterial` reads them as: the center and the width
(`instanceModel0`), the velocity and the height (`instanceModel1`), the rotation, the flipbook
frame, a random seed and the stretch (`instanceModel2`), the life progress (`instanceModel3.x`) and
the color (`instanceColor`).


## Limitations

- Soft particles, which fade where they meet geometry, are not supported: the fragment shader
  would need the depth of the scene behind each particle, and Flutter GPU offers no cheap way to
  read it. A texture cannot be sampled in the render pass that uses it as its depth attachment;
  the depth attachment `flame_3d` uses is transient (never stored to memory); and Flutter GPU only
  has combined depth-stencil formats, with no depth-only view to sample: a stored depth-stencil
  texture binds as a sampler without error, but reads zeros on the Vulkan backend of the headless
  tests. Reading the depth would take an extra color attachment written by every opaque material
  and a second render pass that stores and reloads the color and depth, which is not cheap on the
  tile-based GPUs of phones.
- Particles do not collide with meshes, only with their ground plane.
- `ParticleMaterial` is not available on the web yet: it has no WebGPU shaders.
