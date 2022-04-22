import 'package:vector_math/vector_math_64.dart';

import '../anchor.dart';
import 'anchor_effect.dart';
import 'controllers/effect_controller.dart';
import 'provider_interfaces.dart';

/// An effect that moves the target's anchor to the specified value.
///
/// The anchor will move in a straight line from the anchor's value at the start
/// of the effect towards the provided target. The timing of the move is
/// governed by the [controller].
class AnchorToEffect extends AnchorEffect {
  AnchorToEffect(
    Anchor destination,
    EffectController controller, {
    AnchorProvider? target,
  })  : _destination = destination,
        super(controller, target);

  final Anchor _destination;
  late Vector2 _offset;

  @override
  void onStart() {
    _offset = _destination.toVector2() - target.anchor.toVector2();
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.anchor = Anchor(
      target.anchor.x + _offset.x * dProgress,
      target.anchor.y + _offset.y * dProgress,
    );
  }

  @override
  double measure() => _offset.length;
}
