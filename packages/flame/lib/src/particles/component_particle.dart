import 'dart:ui';

import '../components/component.dart';
import '../extensions/vector2.dart';
import 'particle.dart';

class ComponentParticle extends Particle {
  final Component component;
  final Vector2? size;
  final Paint? overridePaint;

  ComponentParticle({
    required this.component,
    this.size,
    this.overridePaint,
    double? lifespan,
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
