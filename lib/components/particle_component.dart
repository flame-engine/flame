import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle.dart';
import 'component.dart';

/// Base container for [Particle] instances to be attach
/// to a [Component] tree. Could be added either to [BaseGame]
/// or [ComposedComponent] as needed.
/// Proxies [Component] lifecycle hooks to nested [Particle].
class ParticleComponent extends Component {
  Particle particle;

  ParticleComponent({
    @required this.particle,
  });

  /// This [Component] will be automatically destroyed
  /// as soon as
  @override
  bool destroy() => particle.destroy();

  /// Returns progress of the child [Particle]
  /// so could be used by external code for something
  double get progress => particle.progress;

  /// Passes rendering chain down to the inset
  /// [Particle] within this [Component].
  @override
  void render(Canvas canvas) {
    particle.render(canvas);
  }

  /// Passes update chain to child [Particle].
  @override
  void update(double dt) {
    particle.update(dt);
  }
}
