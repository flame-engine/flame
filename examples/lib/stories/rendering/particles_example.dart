import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesExample extends FlameGame {
  static const String description = '''
    Showcases the declarative particle system. Every cell is a single
    ParticleEmitterComponent: a reusable ParticleEmitter preset describes
    what to spawn (rate, bursts, shapes, velocities) and how particles
    evolve (gravity, drag, scale, opacity and color over life), while a
    ParticleRenderer draws all of them in one batched draw call.
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
      ('Fire', _fire()),
      ('Smoke', _smoke()),
      ('Confetti', _confetti(zap)),
      ('Ring', _ring()),
      ('Sparks', _sparks(zap)),
      ('Trail', _trail(cell)),
      ('Custom renderer', _customRenderer()),
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
          anchor: Anchor.topCenter,
          position: Vector2(center.x, row * cell.y + 8),
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      );
    }
  }

  /// A continuous stream of particles thrown upwards and pulled back down
  /// by gravity.
  PositionComponent _fountain() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 120,
        lifespan: (1, 1.6),
        speed: (120, 190),
        direction: -tau / 4,
        spread: tau / 16,
        gravity: Vector2(0, 200),
        size: (2, 5),
        colorOverLife: ColorRamp(const [Colors.white, Colors.lightBlue]),
        opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeIn),
      ),
      renderer: CircleParticleRenderer(),
    );
  }

  /// A burst that repeats every 1.5 seconds; drag slows the debris down and
  /// the color ramp cools it off.
  PositionComponent _explosion() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        bursts: const [EmitterBurst(0, 150)],
        duration: 1.5,
        loop: true,
        lifespan: (0.6, 1.4),
        speed: (30, 220),
        drag: 2,
        size: (2, 6),
        scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.yellow, Colors.deepOrange, Colors.red],
        ),
      ),
      renderer: CircleParticleRenderer(),
    );
  }

  /// Soft, additively blended circles rising from a small area read as
  /// flames.
  PositionComponent _fire() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 90,
        lifespan: (0.5, 1.1),
        shape: const CircleEmitterShape(12),
        speed: (40, 90),
        direction: -tau / 4,
        spread: tau / 10,
        size: (12, 26),
        scaleOverLife: ParticleCurve(1, 0.3),
        colorOverLife: ColorRamp(
          const [Colors.white, Colors.amber, Colors.deepOrange, Colors.red],
        ),
        opacityOverLife: ParticleCurve(0.8, 0),
      ),
      renderer: CircleParticleRenderer(
        softness: 0.8,
        blendMode: BlendMode.plus,
      ),
    );
  }

  /// Slowly drifting, growing and fading soft circles.
  PositionComponent _smoke() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 25,
        lifespan: (1.5, 2.5),
        shape: const CircleEmitterShape(8),
        speed: (20, 45),
        direction: -tau / 4,
        spread: tau / 8,
        drag: 0.5,
        size: (15, 25),
        scaleOverLife: ParticleCurve(1, 2.5),
        colorOverLife: ColorRamp.solid(Colors.blueGrey),
        opacityOverLife: ParticleCurve.custom(
          (t) => t < 0.2 ? t / 0.2 * 0.5 : (1 - t) / 0.8 * 0.5,
        ),
      ),
      renderer: CircleParticleRenderer(softness: 0.9),
    );
  }

  /// Tumbling sprites raining down inside a rectangle.
  PositionComponent _confetti(ui.Image zap) {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 30,
        lifespan: (1.2, 2),
        shape: const RectangleEmitterShape(120, 10),
        speed: (10, 40),
        direction: tau / 4,
        spread: tau / 12,
        gravity: Vector2(0, 60),
        size: (8, 16),
        rotation: (0, tau),
        spin: (-8, 8),
        opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeInExpo),
      ),
      renderer: SpriteParticleRenderer.fromImage(zap),
    );
  }

  /// Particles spawning on the edge of a circle and drifting outwards.
  PositionComponent _ring() {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 200,
        lifespan: (0.4, 0.8),
        shape: const CircleEmitterShape(45, edgeOnly: true),
        speed: (5, 25),
        size: (1.5, 3),
        colorOverLife: ColorRamp(const [Colors.tealAccent, Colors.teal]),
        opacityOverLife: ParticleCurve(1, 0),
      ),
      renderer: CircleParticleRenderer(),
    );
  }

  /// Fast directional sprites that rotate to follow their velocity as
  /// gravity bends their path.
  PositionComponent _sparks(ui.Image zap) {
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        bursts: const [EmitterBurst(0, 20), EmitterBurst(0.5, 20)],
        duration: 1,
        loop: true,
        lifespan: (0.5, 0.9),
        speed: (150, 280),
        direction: -tau / 4,
        spread: tau / 6,
        gravity: Vector2(0, 400),
        size: (10, 16),
        rotateToVelocity: true,
        opacityOverLife: ParticleCurve(1, 0),
      ),
      renderer: SpriteParticleRenderer.fromImage(zap),
    );
  }

  /// A moving emitter with worldSpace enabled: spawned particles stay
  /// behind, forming a trail.
  PositionComponent _trail(Vector2 cell) {
    return _OrbitingEmitter(
      orbit: Vector2(cell.x / 3, cell.y / 4),
      child: ParticleEmitterComponent(
        emitter: ParticleEmitter(
          rate: 150,
          lifespan: (0.3, 0.7),
          speed: (0, 10),
          size: (2, 6),
          scaleOverLife: ParticleCurve(1, 0),
          colorOverLife: ColorRamp(const [Colors.purpleAccent, Colors.indigo]),
        ),
        renderer: CircleParticleRenderer(),
        worldSpace: true,
      ),
    );
  }

  /// Full control over drawing through a CallbackParticleRenderer, here
  /// rendering unbatched squares directly to the canvas.
  PositionComponent _customRenderer() {
    final paint = Paint();
    return ParticleEmitterComponent(
      emitter: ParticleEmitter(
        rate: 40,
        lifespan: (0.8, 1.6),
        speed: (20, 60),
        size: (4, 10),
        spin: (-3, 3),
      ),
      renderer: CallbackParticleRenderer((canvas, particles) {
        for (var i = 0; i < particles.length; i++) {
          final progress = particles.progressAt(i);
          paint.color = Color.lerp(
            Colors.limeAccent,
            Colors.transparent,
            progress,
          )!;
          canvas.save();
          canvas.translate(particles.posX[i], particles.posY[i]);
          canvas.rotate(particles.rotation[i]);
          final side = particles.size[i];
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: side, height: side),
            paint,
          );
          canvas.restore();
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
