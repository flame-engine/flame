import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:meta/meta.dart';

/// Adds [Bloc] access and listening to a [Component]
mixin FlameBlocListenable<B extends BlocBase<S>, S> on Component {
  late S _state;
  late StreamSubscription<S> _subscription;
  late B _bloc;
  B? _blocOverride;

  /// Returns the bloc that this component is reading from once the component
  /// has been mounted.
  B get bloc {
    assert(
      isMounted,
      'Cannot access the bloc instance before it has been mounted.',
    );
    return _bloc;
  }

  /// Explicitly set the bloc instance which the component will be listening to.
  /// This is useful in cases where the bloc being listened to
  /// has not be provided via [FlameBlocProvider].
  set bloc(B bloc) {
    assert(
      _blocOverride == null,
      'Cannot update the bloc instance once it has been set.',
    );
    _blocOverride = bloc;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    var bloc = _blocOverride;
    if (bloc == null) {
      final providers = ancestors().whereType<FlameBlocProvider<B, S>>();
      assert(
        providers.isNotEmpty,
        'No FlameBlocProvider<$B, $S> available on the component tree',
      );

      final provider = providers.first;
      _blocOverride = bloc = provider.bloc;
    }
    _bloc = bloc;
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

  /// Listener called every time a new state is emitted to this component.
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
