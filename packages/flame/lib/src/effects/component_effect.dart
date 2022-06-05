import 'package:flame/components.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// Base class for effects that target a [Component] of type [T].
///
/// A general abstraction for creating effects targeting [Component]s, currently
/// used by `SizeEffect`, `OpacityEffect` and `Transform2DEffect`.
abstract class ComponentEffect<T extends Component> extends Effect {
  ComponentEffect(
    EffectController controller, {
    void Function()? onComplete,
  }) : super(controller, onComplete: onComplete);

  late T target;

  @override
  void onMount() {
    super.onMount();
    assert(parent != null);
    var p = parent;
    while (p is Effect) {
      p = p.parent;
    }
    if (p is T) {
      target = p;
    } else {
      throw UnsupportedError('Can only apply this effect to $T');
    }
  }
}
