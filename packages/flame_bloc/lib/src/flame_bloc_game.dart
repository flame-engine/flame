import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocComponent<B extends BlocBase<S>, S> on Component {
  StreamSubscription<S>? _subscription;

  S? _state;
  S? get state => _state;

  @visibleForTesting
  void subscribe(FlameBlocGame game) {
    final _bloc = game.read<B>();
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

  @visibleForTesting
  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
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
    unsubscribe();
  }
}

/// {@template flame_bloc_game}
/// An enhanced [FlameGame] that has the capability to listen
/// and emit changes to a [Bloc] state.
///
/// {@endtemplate}
class FlameBlocGame extends FlameGame {
  @visibleForTesting
  final List<BlocComponent> subscriptionQueue = [];

  @override
  @mustCallSuper
  void onAttach() {
    _runSubscriptionQueue();
  }

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();

    _unsubscribe();
  }

  T read<T>() {
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
        c.subscribe(this);
      } else {
        subscriptionQueue.add(c);
      }
    }
  }

  void _runSubscriptionQueue() {
    while (subscriptionQueue.isNotEmpty) {
      final component = subscriptionQueue.removeAt(0);
      component.subscribe(this);
    }
  }

  void _unsubscribe() {
    children.whereType<BlocComponent>().forEach((element) {
      element.unsubscribe();
    });
  }
}
