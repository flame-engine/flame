import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../components/component.dart';
import '../particle.dart';
import '../position.dart';

class ComponentParticle extends Particle {
  final Component component;
  final Position size;
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
