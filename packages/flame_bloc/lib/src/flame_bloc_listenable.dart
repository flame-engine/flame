import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../flame_bloc.dart';

/// Adds [Bloc] access and listening to a [Component]
mixin FlameBlocListenable<B extends BlocBase<S>, S> on Component {
  late S _state;
  late B _bloc;
  late StreamSubscription<S> _subscription;

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

    _subscription = _bloc.stream.listen((newState) {
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
  bool listenWhen(S previousState, S newState) => true;

  /// Listener called everytime a new state is emitted to this component.
  ///
  /// Default implementation is a no-op.
  void onNewState(S state) {}

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    _subscription.cancel();
  }
}
