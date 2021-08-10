import 'package:flame/particles.dart';
import 'package:oxygen/oxygen.dart';

export 'package:flame/particles.dart' show Particle;

class ParticleComponent extends Component<Particle> {
  Particle? particle;

  /// Returns progress of the [particle].
  double? get progress => particle?.progress;

  @override
  void init([Particle? data]) => particle = data;

  @override
  void reset() => particle = null;
}
