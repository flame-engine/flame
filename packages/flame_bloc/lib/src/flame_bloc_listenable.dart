import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:meta/meta.dart';

/// Adds [Bloc] access and listening to a [Component]
mixin FlameBlocListenable<B extends BlocBase<S>, S> on Component {
  late S _state;
  late final StreamSubscription<S> _subscription;
  B? _bloc;

  /// Explicitly set the bloc instance which the component will be listening to.
  /// This is useful in cases where the bloc being listened to
  /// has not be provided via [FlameBlocProvider].
  set bloc(B bloc) {
    assert(
      _bloc == null,
      'Cannot update the bloc instance once it has been set.',
    );
    _bloc = bloc;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    var bloc = _bloc;
    if (bloc == null) {
      final providers = ancestors().whereType<FlameBlocProvider<B, S>>();
      assert(
        providers.isNotEmpty,
        'No FlameBlocProvider<$B, $S> available on the component tree',
      );

      final provider = providers.first;
      _bloc = bloc = provider.bloc;
    }
    _state = bloc.state;
    _subscription = bloc.stream.listen((newState) {
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
