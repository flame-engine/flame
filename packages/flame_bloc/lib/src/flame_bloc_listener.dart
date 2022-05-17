import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';

import 'package:flame_bloc/flame_bloc.dart';

/// {@template flame_bloc_listener}
/// A [Component] which can listen to changes in a [Bloc] state.
/// {@endtemplate}
class FlameBlocListener<B extends BlocBase<S>, S> extends Component
    with FlameBlocListenable<B, S> {
  /// {@macro flame_bloc_listener}
  FlameBlocListener({
    B? bloc,
    required void Function(S state) onNewState,
    bool Function(S previousState, S newState)? listenWhen,
  })  : _onNewState = onNewState,
        _listenWhen = listenWhen {
    if (bloc != null) {
      this.bloc = bloc;
    }
  }

  final void Function(S state) _onNewState;
  final bool Function(S previousState, S newState)? _listenWhen;

  @override
  void onNewState(S state) => _onNewState(state);

  @override
  bool listenWhen(S previousState, S newState) {
    return _listenWhen?.call(previousState, newState) ?? true;
  }
}
