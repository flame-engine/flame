import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/particles/particle_buffer.dart';
import 'package:flame/src/particles/particle_emitter.dart';
import 'package:flame/src/particles/particle_range.dart';
import 'package:flame/src/particles/particle_renderer.dart';

/// A component that spawns, simulates, and renders particles described by a
/// [ParticleEmitter].
///
/// The simulation is data-oriented: all particle state lives in a
/// preallocated [ParticleBuffer], and the built-in texture renderers draw
/// every particle in a single batched canvas call, so tens of thousands of
/// particles are cheap.
///
/// ```dart
/// world.add(
///   ParticleEmitterComponent(
///     position: Vector2(200, 100),
///     emitter: ParticleEmitter(
///       bursts: [EmitterBurst(0, 200)],
///       lifespan: (0.4, 1.2),
///       speed: (50, 150),
///       gravity: Vector2(0, 200),
///       scaleOverLife: ParticleCurve(1, 0),
///       colorOverLife: ColorRamp([Colors.yellow, Colors.red]),
///     ),
///     renderer: CircleParticleRenderer(),
///   ),
/// );
/// ```
///
/// Particles simulate in the component's local coordinate system, so moving
/// the component moves all live particles with it. Set [worldSpace] to true
/// to leave already-spawned particles behind instead, which is what trails
/// and exhaust effects want.
class ParticleEmitterComponent extends PositionComponent {
  /// Creates a particle emitter component.
  ///
  /// [emitter] describes what to spawn and how it behaves; [renderer]
  /// describes how it is drawn. When [removeOnFinish] is true (the
  /// default), the component removes itself once emission has naturally
  /// finished and the last particle has died; endless emitters are never
  /// removed automatically. Pass a seeded [random] for deterministic
  /// behavior.
  ParticleEmitterComponent({
    required this.emitter,
    required this.renderer,
    this.removeOnFinish = true,
    this.worldSpace = false,
    bool emitting = true,
    Random? random,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : _emitting = emitting,
       random = random ?? Random(),
       _buffer = ParticleBuffer(emitter.maxParticles),
       _burstFired = List.filled(emitter.bursts.length, false);

  /// The description of what to spawn and how particles behave.
  final ParticleEmitter emitter;

  /// The renderer that draws the live particles.
  final ParticleRenderer renderer;

  /// Whether the component removes itself once emission has finished and no
  /// particles are alive.
  bool removeOnFinish;

  /// When true, live particles keep their world position while the
  /// component moves, so a moving emitter leaves a trail behind.
  ///
  /// Only translation is compensated: ancestors of the component (and the
  /// component itself) should not be rotated or scaled.
  final bool worldSpace;

  /// The random source used for all sampling; seed it for determinism.
  final Random random;

  final ParticleBuffer _buffer;
  final List<bool> _burstFired;
  final Vector2 _sampledPosition = Vector2.zero();
  Vector2? _lastAbsolutePosition;

  bool _emitting;
  bool _completed = false;
  double _clock = 0;
  double _emitDebt = 0;

  /// The live particles. Exposed for custom renderers, custom behaviors,
  /// and tests; treat it as read-only unless you know what you are doing.
  ParticleBuffer get particles => _buffer;

  /// The number of currently live particles.
  int get particleCount => _buffer.length;

  /// Whether the emission timeline is running.
  bool get emitting => _emitting;

  /// Whether emission has naturally finished and no particles are alive.
  bool get isFinished => _completed && _buffer.length == 0;

  @override
  FutureOr<void> onLoad() => renderer.onLoad();

  /// Starts (or resumes) emission; if emission had finished, the timeline
  /// restarts from the beginning.
  void start() {
    if (_completed) {
      _clock = 0;
      _emitDebt = 0;
      _burstFired.fillRange(0, _burstFired.length, false);
      _completed = false;
    }
    _emitting = true;
  }

  /// Pauses emission; live particles keep simulating.
  void stop() => _emitting = false;

  /// Immediately spawns [count] particles, independently of the emission
  /// timeline. Spawns beyond the emitter's `maxParticles` are dropped.
  void emit(int count) => _spawnMany(count);

  /// Removes all live particles.
  void clearParticles() => _buffer.clear();

  @override
  void update(double dt) {
    super.update(dt);
    if (worldSpace) {
      _compensateMovement();
    }
    if (_emitting && !_completed) {
      _advanceEmission(dt);
    }
    _simulate(dt);
    if (removeOnFinish && isFinished) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderer.render(canvas, _buffer);
  }

  void _compensateMovement() {
    final current = absolutePosition;
    final last = _lastAbsolutePosition;
    if (last == null) {
      _lastAbsolutePosition = current.clone();
      return;
    }
    final dx = current.x - last.x;
    final dy = current.y - last.y;
    if (dx != 0 || dy != 0) {
      final buffer = _buffer;
      for (var i = 0; i < buffer.length; i++) {
        buffer.posX[i] -= dx;
        buffer.posY[i] -= dy;
      }
    }
    last.setFrom(current);
  }

  void _advanceEmission(double dt) {
    final end = emitter.emissionEndTime;
    final previous = _clock;
    _clock += dt;
    if (emitter.rate > 0) {
      final activeTime = min(_clock, end) - previous;
      if (activeTime > 0) {
        _emitDebt += emitter.rate * activeTime;
        final count = _emitDebt.floor();
        _emitDebt -= count;
        _spawnMany(count);
      }
    }
    final bursts = emitter.bursts;
    for (var i = 0; i < bursts.length; i++) {
      if (!_burstFired[i] && _clock >= bursts[i].time) {
        _burstFired[i] = true;
        _spawnMany(bursts[i].count);
      }
    }
    if (_clock >= end) {
      if (emitter.loop) {
        // duration is asserted to be set and positive when looping.
        _clock = _clock % end;
        _burstFired.fillRange(0, _burstFired.length, false);
      } else {
        _completed = true;
      }
    }
  }

  void _spawnMany(int count) {
    for (var i = 0; i < count; i++) {
      if (!_spawnOne()) {
        break;
      }
    }
  }

  bool _spawnOne() {
    final buffer = _buffer;
    final index = buffer.spawn();
    if (index < 0) {
      return false;
    }
    emitter.shape.samplePosition(random, _sampledPosition);
    buffer.posX[index] = _sampledPosition.x;
    buffer.posY[index] = _sampledPosition.y;
    final direction =
        emitter.direction + (random.nextDouble() - 0.5) * emitter.spread;
    final speed = emitter.speed.sample(random);
    buffer.velX[index] = cos(direction) * speed;
    buffer.velY[index] = sin(direction) * speed;
    final lifespan = max(emitter.lifespan.sample(random), 1e-4);
    buffer.age[index] = 0;
    buffer.invLifespan[index] = 1 / lifespan;
    final size = emitter.size.sample(random);
    buffer.baseSize[index] = size;
    final scaleCurve = emitter.scaleOverLife;
    buffer.size[index] = scaleCurve == null
        ? size
        : size * scaleCurve.transform(0);
    buffer.rotation[index] = emitter.rotateToVelocity
        ? direction
        : emitter.rotation.sample(random);
    buffer.spin[index] = emitter.spin.sample(random);
    buffer.color[index] = _colorAt(0);
    return true;
  }

  void _simulate(double dt) {
    final buffer = _buffer;
    final accelerationX = emitter.gravity.x;
    final accelerationY = emitter.gravity.y;
    final damping = emitter.drag > 0 ? 1 / (1 + emitter.drag * dt) : 1.0;
    final scaleCurve = emitter.scaleOverLife;
    final tintsOverLife =
        emitter.colorOverLife != null || emitter.opacityOverLife != null;
    var i = 0;
    while (i < buffer.length) {
      final age = buffer.age[i] + dt;
      final progress = age * buffer.invLifespan[i];
      if (progress >= 1) {
        buffer.removeAt(i);
        continue;
      }
      buffer.age[i] = age;
      final velX = (buffer.velX[i] + accelerationX * dt) * damping;
      final velY = (buffer.velY[i] + accelerationY * dt) * damping;
      buffer.velX[i] = velX;
      buffer.velY[i] = velY;
      buffer.posX[i] += velX * dt;
      buffer.posY[i] += velY * dt;
      if (emitter.rotateToVelocity) {
        buffer.rotation[i] = atan2(velY, velX);
      } else {
        buffer.rotation[i] += buffer.spin[i] * dt;
      }
      if (scaleCurve != null) {
        buffer.size[i] = buffer.baseSize[i] * scaleCurve.transform(progress);
      }
      if (tintsOverLife) {
        buffer.color[i] = _colorAt(progress);
      }
      i++;
    }
  }

  int _colorAt(double progress) {
    var color = emitter.colorOverLife?.valueAt(progress) ?? 0xffffffff;
    final opacityCurve = emitter.opacityOverLife;
    if (opacityCurve != null) {
      final opacity = opacityCurve.transform(progress).clamp(0.0, 1.0);
      final alpha = (((color >> 24) & 0xff) * opacity).round();
      color = (alpha << 24) | (color & 0x00ffffff);
    }
    return color;
  }
}
