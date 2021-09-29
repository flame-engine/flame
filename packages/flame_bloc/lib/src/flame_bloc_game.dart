import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

mixin BlocComponent<B extends BlocBase<S>, S> on Component {
  StreamSubscription<S>? _subscription;

  S? _state;
  S? get state => _state;

  void _subscribe(FlameBlocGame game) {
    _subscription = game.read<B>().stream.listen((newState) {
      if (isMounted) {
        _state = newState;

        onNewState(newState);
      // if we are not on the tree anymore, we can clean our subscription
      } else {
        _unsubscribe();
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Listener called everytime a new state is emitted to this component
  /// default implementation is a no-op
  void onNewState(S s) {}
}

/// {@template flame_bloc_game}
/// An enhanced [FlameGame] that has the capability to listen
/// and emit changes to a [Bloc] state
///
/// {@endtemplate}
class FlameBlocGame extends FlameGame {

  final List<BlocComponent> _subscriptionQueue = [];

  @override
  @mustCallSuper
  void onAttach() {
    _runSubscriptionQueue();
  }


  @override
  @mustCallSuper
  void onDetach() {

    _unsubscribe();
  }

  T read<T extends BlocBase>() {
    final context = buildContext;
    if (context == null) {
      throw Exception('build context is not available yet');
    }

    return context.read<T>();
  }

  @override
  @mustCallSuper
  void prepareComponent(Component c) {
    super.prepareComponent(c);

    if (c is BlocComponent) {
      if (isAttached) {
        c._subscribe(this);
      } else {
        _subscriptionQueue.add(c);
      }
    }
  }

  void _runSubscriptionQueue() {
    while (_subscriptionQueue.isNotEmpty) {
      final component = _subscriptionQueue.removeAt(0);
      component._subscribe(this);
    }
  }

  void _unsubscribe() {
    children.whereType<BlocComponent>().forEach((element) {
      element._unsubscribe();
    });
  }
}
