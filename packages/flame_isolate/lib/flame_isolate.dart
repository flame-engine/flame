import 'package:flame/components.dart';
import 'package:integral_isolates/integral_isolates.dart';

export 'package:integral_isolates/integral_isolates.dart';

/// Mixin on [Component] that holds an instance of a long running isolate using
/// the library integral_isolates.
///
/// Using the isolate is done by just running [isolateCompute] function the same
/// way you would run Flutter's compute function or [isolateComputeStream] if
/// your work returns a [Stream].
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
///       compute(recalculateWorld, worldData).then(updateWorld);
///     }
///     return super.update(dt);
///   }
/// }
/// ```
mixin FlameIsolate on Component {
  StatefulIsolate? _isolate;

  /// The backpressureStrategy to use.
  ///
  /// Override this to change strategy.
  BackpressureStrategy get backpressureStrategy => NoBackPressureStrategy();

  @override
  Future<void> onMount() async {
    _isolate = StatefulIsolate(backpressureStrategy: backpressureStrategy);
    _isolate?.init();
    return super.onMount();
  }

  @override
  void onRemove() {
    _isolate?.dispose();
    _isolate = null;
  }

  /// Deprecated in favor of [isolateCompute].
  @Deprecated(
    'Will be removed in flame_isolate 0.7.0. Use isolateCompute instead.',
  )
  Future<R> isolate<Q, R>(
    IsolateCallback<Q, R> callback,
    Q message, {
    String? debugLabel,
  }) {
    return isolateCompute(callback, message, debugLabel: debugLabel);
  }

  /// A function that runs the provided [callback] on the long running isolate
  /// and (eventually) returns the value returned.
  ///
  /// Same footprint as the function compute from flutter, but runs on the
  /// long running thread.
  Future<R> isolateCompute<Q, R>(
    IsolateCallback<Q, R> callback,
    Q message, {
    String? debugLabel,
  }) {
    return _isolate!.compute(callback, message, debugLabel: debugLabel);
  }

  /// A computation function that returns a [Stream] of responses from the
  /// long lived isolate.
  ///
  /// Very similar to the [isolateCompute] function, but instead of returning a
  /// [Future], a [Stream] is returned to allow for a response in multiple
  /// parts. Every stream event will be sent individually through from the
  /// isolate.
  Stream<R> isolateComputeStream<Q, R>(
    IsolateStream<Q, R> callback,
    Q message, {
    String? debugLabel,
  }) {
    return _isolate!.computeStream(callback, message, debugLabel: debugLabel);
  }
}
