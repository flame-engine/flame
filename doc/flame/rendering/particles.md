# Particles

Flame ships a data-oriented particle system built for large particle counts:
all particle state lives in preallocated typed-data buffers, and the built-in
renderers draw every particle of an emitter in a single batched canvas call.
Effects are described declaratively through reusable presets, so most
particle effects require no custom classes and no per-frame allocation.

The system consists of three parts:

- [`ParticleEmitter`](#particleemitter): a declarative, reusable description
  of what to spawn and how particles behave over their lifetime.
- [`ParticleRenderer`](#renderers): how particles are drawn (batched circles,
  sprites, or fully custom canvas code).
- [`ParticleEmitterComponent`](#particleemittercomponent): the
  `PositionComponent` that ties the two together, simulating and rendering
  the particles.

A minimal explosion looks like this:

```dart
import 'package:flame/particles.dart';

world.add(
  ParticleEmitterComponent(
    position: Vector2(200, 100),
    emitter: ParticleEmitter(
      bursts: [EmitterBurst(0, 200)],
      lifespan: (0.4, 1.2),
      speed: (50, 150),
      gravity: Vector2(0, 200),
      scaleOverLife: ParticleCurve(1, 0),
      colorOverLife: ColorRamp([Colors.yellow, Colors.red]),
    ),
    renderer: CircleParticleRenderer(),
  ),
);
```

The component removes itself automatically once the burst has fired and the
last particle has died (see [Lifecycle](#lifecycle)).


## Ranges

Emitter properties that vary from particle to particle are expressed as a
`(min, max)` record called `ParticleRange`; each particle samples a uniform
value from it when it spawns. Use the same value twice for a constant:

```dart
lifespan: (0.5, 2),  // between 0.5 and 2 seconds
size: (8, 8),        // always exactly 8
```


## ParticleEmitter

`ParticleEmitter` is a reusable preset that can be shared by any number of
emitter components. All distances are in the component's local units, angles
in radians, and times in seconds.


### Emission

Particles can be spawned continuously, in bursts, or both:

```dart
ParticleEmitter(
  rate: 120,                     // particles per second
  bursts: [
    EmitterBurst(0, 50),         // 50 particles at t = 0
    EmitterBurst(0.5, 25),       // 25 more at t = 0.5s
  ],
  duration: 1.5,                 // stop emitting after 1.5s
  loop: true,                    // and restart the timeline
  maxParticles: 2048,            // storage for simultaneous particles
);
```

- `rate` emits continuously; fractional amounts accumulate correctly across
  frames.
- `bursts` fire once per pass over the emission timeline.
- `duration` ends emission; when null, a `rate`-based emitter runs forever
  and a burst-only emitter finishes after its last burst.
- `loop` restarts the timeline after `duration` (which must then be set).
- `maxParticles` is allocated up front; spawns beyond it are dropped until
  older particles die.


### Spawn position and velocity

`shape` controls where particles appear, relative to the component's
position:

```dart
shape: const PointEmitterShape(),                    // the default
shape: const CircleEmitterShape(50),                 // inside a circle
shape: const CircleEmitterShape(50, edgeOnly: true), // on its edge
shape: const RectangleEmitterShape(100, 20),         // inside a rectangle
```

Custom spawn patterns are one subclass away: extend `EmitterShape` and
implement `samplePosition`.

The initial velocity is polar: a `speed` range plus a `direction` (radians,
0 points along the positive x-axis, `-tau / 4` points up) with a `spread`
angle centered on it. The default spread of `tau` emits in all directions.

```dart
speed: (100, 200),
direction: -tau / 4,   // up
spread: tau / 8,       // in a 45 degree cone
```


### Forces and rotation

```dart
gravity: Vector2(0, 300),  // constant acceleration
drag: 2,                   // velocity damping, 0 = none
rotation: (0, tau),        // initial rotation
spin: (-5, 5),             // radians per second
rotateToVelocity: true,    // or: always face the direction of travel
```

`rotateToVelocity` suits directional particles such as sparks or arrows;
it overrides `rotation` and `spin`.


### Behavior over a particle's lifetime

Three optional properties change a particle as its life progresses from
0 (spawn) to 1 (death). They are baked into lookup tables when the emitter
is created, so evaluating them per particle per frame is just an array read,
no matter how complex the curve.

`scaleOverLife` multiplies the spawn `size`:

```dart
size: (10, 20),
scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),  // shrink away
```

`ParticleCurve` interpolates between two values, optionally shaped by any
Flutter animation `Curve`. `ParticleCurve.constant` holds a value and
`ParticleCurve.custom` bakes an arbitrary function:

```dart
opacityOverLife: ParticleCurve.custom(
  // Fade in during the first 20% of life, out during the rest.
  (t) => t < 0.2 ? t / 0.2 : (1 - t) / 0.8,
),
```

`colorOverLife` is a `ColorRamp`: a list of colors (optionally with stops)
interpolated over the lifetime. `opacityOverLife` multiplies the ramp's
alpha, so they compose naturally:

```dart
colorOverLife: ColorRamp([Colors.white, Colors.orange, Colors.red]),
opacityOverLife: ParticleCurve(1, 0),
```

With the texture renderers the color tints the texture, so a white texture
takes on the ramp color exactly and sprites stay untinted while the ramp is
unset.


## Renderers

Renderers describe how particles are drawn and can also be shared between
components.


### CircleParticleRenderer

Draws every particle as a circle. The circle is rasterized to a texture once
at load; after that each particle is a transformed, tinted copy of it,
drawn in one `drawRawAtlas` batch. `softness` fades the circle from crisp
(0) to fully soft (1), and `blendMode: BlendMode.plus` gives additive glow,
a natural fit for fire and magic:

```dart
renderer: CircleParticleRenderer(softness: 0.8, blendMode: BlendMode.plus),
```


### SpriteParticleRenderer

Draws every particle as a `Sprite` (or a whole image), also fully batched:

```dart
renderer: SpriteParticleRenderer.fromImage(await images.load('spark.png')),
renderer: SpriteParticleRenderer(sprite),  // a region of a sprite sheet
```

Particles are drawn centered, rotated by their rotation, and scaled so the
sprite's width matches the particle's current size.


### Custom rendering

For full control, use `CallbackParticleRenderer` (or extend
`ParticleRenderer`). The callback receives the canvas, already in the
component's local coordinate system, and the `ParticleBuffer` holding all
live particle state as flat typed-data arrays:

```dart
renderer: CallbackParticleRenderer((canvas, particles) {
  for (var i = 0; i < particles.length; i++) {
    canvas.drawCircle(
      Offset(particles.posX[i], particles.posY[i]),
      particles.size[i] / 2,
      paint,
    );
  }
}),
```

Nothing is batched in a callback renderer, so prefer the texture renderers
for large particle counts.


## ParticleEmitterComponent

`ParticleEmitterComponent` is a regular `PositionComponent`: position it,
give it a priority, add it anywhere in the component tree. It exposes
runtime control over the effect:

```dart
final effect = ParticleEmitterComponent(
  emitter: smokePreset,
  renderer: CircleParticleRenderer(softness: 0.9),
  emitting: false,     // start paused
);

effect.start();        // run the emission timeline (restarts if finished)
effect.stop();         // pause emission; live particles keep simulating
effect.emit(30);       // spawn 30 particles right now, timeline-independent
effect.clearParticles();
effect.particleCount;  // live particles
```

Pass a seeded `Random` for deterministic effects (useful in tests and
replays):

```dart
ParticleEmitterComponent(emitter: e, renderer: r, random: Random(42));
```


### Lifecycle

With `removeOnFinish` (the default), the component removes itself once
emission has naturally finished, meaning the timeline completed without
looping, and the last particle has died. Endless emitters are never removed
automatically. This makes one-shot effects fire-and-forget:

```dart
world.add(
  ParticleEmitterComponent(
    position: hitPosition,
    emitter: sparksPreset,   // burst-only preset, shared by all hits
    renderer: sparksRenderer,
  ),
);
```


### Moving emitters and trails

Particles simulate in the component's local space, so moving the component
moves live particles with it. For trails, exhaust, and similar effects set
`worldSpace: true`: already-spawned particles then keep their world
position while the emitter moves on.

```dart
ship.add(
  ParticleEmitterComponent(
    position: exhaustOffset,
    emitter: exhaustPreset,
    renderer: CircleParticleRenderer(softness: 1),
    worldSpace: true,
  ),
);
```

Only translation is compensated: the component and its ancestors should not
be rotated or scaled while `worldSpace` is enabled.


## Performance notes

- All per-particle state is stored in `Float32List`/`Int32List` columns
  (a struct-of-arrays layout); simulation is a tight loop over contiguous
  memory and dead particles are swap-removed in constant time.
- The texture renderers issue a single `Canvas.drawRawAtlas` call per
  component per frame, regardless of particle count.
- Over-life curves and color ramps are baked into lookup tables at emitter
  construction.
- Storage is allocated once, at `maxParticles`; a running effect performs
  no allocations. Reuse a paused component and call `emit()` instead of
  spawning new components when an effect fires very frequently.
