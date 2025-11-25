import 'package:flame/src/effects/effect.dart';
import 'package:flame/src/effects/effect_target.dart';

/// The `FunctionEffect` class is a very generic Effect that allows you to
/// do almost anything without having to define a new effect.
///
/// It runs a function that takes the target and the progress of the effect and
/// then the user can decide what to do with that input.
///
/// This could for example be used to make game state changes that happen over
/// time, but that isn't necessarily visual, like most other effects are.
class FunctionEffect<T> extends Effect with EffectTarget<T> {
  FunctionEffect(
    this.function,
    super.controller, {
    super.onComplete,
    super.key,
  });

  void Function(T target, double progress) function;

  @override
  void apply(double progress) {
    function(target, progress);
  }
}
