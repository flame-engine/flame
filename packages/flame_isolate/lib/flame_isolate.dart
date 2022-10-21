import 'package:flame/components.dart';
import 'package:integral_isolates/integral_isolates.dart';

export 'package:integral_isolates/integral_isolates.dart';

/// Mixin on [Component] that holds an instance of a long running isolate using
/// the library integral_isolates.
///
/// Using isolate is done by just running [isolate] function the same way you
/// would run Flutter's compute function.
///
/// Keep in mind that every component you create and add with this mixin to the
/// game will create and hold it's own isolate. This makes it easy to
/// accidentally create a lot of isolates if attached to every instance of an
/// NPC for example. What you´probably want to do is to instead create a manager
/// component that does all the calculations and controls the NPCs.
///
/// The following is an example of running a world update cycle when enough time
/// has passed.
///
/// ```dart
/// class MyGame extends FlameGame with FlameIsolate {
///   @override
///   void update(double dt) {
///     if (shouldRecalculate) {
///       isolate(recalculateWorld, worldData).then(updateWorld);
///     }
///     return super.update(dt);
///   }
/// }
/// ```
mixin FlameIsolate on Component implements IsolateGetter {
  Isolated? _isolate;

  /// The backpressureStrategy to use.
  ///
  /// Override this to change strategy.
  BackpressureStrategy get backpressureStrategy => NoBackPressureStrategy();

  @override
  Future onMount() async {
    _isolate = Isolated(backpressureStrategy: backpressureStrategy);
    _isolate?.init();
    return super.onMount();
  }

  @override
  void onRemove() {
    _isolate?.dispose();
    _isolate = null;
  }

  @override
  Future<R> isolate<Q, R>(
    IsolateCallback<Q, R> callback,
    Q message, {
    String? debugLabel,
  }) {
    return _isolate!.isolate(callback, message, debugLabel: debugLabel);
  }
}
