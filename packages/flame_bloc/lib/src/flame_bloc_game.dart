import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Adds capabilities for a [Component] to listen and have access
/// to a [Bloc] state.
mixin BlocComponent<B extends BlocBase<S>, S> on Component {
  StreamSubscription<S>? _subscription;

  S? _state;

  /// The current state of the [Bloc] that this [Component] is listening to.
  /// Flame keeps a copy of the state on the [Component] so this can be directly
  /// accessed in both the [update] and the [render] method.
  S? get state => _state;

  /// Makes this component subscribe to the Bloc changes.
  /// Visible only for test purposes.
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

  /// Makes this component stop listening to the [Bloc] changes.
  /// Visible only for test purposes.
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

  /// Contains a list of all of the [BlocComponent]s with an active
  /// subscription. Only visible for testing.
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

  /// Convenience method for obtaining the nearest ancestor provider of type
  /// [T].
  ///
  /// This method will do a lookup in the tree for [T], so avoid calling this
  /// inside the game loop methods like [update] and [render] to avoid
  /// performance issues.
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
