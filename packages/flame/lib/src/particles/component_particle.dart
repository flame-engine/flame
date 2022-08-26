import 'dart:ui';

import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';

class ComponentParticle extends Particle {
  final Component component;
  final Vector2? size;
  final Paint? overridePaint;

  ComponentParticle({
    required this.component,
    this.size,
    this.overridePaint,
    super.lifespan,
  });

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
