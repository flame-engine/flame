import 'package:meta/meta.dart';

import '../../../game.dart';

/// From an end-user perspective this mixin is usually used together with [Game]
/// to create a game class which is more low-level than the [FlameGame].
///
/// What it provides in practice is a cache for [onLoad], so that a
/// component/class can be certain that [onLoad] only runs once which then gives
/// the possibility to do late initializations in [onLoad].
mixin Loadable {
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
  @mustCallSuper
  Future<void>? onLoad() => null;

  /// Since [onLoad] only should run once throughout a the lifetime of the
  /// implementing class, it is cached so that it can be reused when the parent
  /// component/game/widget changes.
  @internal
  @nonVirtual
  late Future<void>? onLoadCache = onLoad();
}
