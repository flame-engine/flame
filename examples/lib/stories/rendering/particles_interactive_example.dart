import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticlesInteractiveExample extends FlameGame with PanDetector {
  static const description =
      'A single pooled ParticleEmitterComponent follows the pointer while '
      'you drag: worldSpace keeps already-spawned particles in place, and '
      'emit() releases more from the preallocated buffer, so no objects are '
      'allocated while the effect runs.';

  ParticlesInteractiveExample({
    required Color from,
    required Color to,
    required double zoom,
  }) : _emitter = ParticleEmitterComponent(
         emitter: ParticleEmitter(
           maxParticles: 5000,
           lifespan: (0.5, 2),
           shape: const CircleEmitterShape(4),
           speed: (10, 120),
           drag: 1,
           size: (2, 6),
           scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),
           colorOverLife: ColorRamp([from, to]),
         ),
         renderer: CircleParticleRenderer(),
         emitting: false,
         removeOnFinish: false,
         worldSpace: true,
       ),
       super(
         camera: CameraComponent.withFixedResolution(
           width: 400,
           height: 600,
         )..viewfinder.zoom = zoom,
       );

  final ParticleEmitterComponent _emitter;

  @override
  Future<void> onLoad() async {
    add(_emitter);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _emitter.position = info.eventPosition.widget;
    _emitter.emit(20);
  }
}
