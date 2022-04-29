import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../flame_bloc.dart';

/// {@template flame_bloc_listener_component}
/// A [Component] which exposes the ability to listen to changes in a [Bloc] state.
/// {@endtemplate}
class FlameBlocListenerComponent<B extends BlocBase<S>, S> extends Component
    with FlameBlocListener<B, S> {
  /// {@macro flame_bloc_listener_component}
  FlameBlocListenerComponent({
    required void Function(S state) onNewState,
    bool Function(S? previousState, S newState)? listenWhen,
  })  : _onNewState = onNewState,
        _listenWhen = listenWhen;

  final void Function(S state) _onNewState;
  final bool Function(S? previousState, S newState)? _listenWhen;

  @override
  void onNewState(S state) => _onNewState(state);

  @override
  bool listenWhen(S? previousState, S newState) {
    return _listenWhen?.call(previousState, newState) ?? true;
  }
}

/// Adds [Bloc] access and listening to a [Component]
mixin FlameBlocListener<B extends BlocBase<S>, S> on Component {
  late S _state;
  late B _bloc;
  @visibleForTesting
  late StreamSubscription<S> subscription;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    final providers = ancestors().whereType<FlameBlocProvider<B, S>>();
    assert(
      providers.isNotEmpty,
      'No FlameBlocProvider<$B, $S> available on the component tree',
    );

    final provider = providers.first;
    _bloc = provider.bloc;
    _state = _bloc.state;

    subscription = _bloc.stream.listen((newState) {
      if (_state != newState) {
        final _callNewState = listenWhen(_state, newState);
        _state = newState;

        if (_callNewState) {
          onNewState(newState);
        }
      }
    });
  }

  /// Override this to make [onNewState] be called only when
  /// a certain state change happens.
  ///
  /// Default implementation returns true.
  bool listenWhen(S? previousState, S newState) => true;

  /// Listener called everytime a new state is emitted to this component.
  ///
  /// Default implementation is a no-op.
  void onNewState(S state) {}

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    subscription.cancel();
  }
}
