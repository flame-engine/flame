import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/particles/particle.dart';

/// Base container for [Particle] instances to be attach
/// to a [Component] tree. Could be added either to FlameGame
/// or an implementation of [Component].
/// Proxies [Component] lifecycle hooks to nested [Particle].
@Deprecated('Will be removed after v1.1, use ParticleSystemComponent instead')
class ParticleComponent extends Component {
  Particle particle;

  ParticleComponent(this.particle);

  /// Returns progress of the child [Particle].
  ///
  /// Could be used by external code if needed.
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
    if (particle.shouldRemove) {
      removeFromParent();
    }
  }
}
