import 'package:meta/meta.dart';

mixin Loadable {
  /// Called after the component has successfully run [prepare] and it is called
  /// before the component is added to a parent for the first time.
  ///
  /// Whenever [onLoad] returns something, the parent will wait for the [Future]
  /// to be resolved before adding the component on the list.
  /// If `null` is returned, the component is added right away.
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

  /// Since [onLoad] only should run once throughout a components lifetime it is
  /// cached so that it can be reused when the parent component/game/widget
  /// changes.
  @internal
  Future<void>? get onLoadCache => _onLoadCache ?? (_onLoadCache = onLoad());

  /// Called after the component has successfully run [prepare] and [onLoad] and
  /// before the component is added to its new parent.
  ///
  /// Whenever [onMount] returns something, the parent will wait for the
  /// [Future] to be resolved before adding the component on the list.
  /// If `null` is returned, the component is added right away.
  ///
  /// This can be overwritten this to add custom logic to the component loading.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onMount() {
  ///   position = parent!.size / 2;
  /// }
  /// ```
  void onMount() {}

  void onRemove() {}
}
