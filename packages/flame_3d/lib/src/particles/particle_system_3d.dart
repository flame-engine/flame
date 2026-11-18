import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:meta/meta.dart';

/// The space a [ParticleSystem3D] simulates its particles in.
enum ParticleSpace() {
  /// Particles live in the world: once spawned they no longer follow the
  /// system, so a moving system leaves a trail.
  world,

  /// Particles live in the system's local space and move, turn and scale
  /// with it.
  local,
}

/// Whether a [ParticleSystem3D] sorts its particles before drawing them.
enum ParticleSort() {
  /// Back to front when the material blends in an order dependent way
  /// (alpha or premultiplied alpha blending), otherwise not.
  auto,

  /// Never sorted: the order in which particles are drawn is unspecified.
  none,

  /// Always back to front.
  backToFront,
}

/// What a [ParticleSystem3D] does with particles spawned while it is full.
enum ParticleOverflow() {
  /// They are not spawned.
  drop,

  /// They replace live particles, in turn, so that a burst is never lost.
  recycle,
}

/// {@template particle_system_3d}
/// A particle system: it spawns particles from its [emitters] (and from
/// [burst], [emit] and [spawn]), simulates them on the CPU and draws them,
/// depth tested against the rest of the scene, so that particles pass behind
/// and in front of models.
///
/// ## Look
///
/// A system draws either billboards or meshes:
///
/// - with a [material] (a [ParticleMaterial]), each particle is a quad that
///   faces the camera (spherical, cylindrical, stretched along the velocity,
///   or flat), built in the vertex shader;
/// - with a [mesh], each particle is a copy of the mesh, scaled by its size
///   and tumbling about its spin axis (coins, debris, confetti), drawn with
///   the materials of the mesh's surfaces, any instanced material such as
///   `StylizedMaterial`, `SpatialMaterial` or `UnlitMaterial`.
///
/// Either way all the particles of the system are drawn with one instanced
/// draw (per surface of the mesh), whatever their number.
///
/// ## Simulation
///
/// Particles live in [space] (the world by default). Each step they are
/// pulled by [gravity] (scaled per particle by the emitter's
/// `gravityScale`) and [wind], swirled by [turbulence], drawn to
/// [attractors], slowed by [drag], and bounce off the [ground], which reports
/// each bounce to [onGroundHit]. Over its life, a particle's size follows
/// [sizeOverLife], its color [colorOverLife] and [opacityOverLife], its
/// spin [spinOverLife] and its rotation [rotationOverLife]; [flipbook] picks
/// the flipbook frames of a textured [ParticleMaterial].
///
/// All the state is kept in struct-of-arrays typed lists ([particles])
/// allocated with the system, for [capacity] particles: simulating and
/// drawing allocate nothing. The [random] generator is seeded with `seed`, so
/// that a system fed the same time steps produces the same particles.
///
/// ## Bounds
///
/// The world-space [aabb] of the system covers its particles (and their
/// size), and is kept up to date as they move, for culling and for the
/// bounds of the scene.
///
/// ```dart
/// final sparks = ParticleSystem3D(
///   capacity: 512,
///   material: ParticleMaterial(
///     billboard: ParticleBillboard.velocity,
///     renderState: RenderState.additive,
///   ),
///   emitters: [
///     ParticleEmitter3D(
///       shape: const ConeEmitterShape3D(angle: 0.5),
///       speed: (3, 6),
///       lifespan: (0.4, 0.8),
///       size: (0.04, 0.06),
///       colors: const [Color(0xFFFFC870)],
///     ),
///   ],
///   gravity: Vector3(0, -9.8, 0),
///   ground: ParticleGround3D(),
///   velocityStretch: 0.05,
///   opacityOverLife: ParticleCurve(1, 0),
/// );
/// world.add(sparks);
/// sparks.burst(40, at: Vector3(0, 1, 0));
/// ```
/// {@endtemplate}
class ParticleSystem3D({
  /// The maximum number of particles alive at once. Storage for all of them
  /// is allocated with the system.
  final int capacity = 1024,

  /// The material of billboard particles; exactly one of [material] and
  /// [mesh] must be given.
  final ParticleMaterial? material,

  /// The mesh of mesh particles; exactly one of [material] and [mesh] must be
  /// given.
  final Mesh? mesh,
  List<ParticleEmitter3D> emitters = const [],

  /// The space particles are simulated in.
  final ParticleSpace space = ParticleSpace.world,
  int seed = 0x5EED1234,

  /// Whether the emitters' timelines run. Bursts asked for with [burst],
  /// [emit] and [spawn] happen anyway.
  var bool emitting = true,

  /// Whether the simulation is frozen: nothing moves, ages or spawns until it
  /// is resumed. Paused particles are still drawn.
  var bool paused = false,

  /// Whether the system removes itself from its parent once [isFinished].
  var bool removeOnFinish = false,

  /// What happens to particles spawned while the system is full.
  var ParticleOverflow overflow = ParticleOverflow.drop,

  /// A multiplier of the number of particles the emitters spawn (rates and
  /// bursts), for graphics quality settings.
  var double density = 1,
  Vector3? gravity,

  /// How fast particles slow down, per second: each second their velocity is
  /// divided by about `1 + drag`.
  var double drag = 0,
  Vector3? wind,

  /// A swirling flow pushing the particles around.
  var ParticleTurbulence3D? turbulence,

  /// A plane the particles bounce off.
  var ParticleGround3D? ground,
  List<ParticleAttractor3D> attractors = const [],

  /// The size of a particle over its life, as a multiple of its spawn size.
  var ParticleCurve? sizeOverLife,

  /// The color of a particle over its life, multiplied by its spawn color.
  var ColorRamp? colorOverLife,

  /// The opacity of a particle over its life, multiplying its alpha (clamped
  /// to 0..1).
  var ParticleCurve? opacityOverLife,

  /// The spin of a particle over its life, as a multiple of its spawn spin.
  var ParticleCurve? spinOverLife,

  /// An angle, in radians, added to the rotation of a particle over its
  /// life.
  var ParticleCurve? rotationOverLife,

  /// How much [ParticleBillboard.velocity] billboards stretch with speed:
  /// their height is multiplied by `1 + speed * velocityStretch`, at most
  /// [maxStretch].
  var double velocityStretch = 0,

  /// The maximum stretch of [ParticleBillboard.velocity] billboards.
  var double maxStretch = 4,

  /// How the flipbook frames of a textured [ParticleMaterial] are picked.
  var ParticleFlipbook3D? flipbook,

  /// Whether particles are sorted back to front before they are drawn.
  var ParticleSort sort = ParticleSort.auto,
  Vector3? spinAxis,
  Vector4? instanceData,

  /// Called after a simulation step for each particle that bounced off the
  /// [ground] (or hit it, with [ParticleGround3D.killOnHit]): its position on
  /// the ground and the speed at which it hit. The vector is reused; copy it
  /// to keep it. The callback may spawn particles.
  var void Function(Vector3 position, double speed)? onGroundHit,

  /// The longest simulation step, in seconds: longer frames are simulated in
  /// several steps (at most eight).
  var double maxStep = 1 / 30,
  super.position,
  super.rotation,
  super.scale,
  super.children,
}) extends Object3D {
  /// {@macro particle_system_3d}
  this
    : assert(capacity > 0, 'capacity must be positive'),
      assert(
        (material == null) != (mesh == null),
        'exactly one of material and mesh must be given',
      ),
      assert(attractors.length <= 32, 'at most 32 attractors are supported'),
      assert(maxStep > 0, 'maxStep must be positive');

  /// The emitters particles spawn from; the list can be changed at any time.
  final List<ParticleEmitter3D> emitters = List.of(emitters);

  /// A constant acceleration of every particle (scaled by its gravity scale),
  /// in the simulation space.
  final Vector3 gravity = gravity?.clone() ?? Vector3.zero();

  /// A constant acceleration of every particle (not scaled by its gravity
  /// scale), such as a breeze, in the simulation space.
  final Vector3 wind = wind?.clone() ?? Vector3.zero();

  /// The points particles are drawn to; the list can be changed at any time
  /// (at most 32 attractors).
  final List<ParticleAttractor3D> attractors = List.of(attractors);

  /// The axis mesh particles spin about, in the simulation space; when
  /// `null`, each particle spins about an axis of its own, chosen at random.
  final Vector3? spinAxis = spinAxis?.normalized();

  /// Four floats copied into the per-instance data (`instanceData`) of every
  /// particle, which the material interprets: a `StylizedMaterial` reads a
  /// glow, a highlight, a wind strength and a fade from them.
  final Vector4 instanceData = instanceData?.clone() ?? Vector4.zero();

  /// The random generator every random value of the system comes from.
  final SeededRng3D random = SeededRng3D(seed);

  /// The live particles. Treat them as read-only, unless you know what you
  /// are doing.
  final ParticleBuffer3D particles = ParticleBuffer3D(capacity);

  final CurlNoise3D _curlNoise = CurlNoise3D(seed);
  final Map<ParticleEmitter3D, _EmitterState> _states = Map.identity();

  // The instances of the last draw, VertexLayout.instanceStrideInFloats
  // floats per particle.
  final Float32List _instances = Float32List(
    capacity * VertexLayout.instanceStrideInFloats,
  );

  // Sorting: depth keys, the drawing order and the radix sort's scratch.
  final Uint16List _keys = Uint16List(capacity);
  final Float32List _depths = Float32List(capacity);
  final Int32List _order = Int32List(capacity);
  final Int32List _orderScratch = Int32List(capacity);
  final Int32List _counts = Int32List(256);

  // Ground hits of the last step: x, y, z and speed.
  final Float32List _hits = Float32List(capacity * 4);
  int _hitCount = 0;
  final Int32List _arrivals = Int32List(32);

  // The world origin of the system at the end of the last update, now, and
  // its velocity.
  final Vector3 _lastOrigin = Vector3.zero();
  final Vector3 _origin = Vector3.zero();
  final Vector3 _originVelocity = Vector3.zero();
  bool _hasOrigin = false;
  double _motionStart = 0;
  double _motionEnd = 1;

  // The bounds of the particle centers, in the simulation space.
  double _minX = 0;
  double _minY = 0;
  double _minZ = 0;
  double _maxX = 0;
  double _maxY = 0;
  double _maxZ = 0;
  bool _hasRawBounds = false;
  // Whether the bounds were last published with no particles.
  bool _publishedEmpty = false;
  // The largest width or height of the particles spawned since the system
  // was last empty.
  double _maxExtent = 0;

  final Aabb3 _bounds = Aabb3();
  final Aabb3 _localBounds = Aabb3();
  final Matrix4 _inverse = Matrix4.zero();
  final Vector3 _center = Vector3.zero();

  // Scratch vectors for spawning and callbacks.
  final Vector3 _position = Vector3.zero();
  final Vector3 _direction = Vector3.zero();
  final Vector3 _axis = Vector3.zero();
  final Vector3 _curl = Vector3.zero();
  final Vector3 _hitPosition = Vector3.zero();

  ParticleCurve? _maxCurve;
  double _maxCurveValue = 1;
  double _meshRadius = -1;

  double _time = 0;
  int _recycleCursor = 0;
  bool _everSpawned = false;
  bool _muted = false;

  static final ParticleEmitter3D _defaultEmitter = ParticleEmitter3D();

  /// The number of live particles.
  int get particleCount => particles.length;

  /// The time the system has simulated, in seconds.
  double get time => _time;

  /// Whether every emitter finished its timeline and no particle is alive.
  ///
  /// A system without emitters is finished once particles it spawned all
  /// died. Emitters with an endless rate never finish.
  bool get isFinished {
    if (particles.length > 0) {
      return false;
    }
    if (emitters.isEmpty) {
      return _everSpawned;
    }
    for (var i = 0; i < emitters.length; i++) {
      if (!_stateFor(emitters[i]).completed) {
        return false;
      }
    }
    return true;
  }

  /// The bounds of the particles (including their size) in the simulation
  /// space, or `null` when there are none.
  Aabb3? get particleBounds => particles.length == 0 ? null : _bounds;

  /// Starts (or resumes) the emitters' timelines; the timelines of emitters
  /// that finished start again from the beginning.
  void start() {
    for (var i = 0; i < emitters.length; i++) {
      final state = _stateFor(emitters[i]);
      if (state.completed) {
        state.restart();
      }
    }
    emitting = true;
  }

  /// Stops the emitters' timelines; live particles keep moving.
  void stop() => emitting = false;

  /// Removes every live particle.
  void clear() {
    if (particles.length > 0) {
      GraphicsDevice.notifyVisualMutation();
    }
    particles.clear();
    _hasRawBounds = false;
    _maxExtent = 0;
    _hitCount = 0;
    _publishedEmpty = true;
    markAabbDirty();
  }

  /// Removes every live particle and restarts the emitters' timelines.
  void reset() {
    clear();
    for (final state in _states.values) {
      state.restart();
    }
    _time = 0;
    _hasOrigin = false;
  }

  /// Simulates [seconds] of the system's life at once, in steps of [step]
  /// seconds, as if it had been running already (a fire that is already
  /// burning). Ground hits and arrivals are not reported.
  void prewarm(double seconds, {double step = 1 / 30}) {
    assert(step > 0, 'step must be positive');
    _syncOrigin(0);
    _motionStart = 1;
    _motionEnd = 1;
    _muted = true;
    try {
      var remaining = seconds;
      while (remaining > 1e-9) {
        final h = math.min(step, remaining);
        _advance(h, 0);
        remaining -= h;
      }
    } finally {
      _muted = false;
    }
    _lastOrigin.setFrom(_origin);
    _publishBounds();
    GraphicsDevice.notifyVisualMutation();
  }

  /// Spawns [count] particles (times [density]) at once with the spawn rules
  /// of [emitter] (the first of [emitters] by default), at [at] (in the
  /// simulation space; the system's origin by default), all of [color] when
  /// given. Returns the number of particles spawned.
  int burst(
    int count, {
    Vector3? at,
    ParticleEmitter3D? emitter,
    Color? color,
  }) {
    if (count <= 0 || density <= 0) {
      return 0;
    }
    final source =
        emitter ?? (emitters.isNotEmpty ? emitters.first : _defaultEmitter);
    final scaled = density == 1
        ? count
        : math.max(1, (count * density).round());
    double x;
    double y;
    double z;
    if (at != null) {
      x = at.x;
      y = at.y;
      z = at.z;
    } else if (space == ParticleSpace.world) {
      final m = worldTransformMatrix.storage;
      x = m[12];
      y = m[13];
      z = m[14];
    } else {
      x = 0;
      y = 0;
      z = 0;
    }
    var spawned = 0;
    for (var i = 0; i < scaled; i++) {
      if (!_spawn(source, x, y, z, 0, color)) {
        break;
      }
      spawned++;
    }
    if (spawned > 0) {
      _publishBounds();
      GraphicsDevice.notifyVisualMutation();
    }
    return spawned;
  }

  /// Spawns [count] particles with the spawn rules of the first emitter at
  /// the system's origin, see [burst].
  int emit(int count) => burst(count);

  /// Spawns one particle at [position] (in the simulation space) with the
  /// given values. Returns whether it was spawned.
  bool spawn({
    required Vector3 position,
    Vector3? velocity,
    double lifespan = 1,
    double size = 0.1,
    double aspect = 1,
    Color color = const Color(0xFFFFFFFF),
    double rotation = 0,
    double spin = 0,
    double gravityScale = 1,
    Vector3? axis,
  }) {
    final index = _slot();
    if (index < 0) {
      return false;
    }
    final b = particles;
    b.posX[index] = position.x;
    b.posY[index] = position.y;
    b.posZ[index] = position.z;
    b.velX[index] = velocity?.x ?? 0;
    b.velY[index] = velocity?.y ?? 0;
    b.velZ[index] = velocity?.z ?? 0;
    b.age[index] = 0;
    b.invLifespan[index] = 1 / math.max(lifespan, 1e-4);
    b.width[index] = size;
    b.height[index] = size * aspect;
    b.rotation[index] = rotation;
    b.spin[index] = spin;
    if (axis != null && axis.length2 > 0) {
      final length = axis.length;
      b.axisX[index] = axis.x / length;
      b.axisY[index] = axis.y / length;
      b.axisZ[index] = axis.z / length;
    } else {
      _spinAxisInto(index);
    }
    b.gravityScale[index] = gravityScale;
    b.seed[index] = random.nextDouble();
    b.color[index] = color.toARGB32();
    b.attractorFlags[index] = 0;
    _spawned(index);
    _publishBounds();
    GraphicsDevice.notifyVisualMutation();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused || !(dt > 0)) {
      return;
    }
    final hadParticles = particles.length > 0;
    final frame = math.min(dt, 0.25);
    final steps = math.max(1, math.min(8, (frame / maxStep).ceil()));
    final h = frame / steps;
    _syncOrigin(frame);
    final distance = _origin.distanceTo(_lastOrigin) / steps;
    for (var s = 0; s < steps; s++) {
      _motionStart = s / steps;
      _motionEnd = (s + 1) / steps;
      _advance(h, distance);
    }
    _lastOrigin.setFrom(_origin);
    _publishBounds();
    if (hadParticles || particles.length > 0) {
      // Repaint even when the game only renders frames that change.
      GraphicsDevice.notifyVisualMutation();
      worldOrNull?.markSceneDirty(shadows: castsShadows && mesh != null);
    }
    if (removeOnFinish && isFinished) {
      removeFromParent();
    }
  }

  /// Reads the system's world origin, and its velocity over the last [frame]
  /// seconds.
  void _syncOrigin(double frame) {
    final m = worldTransformMatrix.storage;
    _origin.setValues(m[12], m[13], m[14]);
    if (!_hasOrigin) {
      _lastOrigin.setFrom(_origin);
      _hasOrigin = true;
    }
    if (frame > 0) {
      _originVelocity
        ..setFrom(_origin)
        ..sub(_lastOrigin)
        ..scale(1 / frame);
    } else {
      _originVelocity.setZero();
    }
  }

  /// Simulates one step of [h] seconds, then spawns the particles of the
  /// emitters for that step, the system's origin having traveled
  /// [distance].
  void _advance(double h, double distance) {
    _simulate(h);
    if (emitting) {
      for (var i = 0; i < emitters.length; i++) {
        _emit(emitters[i], h, distance);
      }
    }
    _time += h;
    _dispatchEvents();
  }

  _EmitterState _stateFor(ParticleEmitter3D emitter) {
    final state = _states[emitter];
    if (state != null) {
      return state;
    }
    if (_states.length > emitters.length) {
      _states.removeWhere((key, _) => !emitters.contains(key));
    }
    return _states[emitter] = _EmitterState(emitter.bursts.length);
  }

  void _emit(ParticleEmitter3D emitter, double h, double distance) {
    final state = _stateFor(emitter);
    if (state.completed) {
      return;
    }
    final end = emitter.emissionEndTime;
    final previous = state.clock;
    state.clock += h;
    final density = this.density;
    if (density > 0 && previous < end) {
      final active = math.min(state.clock, end) - previous;
      if (emitter.rate > 0 && active > 0) {
        state.debt += emitter.rate * density * active;
        final count = state.debt.floor();
        state.debt -= count;
        _spawnSpread(emitter, count, h);
      }
      if (emitter.ratePerDistance > 0 && distance > 0) {
        state.distanceDebt += emitter.ratePerDistance * density * distance;
        final count = state.distanceDebt.floor();
        state.distanceDebt -= count;
        _spawnSpread(emitter, count, h);
      }
    }
    final bursts = emitter.bursts;
    for (var i = 0; i < bursts.length; i++) {
      final burst = bursts[i];
      if (!state.fired[i] && state.clock >= burst.time) {
        state.fired[i] = true;
        if (density > 0) {
          final count = density == 1
              ? burst.count
              : math.max(1, (burst.count * density).round());
          final age = math.min(state.clock - burst.time, h);
          final f = _motionEnd - (_motionEnd - _motionStart) * (age / h);
          for (var k = 0; k < count; k++) {
            if (!_spawnAtMotion(emitter, f, age)) {
              break;
            }
          }
        }
      }
    }
    if (state.clock >= end) {
      if (emitter.loop) {
        state.clock %= end;
        state.fired.fillRange(0, state.fired.length, false);
      } else {
        state.completed = true;
      }
    }
  }

  /// Spawns [count] particles born at regular times over the last step of
  /// [h] seconds, along the way the system's origin traveled.
  void _spawnSpread(ParticleEmitter3D emitter, int count, double h) {
    for (var k = 0; k < count; k++) {
      final birth = (k + 0.5) / count;
      final f = _motionStart + (_motionEnd - _motionStart) * birth;
      if (!_spawnAtMotion(emitter, f, h * (1 - birth))) {
        break;
      }
    }
  }

  /// Spawns a particle at the system's origin as it was at [fraction] of the
  /// current frame's motion, aged [age] seconds.
  bool _spawnAtMotion(ParticleEmitter3D emitter, double fraction, double age) {
    if (space == ParticleSpace.local) {
      return _spawn(emitter, 0, 0, 0, age, null);
    }
    final a = _lastOrigin;
    final b = _origin;
    return _spawn(
      emitter,
      a.x + (b.x - a.x) * fraction,
      a.y + (b.y - a.y) * fraction,
      a.z + (b.z - a.z) * fraction,
      age,
      null,
    );
  }

  /// A slot for a new particle, or `-1` when the system is full and drops
  /// particles.
  int _slot() {
    final index = particles.spawn();
    if (index >= 0) {
      return index;
    }
    if (overflow == ParticleOverflow.drop) {
      return -1;
    }
    final slot = _recycleCursor;
    _recycleCursor = (_recycleCursor + 1) % capacity;
    return slot;
  }

  /// Spawns a particle of [emitter] around ([x], [y], [z]) in the simulation
  /// space, aged [age] seconds, of [color] when given.
  bool _spawn(
    ParticleEmitter3D emitter,
    double x,
    double y,
    double z,
    double age,
    Color? color,
  ) {
    final index = _slot();
    if (index < 0) {
      return false;
    }
    final random = this.random;
    final position = _position;
    final direction = _direction;
    emitter.shape.sample(random, position, direction);
    position.add(emitter.offset);
    if (space == ParticleSpace.world) {
      // Oriented, scaled and placed by the system's world transform.
      final m = worldTransformMatrix.storage;
      final px = position.x;
      final py = position.y;
      final pz = position.z;
      position.setValues(
        x + m[0] * px + m[4] * py + m[8] * pz,
        y + m[1] * px + m[5] * py + m[9] * pz,
        z + m[2] * px + m[6] * py + m[10] * pz,
      );
      final dx = direction.x;
      final dy = direction.y;
      final dz = direction.z;
      direction.setValues(
        m[0] * dx + m[4] * dy + m[8] * dz,
        m[1] * dx + m[5] * dy + m[9] * dz,
        m[2] * dx + m[6] * dy + m[10] * dz,
      );
      final length = direction.length;
      if (length > 0) {
        direction.scale(1 / length);
      }
    } else {
      position.setValues(position.x + x, position.y + y, position.z + z);
    }
    if (emitter.spread > 0) {
      EmitterShape3D.randomDirectionInCone(
        random,
        direction,
        emitter.spread,
        direction,
      );
    }
    final speed = emitter.speed.sample(random);
    final inherit = emitter.inheritVelocity;
    final velocity = emitter.velocity;
    var vx = direction.x * speed + velocity.x;
    var vy = direction.y * speed + velocity.y;
    var vz = direction.z * speed + velocity.z;
    if (inherit != 0 && space == ParticleSpace.world) {
      vx += _originVelocity.x * inherit;
      vy += _originVelocity.y * inherit;
      vz += _originVelocity.z * inherit;
    }

    final b = particles;
    b.posX[index] = position.x + vx * age;
    b.posY[index] = position.y + vy * age;
    b.posZ[index] = position.z + vz * age;
    b.velX[index] = vx;
    b.velY[index] = vy;
    b.velZ[index] = vz;
    final lifespan = math.max(emitter.lifespan.sample(random), 1e-4);
    b.invLifespan[index] = 1 / lifespan;
    b.age[index] = math.min(age, lifespan * 0.999);
    final width = emitter.size.sample(random);
    b.width[index] = width;
    b.height[index] = width * emitter.aspect.sample(random);
    b.rotation[index] = emitter.rotation.sample(random);
    b.spin[index] = emitter.spin.sample(random);
    b.gravityScale[index] = emitter.gravityScale.sample(random);
    final colors = emitter.colors;
    b.color[index] =
        (color ??
                (colors.length == 1
                    ? colors[0]
                    : colors[random.nextInt(colors.length)]))
            .toARGB32();
    b.seed[index] = random.nextDouble();
    b.attractorFlags[index] = 0;
    _spinAxisInto(index);
    _spawned(index);
    return true;
  }

  /// Sets the spin axis of the particle at [index]: the system's
  /// [spinAxis], or a random one for mesh particles.
  void _spinAxisInto(int index) {
    final b = particles;
    final fixed = spinAxis;
    if (fixed != null) {
      b.axisX[index] = fixed.x;
      b.axisY[index] = fixed.y;
      b.axisZ[index] = fixed.z;
    } else if (mesh != null) {
      EmitterShape3D.randomDirection(random, _axis);
      b.axisX[index] = _axis.x;
      b.axisY[index] = _axis.y;
      b.axisZ[index] = _axis.z;
    } else {
      b.axisX[index] = 0;
      b.axisY[index] = 1;
      b.axisZ[index] = 0;
    }
  }

  /// Takes the particle just spawned at [index] into account in the bounds.
  void _spawned(int index) {
    final b = particles;
    _everSpawned = true;
    final extent = math.max(b.width[index], b.height[index]);
    if (extent > _maxExtent) {
      _maxExtent = extent;
    }
    _includeInBounds(b.posX[index], b.posY[index], b.posZ[index]);
  }

  void _includeInBounds(double x, double y, double z) {
    if (!_hasRawBounds) {
      _minX = _maxX = x;
      _minY = _maxY = y;
      _minZ = _maxZ = z;
      _hasRawBounds = true;
      return;
    }
    if (x < _minX) {
      _minX = x;
    } else if (x > _maxX) {
      _maxX = x;
    }
    if (y < _minY) {
      _minY = y;
    } else if (y > _maxY) {
      _maxY = y;
    }
    if (z < _minZ) {
      _minZ = z;
    } else if (z > _maxZ) {
      _maxZ = z;
    }
  }

  void _simulate(double h) {
    final b = particles;
    _hitCount = 0;
    final attractorCount = attractors.length;
    for (var a = 0; a < attractorCount; a++) {
      _arrivals[a] = 0;
    }
    _hasRawBounds = false;
    if (b.length == 0) {
      _maxExtent = 0;
      return;
    }

    final gx = gravity.x;
    final gy = gravity.y;
    final gz = gravity.z;
    final wx = wind.x;
    final wy = wind.y;
    final wz = wind.z;
    final damping = drag > 0 ? 1 / (1 + drag * h) : 1.0;

    final turbulence = this.turbulence;
    final hasTurbulence = turbulence != null && turbulence.strength != 0;
    final turbulenceFrequency = turbulence?.frequency ?? 1;
    final turbulenceStrength = turbulence?.strength ?? 0;
    final turbulenceTime = _time * (turbulence?.speed ?? 0);
    final curl = _curl;

    final ground = this.ground;
    final hasGround = ground != null;
    final normal = ground?.normal;
    final nx = normal?.x ?? 0;
    final ny = normal?.y ?? 1;
    final nz = normal?.z ?? 0;
    final groundHeight = ground?.height ?? 0;
    final restitution = ground?.restitution ?? 0;
    final friction = ground?.friction ?? 1;
    final slide = 1 / (1 + (ground?.slideDrag ?? 0) * h);
    final restSpeed = ground?.restSpeed ?? 0;
    final sizeOffset = ground?.sizeOffset ?? 0;
    final killOnHit = ground?.killOnHit ?? false;
    final settle = ground?.settleRotation ?? false;
    final settleFactor = 1 - math.exp(-12 * h);
    final sizeCurve = sizeOverLife;
    final spinCurve = spinOverLife;
    final hits = _hits;
    final reportHits = onGroundHit != null && !_muted;

    var i = 0;
    while (i < b.length) {
      final invLifespan = b.invLifespan[i];
      final age = b.age[i] + h;
      if (age * invLifespan >= 1) {
        b.removeAt(i);
        continue;
      }
      b.age[i] = age;
      final t = age * invLifespan;

      final px0 = b.posX[i];
      final py0 = b.posY[i];
      final pz0 = b.posZ[i];
      final vx0 = b.velX[i];
      final vy0 = b.velY[i];
      final vz0 = b.velZ[i];

      final gs = b.gravityScale[i];
      var ax = gx * gs + wx;
      var ay = gy * gs + wy;
      var az = gz * gs + wz;
      if (hasTurbulence) {
        _curlNoise.sample(
          px0,
          py0,
          pz0,
          turbulenceTime,
          turbulenceFrequency,
          turbulenceStrength,
          curl,
        );
        ax += curl.x;
        ay += curl.y;
        az += curl.z;
      }
      if (attractorCount > 0) {
        var flags = b.attractorFlags[i];
        var consumed = false;
        for (var a = 0; a < attractorCount; a++) {
          final attractor = attractors[a];
          final target = attractor.target;
          final dx = target.x - px0;
          final dy = target.y - py0;
          final dz = target.z - pz0;
          final d2 = dx * dx + dy * dy + dz * dz;
          final radius = attractor.arrivalRadius;
          final bit = 1 << a;
          if (d2 <= radius * radius) {
            if (flags & bit == 0) {
              flags |= bit;
              _arrivals[a]++;
              if (attractor.consumeOnArrival) {
                consumed = true;
                break;
              }
            }
          } else {
            flags &= ~bit;
            if (d2 > 0) {
              final k = attractor.strength / math.sqrt(d2);
              ax += dx * k;
              ay += dy * k;
              az += dz * k;
            }
          }
        }
        if (consumed) {
          b.removeAt(i);
          continue;
        }
        b.attractorFlags[i] = flags;
      }

      var vx = (vx0 + ax * h) * damping;
      var vy = (vy0 + ay * h) * damping;
      var vz = (vz0 + az * h) * damping;
      var px = px0 + vx * h;
      var py = py0 + vy * h;
      var pz = pz0 + vz * h;
      var spin = b.spin[i];
      var resting = false;

      if (hasGround) {
        final level =
            groundHeight +
            (sizeOffset == 0
                ? 0
                : sizeOffset *
                      b.width[i] *
                      (sizeCurve == null ? 1 : sizeCurve.transform(t)));
        final below = px * nx + py * ny + pz * nz - level;
        if (below < 0) {
          // The speed into the ground at the moment of contact, from the
          // state at the start of the step: one step of gravity does not
          // count as an impact for a particle already lying on the ground.
          final above = px0 * nx + py0 * ny + pz0 * nz - level;
          final normalSpeed0 = vx0 * nx + vy0 * ny + vz0 * nz;
          double impact;
          if (above >= 0) {
            final an = ax * nx + ay * ny + az * nz;
            final square = normalSpeed0 * normalSpeed0 - 2 * an * above;
            impact = square > 0 ? math.sqrt(square) : 0;
          } else {
            impact = -(vx * nx + vy * ny + vz * nz);
            if (impact < 0) {
              impact = 0;
            }
          }
          px -= nx * below;
          py -= ny * below;
          pz -= nz * below;
          final normalSpeed = vx * nx + vy * ny + vz * nz;
          var tx = vx - nx * normalSpeed;
          var ty = vy - ny * normalSpeed;
          var tz = vz - nz * normalSpeed;
          if (killOnHit || impact > restSpeed) {
            if (reportHits) {
              final o = _hitCount * 4;
              hits[o] = px;
              hits[o + 1] = py;
              hits[o + 2] = pz;
              hits[o + 3] = impact;
              _hitCount++;
            }
            if (killOnHit) {
              b.removeAt(i);
              continue;
            }
            final bounce = impact * restitution;
            tx *= friction;
            ty *= friction;
            tz *= friction;
            vx = tx + nx * bounce;
            vy = ty + ny * bounce;
            vz = tz + nz * bounce;
          } else {
            vx = tx * slide;
            vy = ty * slide;
            vz = tz * slide;
            spin *= slide;
            resting = true;
          }
        }
      }

      var rotation = b.rotation[i];
      if (resting && settle) {
        const turn = 2 * math.pi;
        final target = (rotation / turn).roundToDouble() * turn;
        rotation += (target - rotation) * settleFactor;
        spin = 0;
      } else if (spin != 0) {
        rotation += spin * (spinCurve == null ? 1 : spinCurve.transform(t)) * h;
      }

      b.posX[i] = px;
      b.posY[i] = py;
      b.posZ[i] = pz;
      b.velX[i] = vx;
      b.velY[i] = vy;
      b.velZ[i] = vz;
      b.rotation[i] = rotation;
      b.spin[i] = spin;
      _includeInBounds(px, py, pz);
      i++;
    }
    if (b.length == 0) {
      _maxExtent = 0;
    }
  }

  void _dispatchEvents() {
    final hitCount = _hitCount;
    _hitCount = 0;
    final onGroundHit = this.onGroundHit;
    if (onGroundHit != null && hitCount > 0 && !_muted) {
      final hits = _hits;
      for (var i = 0; i < hitCount; i++) {
        final o = i * 4;
        _hitPosition.setValues(hits[o], hits[o + 1], hits[o + 2]);
        onGroundHit(_hitPosition, hits[o + 3]);
      }
    }
    for (var a = 0; a < attractors.length; a++) {
      final count = _arrivals[a];
      _arrivals[a] = 0;
      if (count > 0 && !_muted) {
        attractors[a].onArrived?.call(count);
      }
    }
  }

  /// The largest value of [sizeOverLife] (cached), for the bounds.
  double get _sizeCurveMax {
    final curve = sizeOverLife;
    if (curve == null) {
      return 1;
    }
    if (!identical(curve, _maxCurve)) {
      var max = 0.0;
      for (var i = 0; i <= 64; i++) {
        max = math.max(max, curve.transform(i / 64).abs());
      }
      _maxCurve = curve;
      _maxCurveValue = max;
    }
    return _maxCurveValue;
  }

  /// The largest distance of the mesh's vertices from its origin (cached).
  double get _radiusOfMesh {
    if (_meshRadius < 0) {
      final box = mesh!.aabb;
      final x = math.max(box.min.x.abs(), box.max.x.abs());
      final y = math.max(box.min.y.abs(), box.max.y.abs());
      final z = math.max(box.min.z.abs(), box.max.z.abs());
      _meshRadius = math.sqrt(x * x + y * y + z * z);
    }
    return _meshRadius;
  }

  /// The uniform scale of the world transform (the cube root of the volume
  /// it scales by).
  static double _uniformScale(Float32List m) {
    final determinant =
        m[0] * (m[5] * m[10] - m[6] * m[9]) -
        m[4] * (m[1] * m[10] - m[2] * m[9]) +
        m[8] * (m[1] * m[6] - m[2] * m[5]);
    final volume = determinant.abs();
    if (volume == 1) {
      return 1;
    }
    return volume == 0 ? 0 : math.exp(math.log(volume) / 3);
  }

  /// Sets [_bounds] from the particle centers and sizes, and tells the
  /// component tree that the bounds changed.
  void _publishBounds() {
    if (!_hasRawBounds || particles.length == 0) {
      if (!_publishedEmpty) {
        _publishedEmpty = true;
        markAabbDirty();
      }
      return;
    }
    _publishedEmpty = false;
    final scale = space == ParticleSpace.world
        ? _uniformScale(worldTransformMatrix.storage)
        : 1.0;
    final double pad;
    if (mesh != null) {
      pad = _radiusOfMesh * _maxExtent * _sizeCurveMax * scale;
    } else {
      final stretch = velocityStretch > 0 ? math.max(1, maxStretch) : 1;
      // Half the diagonal of the largest quad, stretched.
      pad = 0.71 * _maxExtent * _sizeCurveMax * stretch * scale;
    }
    _bounds.min.setValues(_minX - pad, _minY - pad, _minZ - pad);
    _bounds.max.setValues(_maxX + pad, _maxY + pad, _maxZ + pad);
    markAabbDirty();
  }

  @override
  Aabb3? computeLocalAabb() {
    if (particles.length == 0 || !_hasRawBounds) {
      return null;
    }
    if (space == ParticleSpace.local) {
      return _bounds;
    }
    // The bounds are in world space; the component expects local ones.
    final determinant = _inverse.copyInverse(worldTransformMatrix);
    if (determinant == 0) {
      return null;
    }
    return _localBounds
      ..setFrom(_bounds)
      ..transform(_inverse);
  }

  /// Whether the particles are sorted back to front for the next draw.
  bool get sortsParticles {
    switch (sort) {
      case ParticleSort.none:
        return false;
      case ParticleSort.backToFront:
        return true;
      case ParticleSort.auto:
        final material = this.material;
        if (material != null) {
          return material.needsSorting;
        }
        final mesh = this.mesh!;
        for (var i = 0; i < mesh.surfaceCount; i++) {
          final state = mesh.surfaces.elementAt(i).material.renderState;
          if (ParticleMaterial.blendsInOrder(state)) {
            return true;
          }
        }
        return false;
    }
  }

  @override
  void draw(covariant RenderContext3D context) {
    final count = particles.length;
    if (count == 0 || (context.isShadowPass && !_castsShadows)) {
      return;
    }
    RenderProfile.lap(RenderPhase.recording);
    final sorted = sortsParticles;
    if (sorted) {
      _sortBackToFront(context.view);
    }
    final material = this.material;
    if (material != null) {
      _writeBillboards(sorted, material);
    } else {
      _writeMeshes(sorted);
    }
    final center = _center
      ..setFrom(_bounds.min)
      ..add(_bounds.max)
      ..scale(0.5);
    if (space == ParticleSpace.local) {
      worldTransformMatrix.transform3(center);
    }
    RenderProfile.lap(RenderPhase.particles);
    if (material != null) {
      context.drawInstances(
        _quad,
        material: material,
        instances: _instances,
        count: count,
        center: center,
      );
    } else {
      final mesh = this.mesh!;
      for (var i = 0; i < mesh.surfaceCount; i++) {
        context.drawInstances(
          mesh.surfaces.elementAt(i),
          instances: _instances,
          count: count,
          center: center,
        );
      }
    }
    context.device.stats.particles += count;
  }

  /// Whether the material, or one of the materials of the mesh, casts
  /// shadows: otherwise the particles are not drawn into shadow maps.
  bool get _castsShadows {
    final material = this.material;
    if (material != null) {
      return material.castsShadows;
    }
    final mesh = this.mesh!;
    for (var i = 0; i < mesh.surfaceCount; i++) {
      if (mesh.surfaces.elementAt(i).material.castsShadows) {
        return true;
      }
    }
    return false;
  }

  /// The instance data of the last draw, for tests and custom renderers.
  @visibleForTesting
  Float32List get instanceBuffer => _instances;

  /// The order of the particles in the last sorted draw.
  @visibleForTesting
  Int32List get drawOrder => _order;

  /// Sorts the particles back to front as seen through [view], into
  /// [_order].
  void _sortBackToFront(Matrix4 view) {
    final b = particles;
    final n = b.length;
    final v = view.storage;
    // The view-space z of a world point is dot(row 2, (x, y, z, 1)); the
    // camera looks along -z, so -z grows away from it.
    var rx = v[2];
    var ry = v[6];
    var rz = v[10];
    var rw = v[14];
    if (space == ParticleSpace.local) {
      // Fold the world transform into the row.
      final m = worldTransformMatrix.storage;
      final lx = rx * m[0] + ry * m[1] + rz * m[2];
      final ly = rx * m[4] + ry * m[5] + rz * m[6];
      final lz = rx * m[8] + ry * m[9] + rz * m[10];
      rw += rx * m[12] + ry * m[13] + rz * m[14];
      rx = lx;
      ry = ly;
      rz = lz;
    }
    final depths = _depths;
    var minDepth = double.infinity;
    var maxDepth = double.negativeInfinity;
    for (var i = 0; i < n; i++) {
      final depth = -(rx * b.posX[i] + ry * b.posY[i] + rz * b.posZ[i] + rw);
      depths[i] = depth;
      if (depth < minDepth) {
        minDepth = depth;
      }
      if (depth > maxDepth) {
        maxDepth = depth;
      }
    }
    final range = maxDepth - minDepth;
    final scale = range > 0 ? 65535 / range : 0.0;
    final keys = _keys;
    for (var i = 0; i < n; i++) {
      // The farthest particle gets the smallest key: it is drawn first.
      keys[i] = 65535 - ((depths[i] - minDepth) * scale).toInt();
    }
    // A stable radix sort on the two bytes of the keys.
    final counts = _counts;
    final scratch = _orderScratch;
    final order = _order;
    counts.fillRange(0, 256, 0);
    for (var i = 0; i < n; i++) {
      counts[keys[i] & 0xFF]++;
    }
    var sum = 0;
    for (var c = 0; c < 256; c++) {
      final value = counts[c];
      counts[c] = sum;
      sum += value;
    }
    for (var i = 0; i < n; i++) {
      scratch[counts[keys[i] & 0xFF]++] = i;
    }
    counts.fillRange(0, 256, 0);
    for (var i = 0; i < n; i++) {
      counts[keys[i] >> 8]++;
    }
    sum = 0;
    for (var c = 0; c < 256; c++) {
      final value = counts[c];
      counts[c] = sum;
      sum += value;
    }
    for (var k = 0; k < n; k++) {
      final i = scratch[k];
      order[counts[keys[i] >> 8]++] = i;
    }
  }

  /// The flipbook frame of the particle at [index], at life progress [t].
  double _frameOf(int index, double t, int frames, bool blending) {
    final flipbook = this.flipbook;
    if (flipbook == null || frames <= 1) {
      return 0;
    }
    final b = particles;
    final start = flipbook.randomStart
        ? (b.seed[index] * frames).floorToDouble()
        : 0.0;
    switch (flipbook.mode) {
      case ParticleFrameMode.overLife:
        final cycles = flipbook.cycles;
        if (cycles == 1 && !flipbook.randomStart) {
          // One pass, ending on the last frame.
          return blending
              ? t * (frames - 1)
              : math.min(t * frames, frames - 1.0).floorToDouble();
        }
        final frame = t * cycles * frames + start;
        return blending ? frame % frames : (frame % frames).floorToDouble();
      case ParticleFrameMode.fps:
        final frame = b.age[index] * flipbook.fps + start;
        return blending ? frame % frames : (frame % frames).floorToDouble();
      case ParticleFrameMode.random:
        return (b.seed[index] * frames).floorToDouble();
    }
  }

  void _writeBillboards(bool sorted, ParticleMaterial material) {
    final b = particles;
    final n = b.length;
    final out = _instances;
    final order = _order;
    final local = space == ParticleSpace.local;
    final m = worldTransformMatrix.storage;
    final scale = _uniformScale(m);
    final sizeCurve = sizeOverLife;
    final colorRamp = colorOverLife;
    final opacityCurve = opacityOverLife;
    final rotationCurve = rotationOverLife;
    final stretchFactor = velocityStretch;
    final stretchMax = math.max(1.0, maxStretch);
    final frames = material.frameCount;
    final blending = material.frameBlending;
    final hasFlipbook = flipbook != null && frames > 1;
    final data = instanceData.storage;
    final d0 = data[0];
    final d1 = data[1];
    final d2 = data[2];
    final d3 = data[3];
    const toUnit = 1 / 255;

    for (var k = 0; k < n; k++) {
      final i = sorted ? order[k] : k;
      var t = b.age[i] * b.invLifespan[i];
      if (t > 1) {
        t = 1;
      }
      var px = b.posX[i];
      var py = b.posY[i];
      var pz = b.posZ[i];
      var vx = b.velX[i];
      var vy = b.velY[i];
      var vz = b.velZ[i];
      if (local) {
        final x = px;
        final y = py;
        final z = pz;
        px = m[0] * x + m[4] * y + m[8] * z + m[12];
        py = m[1] * x + m[5] * y + m[9] * z + m[13];
        pz = m[2] * x + m[6] * y + m[10] * z + m[14];
        final ux = vx;
        final uy = vy;
        final uz = vz;
        vx = m[0] * ux + m[4] * uy + m[8] * uz;
        vy = m[1] * ux + m[5] * uy + m[9] * uz;
        vz = m[2] * ux + m[6] * uy + m[10] * uz;
      }
      final size = (sizeCurve == null ? 1.0 : sizeCurve.transform(t)) * scale;
      var stretch = 1.0;
      if (stretchFactor > 0) {
        final speed = math.sqrt(vx * vx + vy * vy + vz * vz);
        stretch = 1 + speed * stretchFactor;
        if (stretch > stretchMax) {
          stretch = stretchMax;
        }
      }
      final rotation =
          b.rotation[i] +
          (rotationCurve == null ? 0 : rotationCurve.transform(t));
      final frame = hasFlipbook ? _frameOf(i, t, frames, blending) : 0.0;

      final argb = b.color[i];
      var r = ((argb >> 16) & 0xFF) * toUnit;
      var g = ((argb >> 8) & 0xFF) * toUnit;
      var bl = (argb & 0xFF) * toUnit;
      var a = ((argb >> 24) & 0xFF) * toUnit;
      if (colorRamp != null) {
        final ramp = colorRamp.valueAt(t);
        r *= ((ramp >> 16) & 0xFF) * toUnit;
        g *= ((ramp >> 8) & 0xFF) * toUnit;
        bl *= (ramp & 0xFF) * toUnit;
        a *= ((ramp >> 24) & 0xFF) * toUnit;
      }
      if (opacityCurve != null) {
        final opacity = opacityCurve.transform(t);
        a *= opacity < 0 ? 0 : (opacity > 1 ? 1 : opacity);
      }

      final o = k * VertexLayout.instanceStrideInFloats;
      out[o] = px;
      out[o + 1] = py;
      out[o + 2] = pz;
      out[o + 3] = b.width[i] * size;
      out[o + 4] = vx;
      out[o + 5] = vy;
      out[o + 6] = vz;
      out[o + 7] = b.height[i] * size;
      out[o + 8] = rotation;
      out[o + 9] = frame;
      out[o + 10] = b.seed[i];
      out[o + 11] = stretch;
      out[o + 12] = t;
      out[o + 13] = 0;
      out[o + 14] = 0;
      out[o + 15] = 1;
      out[o + 16] = r;
      out[o + 17] = g;
      out[o + 18] = bl;
      out[o + 19] = a;
      out[o + 20] = d0;
      out[o + 21] = d1;
      out[o + 22] = d2;
      out[o + 23] = d3;
    }
  }

  void _writeMeshes(bool sorted) {
    final b = particles;
    final n = b.length;
    final out = _instances;
    final order = _order;
    final local = space == ParticleSpace.local;
    final m = worldTransformMatrix.storage;
    // The linear part of the world transform: the base orientation and scale
    // of every particle.
    final b00 = m[0];
    final b10 = m[1];
    final b20 = m[2];
    final b01 = m[4];
    final b11 = m[5];
    final b21 = m[6];
    final b02 = m[8];
    final b12 = m[9];
    final b22 = m[10];
    final sizeCurve = sizeOverLife;
    final colorRamp = colorOverLife;
    final opacityCurve = opacityOverLife;
    final rotationCurve = rotationOverLife;
    final data = instanceData.storage;
    final d0 = data[0];
    final d1 = data[1];
    final d2 = data[2];
    final d3 = data[3];
    const toUnit = 1 / 255;

    for (var k = 0; k < n; k++) {
      final i = sorted ? order[k] : k;
      var t = b.age[i] * b.invLifespan[i];
      if (t > 1) {
        t = 1;
      }
      var px = b.posX[i];
      var py = b.posY[i];
      var pz = b.posZ[i];
      if (local) {
        final x = px;
        final y = py;
        final z = pz;
        px = m[0] * x + m[4] * y + m[8] * z + m[12];
        py = m[1] * x + m[5] * y + m[9] * z + m[13];
        pz = m[2] * x + m[6] * y + m[10] * z + m[14];
      }
      final size =
          b.width[i] * (sizeCurve == null ? 1.0 : sizeCurve.transform(t));
      final angle =
          b.rotation[i] +
          (rotationCurve == null ? 0 : rotationCurve.transform(t));
      final x = b.axisX[i];
      final y = b.axisY[i];
      final z = b.axisZ[i];
      final c = math.cos(angle);
      final s = math.sin(angle);
      final cc = 1 - c;
      // The rotation about the axis (Rodrigues), column by column.
      final r00 = c + x * x * cc;
      final r10 = y * x * cc + z * s;
      final r20 = z * x * cc - y * s;
      final r01 = x * y * cc - z * s;
      final r11 = c + y * y * cc;
      final r21 = z * y * cc + x * s;
      final r02 = x * z * cc + y * s;
      final r12 = y * z * cc - x * s;
      final r22 = c + z * z * cc;
      // World space: the particle's rotation applies to the system's
      // orientation (R * B); local space: the system's transform applies to
      // the particle (B * R).
      final double l00;
      final double l10;
      final double l20;
      final double l01;
      final double l11;
      final double l21;
      final double l02;
      final double l12;
      final double l22;
      if (local) {
        l00 = b00 * r00 + b01 * r10 + b02 * r20;
        l10 = b10 * r00 + b11 * r10 + b12 * r20;
        l20 = b20 * r00 + b21 * r10 + b22 * r20;
        l01 = b00 * r01 + b01 * r11 + b02 * r21;
        l11 = b10 * r01 + b11 * r11 + b12 * r21;
        l21 = b20 * r01 + b21 * r11 + b22 * r21;
        l02 = b00 * r02 + b01 * r12 + b02 * r22;
        l12 = b10 * r02 + b11 * r12 + b12 * r22;
        l22 = b20 * r02 + b21 * r12 + b22 * r22;
      } else {
        l00 = r00 * b00 + r01 * b10 + r02 * b20;
        l10 = r10 * b00 + r11 * b10 + r12 * b20;
        l20 = r20 * b00 + r21 * b10 + r22 * b20;
        l01 = r00 * b01 + r01 * b11 + r02 * b21;
        l11 = r10 * b01 + r11 * b11 + r12 * b21;
        l21 = r20 * b01 + r21 * b11 + r22 * b21;
        l02 = r00 * b02 + r01 * b12 + r02 * b22;
        l12 = r10 * b02 + r11 * b12 + r12 * b22;
        l22 = r20 * b02 + r21 * b12 + r22 * b22;
      }

      final argb = b.color[i];
      var r = ((argb >> 16) & 0xFF) * toUnit;
      var g = ((argb >> 8) & 0xFF) * toUnit;
      var bl = (argb & 0xFF) * toUnit;
      var a = ((argb >> 24) & 0xFF) * toUnit;
      if (colorRamp != null) {
        final ramp = colorRamp.valueAt(t);
        r *= ((ramp >> 16) & 0xFF) * toUnit;
        g *= ((ramp >> 8) & 0xFF) * toUnit;
        bl *= (ramp & 0xFF) * toUnit;
        a *= ((ramp >> 24) & 0xFF) * toUnit;
      }
      if (opacityCurve != null) {
        final opacity = opacityCurve.transform(t);
        a *= opacity < 0 ? 0 : (opacity > 1 ? 1 : opacity);
      }

      final o = k * VertexLayout.instanceStrideInFloats;
      out[o] = l00 * size;
      out[o + 1] = l10 * size;
      out[o + 2] = l20 * size;
      out[o + 3] = 0;
      out[o + 4] = l01 * size;
      out[o + 5] = l11 * size;
      out[o + 6] = l21 * size;
      out[o + 7] = 0;
      out[o + 8] = l02 * size;
      out[o + 9] = l12 * size;
      out[o + 10] = l22 * size;
      out[o + 11] = 0;
      out[o + 12] = px;
      out[o + 13] = py;
      out[o + 14] = pz;
      out[o + 15] = 1;
      out[o + 16] = r;
      out[o + 17] = g;
      out[o + 18] = bl;
      out[o + 19] = a;
      out[o + 20] = d0;
      out[o + 21] = d1;
      out[o + 22] = d2;
      out[o + 23] = d3;
    }
  }

  /// The quad every billboard is drawn with: corners in `[-0.5, 0.5]`,
  /// texture coordinates with `v` growing downwards.
  static final Surface _quad = Surface.fromBuffers(
    vertices: Float32List.fromList(const [
      -0.5, -0.5, 0, 0, 1, //
      0.5, -0.5, 0, 1, 1, //
      0.5, 0.5, 0, 1, 0, //
      -0.5, 0.5, 0, 0, 0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 2, 3, 0]),
    layout: quadLayout,
  );

  /// The vertex layout of the quad billboards are drawn with: a corner
  /// position and texture coordinates.
  static final VertexLayout quadLayout = VertexLayout(const [
    VertexAttribute(VertexLayout.positionAttribute, 3),
    VertexAttribute('vertexTexCoord', 2),
  ]);
}

/// The timeline of an emitter within a system.
class _EmitterState(int bursts) {
  double clock = 0;
  double debt = 0;
  double distanceDebt = 0;
  bool completed = false;
  final List<bool> fired = List.filled(bursts, false);

  void restart() {
    clock = 0;
    debt = 0;
    distanceDebt = 0;
    completed = false;
    fired.fillRange(0, fired.length, false);
  }
}
