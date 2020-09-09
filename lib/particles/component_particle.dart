import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import '../particle.dart';
import '../components/component.dart';

class ComponentParticle extends Particle {
  final Component component;
  final Vector2 size;
  final Paint overridePaint;

  ComponentParticle({
    @required this.component,
    this.size,
    this.overridePaint,
    double lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    component.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    component.update(dt);
  }
}
