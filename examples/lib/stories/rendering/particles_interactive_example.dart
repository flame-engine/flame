import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticlesInteractiveExample extends FlameGame with PanDetector {
  static const description = 'An example which shows how '
      'ParticleSystemComponent can be added in runtime '
      'following an event, in this example, the mouse '
      'dragging';

  final random = Random();
  final Tween<double> noise = Tween(begin: -1, end: 1);
  final ColorTween colorTween;

  ParticlesInteractiveExample({
    required Color from,
    required Color to,
    required double zoom,
  })  : colorTween = ColorTween(begin: from, end: to),
        super(
          camera: CameraComponent.withFixedResolution(
            width: 400,
            height: 600,
          )..viewfinder.zoom = zoom,
        );

  @override
  void onPanUpdate(DragUpdateInfo info) {
    add(
      ParticleSystemComponent(
        position: info.eventPosition.widget,
        particle: Particle.generate(
          count: 40,
          generator: (i) {
            return AcceleratedParticle(
              lifespan: 2,
              speed: Vector2(
                    noise.transform(random.nextDouble()),
                    noise.transform(random.nextDouble()),
                  ) *
                  i.toDouble(),
              child: CircleParticle(
                radius: 2,
                paint: Paint()
                  ..color = colorTween.transform(random.nextDouble())!,
              ),
            );
          },
        ),
      ),
    );
  }
}
