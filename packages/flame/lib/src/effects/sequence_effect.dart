
import 'package:flame/effects.dart';

import 'effect.dart';

class SequenceEffect extends Effect {
  SequenceEffect(this.effects, {
    bool alternate = false,
  }) : super(LinearEffectController(1));

  final List<Effect> effects;

  @override
  void apply(double progress) {}

  @override
  void updateTree(double dt, {bool callOwnUpdate = true}) {

  }
}
