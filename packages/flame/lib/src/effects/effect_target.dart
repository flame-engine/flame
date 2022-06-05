import 'package:flame/src/effects/effect.dart';

/// Mixin adds field [target] of type [T] to an [Effect]. The target can be
/// either set explicitly by the effect class, or acquired automatically from
/// the effect's parent when mounting.
///
/// The type [T] can be either a Component subclass, or one of the property
/// providers defined in "provider_interfaces.dart".
mixin EffectTarget<T> on Effect {
  T get target => _target!;
  T? _target;
  set target(T? value) {
    _target = value;
  }

  @override
  void onMount() {
    if (_target == null) {
      final parent = ancestors().firstWhere((c) => c is! Effect);
      if (parent is! T) {
        throw UnsupportedError('Can only apply this effect to $T');
      }
      _target = parent as T;
    }
  }
}
