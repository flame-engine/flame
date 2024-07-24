import 'package:flame/effects.dart';
import 'package:meta/meta.dart';

/// This mixin must be used with [EffectController]s that wrap a single child
/// effect controller of type [T].
mixin HasSingleChildEffectController<T extends EffectController>
    on EffectController {
  /// Returns the wrapped child effect controller.
  T get child;

  @mustCallSuper
  @override
  void setToStart() {
    child.setToStart();
  }

  @mustCallSuper
  @override
  void setToEnd() {
    child.setToEnd();
  }

  @mustCallSuper
  @override
  void onMount(Effect parent) {
    child.onMount(parent);
  }
}
