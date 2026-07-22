import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesExample extends FlameGame {
  static const String description = '''
    Showcases the declarative particle system. Every effect is built from
    ParticleEmitterComponents: reusable ParticleEmitter presets describe what
    to spawn (rate, bursts, shapes, velocities) and how particles evolve
    (gravity, drag, scale, opacity and color over life), while renderers draw
    all particles of an emitter in a single batched draw call. Watch the
    live particle counter: everything runs from preallocated buffers.
  ''';

  static const int _columns = 3;
  static const int _rows = 3;

  @override
  Future<void> onLoad() async {
    final zap = await images.load('zap.png');
    final cell = Vector2(size.x / _columns, size.y / _rows);

    final effects = <(String, PositionComponent)>[
      ('Fountain', _fountain()),
      ('Explosion', _explosion()),
      ('Inferno', _inferno()),
      ('Snow', _snow(cell)),
      ('Confetti', _confetti(zap)),
      ('Portal', _portal()),
      ('Sparks', _sparks(zap)),
      ('Comet', _comet(cell)),
      ('Velocity streaks', _velocityStreaks()),
    ];

    for (final (index, (label, component)) in effects.indexed) {
      final column = index % _columns;
      final row = index ~/ _columns;
      final center = Vector2(
        (column + 0.5) * cell.x,
        (row + 0.5) * cell.y,
      );
      add(component..position = center);
      add(
        TextComponent(
          text: label,
          anchor: Anchor.bottomCenter,
          position: Vector2(center.x, (row + 1) * cell.y - 6),
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    // Top-center, so it does not collide with the Dashbook menu button that
    // overlays the top-left corner.
    add(
      _StatsText(
        position: Vector2(size.x / 2, 8),
        anchor: Anchor.topCenter,
      ),
    );
  }

  /// A continuous jet of glowing droplets pulled back down by gravity.
  PositionComponent _fountain() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 250,
        lifespan: (1, 1.7),
        speed: (130, 210),
        direction: -tau / 4,
        spread: tau / 14,
        gravity: Vector2(0, 220),
        size: (2, 6),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.cyanAccent, Colors.blueAccent],
        ),
        opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeIn),
      ),
      renderer: CircleParticleRenderer(
        softness: 0.4,
        blendMode: BlendMode.plus,
      ),
    );
  }

  /// A repeating explosion layered from a bright flash and hot debris that
  /// drag slows down as it cools off.
  PositionComponent _explosion() {
    final flash = ParticleEmitter(
      bursts: const [EmitterBurst(0, 1)],
      duration: 1.5,
      loop: true,
      lifespan: (0.25, 0.25),
      size: (60, 60),
      scaleOverLife: ParticleCurve(0.3, 2.2, curve: Curves.easeOutExpo),
      colorOverLife: ColorRamp(const [Colors.white, Colors.orangeAccent]),
      opacityOverLife: ParticleCurve(1, 0),
    );
    final debris = ParticleEmitter(
      bursts: const [EmitterBurst(0, 250)],
      duration: 1.5,
      loop: true,
      lifespan: (0.5, 1.4),
      speed: (40, 300),
      drag: 2.5,
      size: (1.5, 5),
      scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),
      colorOverLife: ColorRamp(
        const [
          Colors.white,
          Colors.yellowAccent,
          Colors.deepOrange,
          Colors.red,
        ],
      ),
    );
    final glow = CircleParticleRenderer(
      softness: 0.5,
      blendMode: BlendMode.plus,
    );
    return PositionComponent(
      children: [
        ParticleEmitterComponent(emitter: flash, renderer: glow),
        ParticleEmitterComponent(emitter: debris, renderer: glow),
      ],
    );
  }

  /// Flames, drifting smoke, and crackling embers layered into one bonfire.
  PositionComponent _inferno() {
    final flames = ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 140,
        lifespan: (0.5, 1.1),
        shape: const CircleEmitterShape(14),
        speed: (50, 110),
        direction: -tau / 4,
        spread: tau / 10,
        size: (14, 30),
        scaleOverLife: ParticleCurve(1, 0.2, curve: Curves.easeOut),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.amber, Colors.deepOrange, Colors.red],
        ),
        opacityOverLife: ParticleCurve(0.9, 0),
      ),
      renderer: CircleParticleRenderer(
        softness: 0.8,
        blendMode: BlendMode.plus,
      ),
    );
    final smoke = ParticleEmitterComponent(
      position: Vector2(0, -40),
      emitter: ParticleEmitter(
        rate: 20,
        lifespan: (1.5, 2.5),
        shape: const CircleEmitterShape(10),
        speed: (25, 50),
        direction: -tau / 4,
        spread: tau / 8,
        size: (18, 30),
        scaleOverLife: ParticleCurve(1, 2.8),
        colorOverLife: ColorRamp.solid(Colors.blueGrey.shade700),
        opacityOverLife: ParticleCurve.custom(
          (t) => t < 0.2 ? t / 0.2 * 0.4 : (1 - t) / 0.8 * 0.4,
        ),
      ),
      renderer: CircleParticleRenderer(softness: 0.9),
    );
    final embers = ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 12,
        lifespan: (1, 2),
        shape: const CircleEmitterShape(16),
        speed: (30, 90),
        direction: -tau / 4,
        spread: tau / 7,
        gravity: Vector2(0, -30),
        size: (1.5, 3.5),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.orangeAccent, Colors.red],
        ),
        opacityOverLife: ParticleCurve.custom((t) => 0.5 + 0.5 * sin(t * 25)),
      ),
      renderer: CircleParticleRenderer(blendMode: BlendMode.plus),
    );
    return PositionComponent(children: [smoke, flames, embers]);
  }

  /// Soft flakes drifting down across the whole cell.
  PositionComponent _snow(Vector2 cell) {
    return ParticleEmitterComponent(
      position: Vector2(0, -cell.y / 2),
      emitter: ParticleEmitter(
        rate: 40,
        lifespan: (3, 5),
        shape: RectangleEmitterShape(cell.x * 0.9, 4),
        speed: (25, 60),
        direction: tau / 4,
        spread: tau / 24,
        size: (2, 7),
        opacityOverLife: ParticleCurve.custom(
          (t) => t < 0.1 ? t / 0.1 : (1 - t) / 0.9,
        ),
      ),
      renderer: CircleParticleRenderer(softness: 0.6),
    );
  }

  /// Three tinted sprite emitters make multicolored, tumbling confetti.
  PositionComponent _confetti(ui.Image zap) {
    ParticleEmitterComponent emitterWithColor(Color color) {
      return ParticleEmitterComponent(
        emitter: ParticleEmitter(
          rate: 12,
          lifespan: (1.4, 2.2),
          shape: const RectangleEmitterShape(130, 10),
          speed: (10, 40),
          direction: tau / 4,
          spread: tau / 12,
          gravity: Vector2(0, 70),
          size: (8, 16),
          rotation: (0, tau),
          spin: (-9, 9),
          colorOverLife: ColorRamp.solid(color),
          opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeInExpo),
        ),
        renderer: SpriteParticleRenderer.fromImage(zap),
      );
    }

    return PositionComponent(
      position: Vector2(0, -60),
      children: [
        emitterWithColor(Colors.pinkAccent),
        emitterWithColor(Colors.tealAccent),
        emitterWithColor(Colors.amberAccent),
      ],
    );
  }

  /// A glowing ring of particles around a pulsing core.
  PositionComponent _portal() {
    final ring = ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 350,
        lifespan: (0.4, 0.9),
        shape: const CircleEmitterShape(45, edgeOnly: true),
        speed: (3, 22),
        size: (1.5, 4),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.tealAccent, Colors.indigoAccent],
        ),
        opacityOverLife: ParticleCurve(1, 0),
      ),
      renderer: CircleParticleRenderer(
        softness: 0.4,
        blendMode: BlendMode.plus,
      ),
    );
    final core = ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 20,
        lifespan: (0.6, 1.2),
        size: (25, 45),
        scaleOverLife: ParticleCurve(0.4, 1.4, curve: Curves.easeOut),
        colorOverLife: ColorRamp(const [Colors.tealAccent, Colors.indigo]),
        opacityOverLife: ParticleCurve(0.35, 0),
      ),
      renderer: CircleParticleRenderer(
        softness: 1,
        blendMode: BlendMode.plus,
      ),
    );
    return PositionComponent(children: [core, ring]);
  }

  /// Fast directional sprites that rotate to follow their velocity as
  /// gravity bends their path.
  PositionComponent _sparks(ui.Image zap) {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        bursts: const [EmitterBurst(0, 25), EmitterBurst(0.5, 25)],
        duration: 1,
        loop: true,
        lifespan: (0.5, 0.9),
        speed: (160, 300),
        direction: -tau / 4,
        spread: tau / 6,
        gravity: Vector2(0, 450),
        size: (10, 16),
        rotateToVelocity: true,
        opacityOverLife: ParticleCurve(1, 0),
      ),
      renderer: SpriteParticleRenderer.fromImage(zap),
    );
  }

  /// A moving emitter with worldSpace enabled: spawned particles stay
  /// behind, forming a glowing tail.
  PositionComponent _comet(Vector2 cell) {
    return _OrbitingEmitter(
      orbit: Vector2(cell.x / 3, cell.y / 4),
      child: ParticleEmitterComponent(
        emitter: ParticleEmitter(
          rate: 350,
          lifespan: (0.3, 0.8),
          shape: const CircleEmitterShape(3),
          speed: (0, 12),
          size: (3, 9),
          scaleOverLife: ParticleCurve(1, 0),
          colorOverLife: ColorRamp(
            const [Colors.white, Colors.purpleAccent, Colors.indigo],
          ),
          opacityOverLife: ParticleCurve(0.9, 0),
        ),
        renderer: CircleParticleRenderer(
          softness: 0.6,
          blendMode: BlendMode.plus,
        ),
        worldSpace: true,
      ),
    );
  }

  /// Full access to the raw particle buffer through a
  /// CallbackParticleRenderer, here drawing every particle as a motion
  /// streak along its velocity.
  PositionComponent _velocityStreaks() {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 120,
        lifespan: (0.8, 1.6),
        shape: const CircleEmitterShape(10),
        speed: (40, 140),
        drag: 1.2,
        size: (2, 4),
      ),
      renderer: CallbackParticleRenderer((canvas, particles) {
        for (var i = 0; i < particles.length; i++) {
          final progress = particles.progressAt(i);
          paint.color = Color.lerp(
            Colors.limeAccent,
            Colors.transparent,
            progress,
          )!;
          final x = particles.posX[i];
          final y = particles.posY[i];
          canvas.drawLine(
            Offset(x, y),
            Offset(
              x - particles.velX[i] * 0.08,
              y - particles.velY[i] * 0.08,
            ),
            paint,
          );
        }
      }),
    );
  }
}

/// Moves its emitter child along a Lissajous-like path.
class _OrbitingEmitter extends PositionComponent {
  _OrbitingEmitter({required this.orbit, required PositionComponent child}) {
    add(child);
  }

  final Vector2 orbit;
  late final Vector2 _center = position.clone();
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    position.setValues(
      _center.x + cos(_time * 2) * orbit.x,
      _center.y + sin(_time * 3) * orbit.y,
    );
  }
}

/// Displays the frame rate and the total number of live particles across
/// all emitters, refreshed a few times per second.
class _StatsText extends TextComponent with HasGameReference {
  _StatsText({super.position, super.anchor})
    : super(
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );

  final FpsComponent _fps = FpsComponent();
  double _sinceRefresh = 1;

  @override
  Future<void> onLoad() async {
    add(_fps);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sinceRefresh += dt;
    if (_sinceRefresh < 0.25) {
      return;
    }
    _sinceRefresh = 0;
    var count = 0;
    for (final emitter
        in game.descendants().whereType<ParticleEmitterComponent>()) {
      count += emitter.particleCount;
    }
    text = '${_fps.fps.round()} fps, $count particles';
  }
}
