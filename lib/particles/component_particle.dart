import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../components/component.dart';
import '../vector2.dart';

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
