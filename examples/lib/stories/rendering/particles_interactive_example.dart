import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesInteractiveExample extends FlameGame with PanDetector {
  static const description =
      'Drag around the canvas to paint with particles, and pick an effect in '
      'the properties panel (the knobs icon in the top right) to try the '
      'different emitter presets and renderers. A single pooled '
      'ParticleEmitterComponent follows the pointer: worldSpace keeps '
      'already-spawned particles in place while emit() releases more from '
      'the preallocated buffer, so no objects are allocated while you draw.';

  /// The effect presets selectable in the properties panel.
  static const List<String> effects = [
    'Sparkles',
    'Fire',
    'Smoke',
    'Explosions',
    'Sparks',
    'Confetti',
    'Streaks',
    'Bubbles',
  ];

  ParticlesInteractiveExample({
    required this.effect,
    required double zoom,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: 400,
           height: 600,
         )..viewfinder.zoom = zoom,
       );

  /// The name of the selected effect preset, one of [effects].
  final String effect;

  late ParticleEmitterComponent _emitter;

  /// How many particles are released when a drag starts and on every drag
  /// update; tuned per preset.
  int _perDragStart = 0;
  int _perDragUpdate = 20;

  @override
  Future<void> onLoad() async {
    final zap = await images.load('zap.png');
    _emitter = _buildEffect(zap);
    add(_emitter);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _emitter.position = info.eventPosition.widget;
    _emitter.emit(_perDragStart);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _emitter.position = info.eventPosition.widget;
    _emitter.emit(_perDragUpdate);
  }

  /// All presets share the same pooled setup: emission is driven purely by
  /// emit() from the drag callbacks, and worldSpace leaves spawned
  /// particles behind as the emitter follows the pointer.
  ParticleEmitterComponent _pooled(
    ParticleEmitter emitter,
    ParticleRenderer renderer,
  ) {
    return ParticleEmitterComponent(
      emitter: emitter,
      renderer: renderer,
      emitting: false,
      removeOnFinish: false,
      worldSpace: true,
    );
  }

  ParticleEmitterComponent _buildEffect(ui.Image zap) {
    switch (effect) {
      case 'Fire':
        _perDragUpdate = 6;
        return _pooled(
          ParticleEmitter(
            maxParticles: 4096,
            lifespan: (0.4, 1),
            shape: const CircleEmitterShape(6),
            speed: (20, 70),
            direction: -tau / 4,
            spread: tau / 6,
            size: (10, 24),
            scaleOverLife: ParticleCurve(1, 0.3),
            colorOverLife: ColorRamp(
              const [Colors.white, Colors.amber, Colors.deepOrange, Colors.red],
            ),
            opacityOverLife: ParticleCurve(0.9, 0),
          ),
          CircleParticleRenderer(softness: 0.8, blendMode: BlendMode.plus),
        );
      case 'Smoke':
        _perDragUpdate = 4;
        return _pooled(
          ParticleEmitter(
            maxParticles: 2048,
            lifespan: (1.5, 3),
            shape: const CircleEmitterShape(6),
            speed: (10, 40),
            direction: -tau / 4,
            spread: tau / 5,
            drag: 0.5,
            size: (14, 24),
            scaleOverLife: ParticleCurve(1, 2.5),
            colorOverLife: ColorRamp.solid(Colors.blueGrey),
            opacityOverLife: ParticleCurve.custom(
              (t) => t < 0.2 ? t / 0.2 * 0.4 : (1 - t) / 0.8 * 0.4,
            ),
          ),
          CircleParticleRenderer(softness: 0.9),
        );
      case 'Explosions':
        _perDragStart = 120;
        _perDragUpdate = 5;
        return _pooled(
          ParticleEmitter(
            maxParticles: 8192,
            lifespan: (0.4, 1.2),
            speed: (40, 260),
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
          ),
          CircleParticleRenderer(softness: 0.5, blendMode: BlendMode.plus),
        );
      case 'Sparks':
        _perDragUpdate = 6;
        return _pooled(
          ParticleEmitter(
            maxParticles: 4096,
            lifespan: (0.5, 1),
            speed: (100, 300),
            gravity: Vector2(0, 500),
            size: (8, 14),
            rotateToVelocity: true,
            opacityOverLife: ParticleCurve(1, 0),
          ),
          SpriteParticleRenderer.fromImage(zap),
        );
      case 'Confetti':
        _perDragUpdate = 6;
        return _pooled(
          ParticleEmitter(
            maxParticles: 4096,
            lifespan: (1, 2),
            speed: (20, 90),
            gravity: Vector2(0, 150),
            drag: 0.5,
            size: (6, 14),
            rotation: (0, tau),
            spin: (-10, 10),
            colorOverLife: ColorRamp(
              const [Colors.pinkAccent, Colors.tealAccent, Colors.amberAccent],
            ),
            opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeInExpo),
          ),
          SpriteParticleRenderer.fromImage(zap),
        );
      case 'Streaks':
        _perDragUpdate = 12;
        final paint = Paint()
          ..strokeWidth = 2
          ..strokeCap = ui.StrokeCap.round
          ..blendMode = BlendMode.plus;
        return _pooled(
          ParticleEmitter(
            maxParticles: 8192,
            lifespan: (0.6, 1.4),
            speed: (60, 200),
            drag: 1.5,
            size: (2, 4),
          ),
          CallbackParticleRenderer((canvas, particles) {
            for (var i = 0; i < particles.length; i++) {
              paint.color = Color.lerp(
                Colors.limeAccent,
                Colors.transparent,
                particles.progressAt(i),
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
      case 'Bubbles':
        _perDragUpdate = 8;
        return _pooled(
          ParticleEmitter(
            maxParticles: 4096,
            lifespan: (0.8, 2),
            shape: const CircleEmitterShape(8),
            speed: (5, 40),
            gravity: Vector2(0, -120),
            drag: 1,
            size: (3, 10),
            colorOverLife: ColorRamp(
              const [Colors.white, Colors.lightBlueAccent],
            ),
            opacityOverLife: ParticleCurve(0.7, 0),
          ),
          CircleParticleRenderer(),
        );
      case 'Sparkles':
      default:
        _perDragUpdate = 20;
        return _pooled(
          ParticleEmitter(
            maxParticles: 8192,
            lifespan: (0.5, 2),
            shape: const CircleEmitterShape(4),
            speed: (10, 120),
            drag: 1,
            size: (2, 6),
            scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),
            colorOverLife: ColorRamp(
              const [Colors.white, Colors.cyanAccent, Colors.purpleAccent],
            ),
          ),
          CircleParticleRenderer(softness: 0.4, blendMode: BlendMode.plus),
        );
    }
  }
}
