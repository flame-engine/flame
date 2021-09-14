import 'package:meta/meta.dart';

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
  void onRemove() {}
}
