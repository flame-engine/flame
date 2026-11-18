import 'package:flame/effects.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:meta/meta.dart';

/// Base class for effects targeting a [Component3D] of type [T].
///
/// Extends Flame's [ComponentEffect] so all [EffectController]s,
/// [SequenceEffect], `onComplete`, `reset()`, and `removeOnFinish` work
/// natively on 3D components.
abstract class Effect3D<T extends Component3D>(
  super.controller, {
  super.onComplete,
  super.key,
}) extends ComponentEffect<T> {
  /// Marks any enclosing [World3D] as visually dirty when mutating
  /// non-transform per-instance properties such as `color` or `instanceData`.
  @protected
  void markWorldDirty({bool shadows = false}) {
    for (final ancestor in target.ancestors()) {
      if (ancestor is World3D) {
        ancestor.markSceneDirty(shadows: shadows);
        break;
      }
    }
  }
}
