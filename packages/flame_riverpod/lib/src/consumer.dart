import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/src/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentRef implements WidgetRef {
  ComponentRef({required this.game});

  RiverpodGameMixin? game;

  @override
  BuildContext get context => game!.buildContext!;

  RiverpodAwareGameWidgetState? get _container {
    return game?.widgetKey?.currentState;
  }

  @override
  Res watch<Res>(ProviderListenable<Res> target) {
    return _container!.watch(target);
  }

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    _container!.listen(provider, listener, onError: onError);
  }

  @override
  bool exists(ProviderBase<Object?> provider) {
    return _container!.exists(provider);
  }

  @override
  T read<T>(ProviderListenable<T> provider) {
    return _container!.read(provider);
  }

  @override
  T refresh<T>(Refreshable<T> provider) {
    return _container!.refresh(provider);
  }

  @override
  void invalidate(ProviderOrFamily provider) {
    _container!.invalidate(provider);
  }

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return _container!.listenManual(
      provider,
      listener,
      onError: onError,
      fireImmediately: fireImmediately,
    );
  }
}

mixin RiverpodComponentMixin on Component {
  final ComponentRef ref = ComponentRef(game: null);
  final List<Function()> _onBuildCallbacks = [];

  /// Whether to immediately call [RiverpodAwareGameWidgetState.build] when
  /// this component is mounted.
  bool rebuildOnMountWhen(ComponentRef ref) => true;

  /// Whether to immediately call [RiverpodAwareGameWidgetState.build] when
  /// this component is removed.
  bool rebuildOnRemoveWhen(ComponentRef ref) => true;

  /// Adds a callback method to be invoked in the build method of
  /// [RiverpodAwareGameWidgetState].
  void addToGameWidgetBuild(Function() cb) {
    _onBuildCallbacks.add(cb);
  }

  @mustCallSuper
  @override
  void onMount() {
    super.onMount();
    ref.game = findGame()! as RiverpodGameMixin;
    ref.game!._onBuildCallbacks.addAll(_onBuildCallbacks);

    if (rebuildOnMountWhen(ref) == true) {
      rebuildGameWidget();
    }
  }

  @mustCallSuper
  @override
  void onRemove() {
    // Remove this component's onBuild callbacks from the GameWidget
    _onBuildCallbacks.forEach(ref.game!._onBuildCallbacks.remove);

    // Clear the local store of build callbacks - if the component is
    // re-mounted, it would be undesirable to double-up.
    _onBuildCallbacks.clear();

    // Force build to flush dependencies
    if (rebuildOnRemoveWhen(ref) == true) {
      rebuildGameWidget();
    }

    // Clear game reference as the component is no longer mounted to this game
    ref.game = null;

    super.onRemove();
  }

  void rebuildGameWidget() {
    assert(ref.game!.isMounted == true);
    if (ref.game!.isMounted) {
      ref.game!.widgetKey!.currentState!.forceBuild();
    }
  }
}

mixin RiverpodGameMixin<W extends World> on FlameGame<W> {
  /// [GlobalKey] associated with the [RiverpodAwareGameWidget] that this game
  /// was provided to.
  ///
  /// Used to facilitate [Component] access to the [ProviderContainer].
  GlobalKey<RiverpodAwareGameWidgetState>? widgetKey;

  final ComponentRef ref = ComponentRef(game: null);
  final List<void Function()> _onBuildCallbacks = [];

  /// Adds a callback method to be invoked in the build method of
  /// [RiverpodAwareGameWidgetState].
  void addToGameWidgetBuild(Function() cb) {
    _onBuildCallbacks.add(cb);
  }

  @override
  void onMount() {
    super.onMount();
    mounted.whenComplete(() {
      widgetKey!.currentState!.forceBuild();
    });
  }

  @mustCallSuper
  @override
  FutureOr<void> onLoad() {
    ref.game = this;
    return super.onLoad();
  }

  /// Invoked in [RiverpodAwareGameWidgetState.build]. Each callback is
  /// expected to consist of calls to methods implemented in [WidgetRef].
  /// E.g. [WidgetRef.watch], [WidgetRef.listen], etc.
  void onBuild() {
    for (final callback in _onBuildCallbacks) {
      callback.call();
    }
  }

  bool get hasBuildCallbacks => _onBuildCallbacks.isNotEmpty;
}
