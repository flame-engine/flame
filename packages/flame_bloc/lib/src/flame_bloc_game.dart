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
mixin BlocComponent2<B1 extends BlocBase<S1>, S1, B2 extends BlocBase<S2>, S2>
    on Component {
  StreamSubscription<S1>? _subscription1;
  StreamSubscription<S2>? _subscription2;

  S1? _state1;
  S2? _state2;

  /// The current state of the [Bloc] that this [Component] is listening to.
  /// Flame keeps a copy of the state on the [Component] so this can be directly
  /// accessed in both the [update] and the [render] method.
  S1? get state1 => _state1;
  S2? get state2 => _state2;

  /// Makes this component subscribe to the Bloc changes.
  /// Visible only for test purposes.
  @visibleForTesting
  void subscribe(FlameBlocGame game) {
    final _bloc1 = game.read<B1>();
    final _bloc2 = game.read<B2>();
    _state1 = _bloc1.state;
    _state2 = _bloc2.state;

    _subscription1 = _bloc1.stream.listen((newState) {
      if (_state1 != newState) {
        final _callNewState = listenWhen1(_state1, newState);
        _state1 = newState;

        if (_callNewState) {
          onNewState1(newState);
        }
      }
    });

    _subscription2 = _bloc2.stream.listen((newState) {
      if (_state2 != newState) {
        final _callNewState = listenWhen2(_state2, newState);
        _state2 = newState;

        if (_callNewState) {
          onNewState2(newState);
        }
      }
    });
  }

  /// Makes this component stop listening to the [Bloc] changes.
  /// Visible only for test purposes.
  @visibleForTesting
  void unsubscribe() {
    _subscription1?.cancel();
    _subscription2?.cancel();
    _subscription1 = null;
    _subscription2 = null;
  }

  /// Override this to make [onNewState] be called only when
  /// a certain state change happens.
  ///
  /// Default implementation returns true.
  bool listenWhen1(S1? previousState, S1 newState) => true;
  bool listenWhen2(S2? previousState, S2 newState) => true;

  /// Listener called everytime a new state is emitted to this component.
  ///
  /// Default implementation is a no-op.
  void onNewState1(S1 state) {}
  void onNewState2(S2 state) {}

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
  FlameBlocGame({Camera? camera}) : super(camera: camera);

  @visibleForTesting

  /// Contains a list of all of the [BlocComponent]s with an active
  /// subscription. Only visible for testing.
  final List<BlocComponent> subscriptionQueue = [];
  final List<BlocComponent2> subscriptionQueue2 = [];

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
    if (c is BlocComponent2) {
      if (isAttached) {
        c.subscribe(this);
      } else {
        subscriptionQueue2.add(c);
      }
    }
  }

  void _runSubscriptionQueue() {
    while (subscriptionQueue.isNotEmpty) {
      final component = subscriptionQueue.removeAt(0);
      component.subscribe(this);
    }
    while (subscriptionQueue2.isNotEmpty) {
      final component = subscriptionQueue2.removeAt(0);
      component.subscribe(this);
    }
  }

  void _unsubscribe() {
    children.whereType<BlocComponent>().forEach((element) {
      element.unsubscribe();
    });
    children.whereType<BlocComponent2>().forEach((element) {
      element.unsubscribe();
    });
  }
}
