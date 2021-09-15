import 'package:meta/meta.dart';

import '../../../game.dart';

/// From an end-user perspective this mixin is usually used together with [Game]
/// to create a game class which is more low-level than the [FlameGame].
///
/// What it provides in practice is a cache for [onLoad], so that a
/// component/class can be certain that [onLoad] only runs once which then gives
/// the possibility to do late initializations in [onLoad].
///
/// It also provides empty implementations of [onMount] and [onRemove] which are
/// called when the implementing class/component is added or removed from a
/// parent/widget, in that respective order.
mixin Loadable {
  /// This receives the new bounding size from its parent, which could be for
  /// example a [GameWidget] or a `Component`.
  void onGameResize(Vector2 size) {}

  /// Whenever [onLoad] returns something, the parent will wait for the [Future]
  /// to be resolved before adding it.
  /// If `null` is returned, the class is added right away.
  ///
  /// The default implementation just returns null.
  ///
  /// This can be overwritten to add custom logic to the component loading.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   myImage = await gameRef.load('my_image.png');
  /// }
  /// ```
  Future<void>? onLoad() => null;

  Future<void>? _onLoadCache;

  /// Since [onLoad] only should run once throughout a the lifetime of the
  /// implementing class, it is cached so that it can be reused when the parent
  /// component/game/widget changes.
  @internal
  Future<void>? get onLoadCache => _onLoadCache ?? (_onLoadCache = onLoad());

  /// Called after the component has successfully run [onLoad] and before the
  /// component is added to its new parent.
  ///
  /// Whenever [onMount] returns something, the parent will wait for the
  /// [Future] to be resolved before adding it.
  /// If `null` is returned, the class is added right away.
  ///
  /// This can be overwritten to add custom logic to the component's mounting.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onMount() {
  ///   position = parent!.size / 2;
  /// }
  /// ```
  void onMount() {}

  /// Called when the class is removed from its parent.
  /// The parent could be for example a [GameWidget] or a `Component`.
  void onRemove() {}
}
