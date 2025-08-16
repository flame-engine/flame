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
    required void Function(S state) onNewState,
    void Function(S state)? onInitialState,
    B? bloc,
    bool Function(S previousState, S newState)? listenWhen,
    super.key,
  }) : _onNewState = onNewState,
       _onInitialState = onInitialState,
       _listenWhen = listenWhen {
    if (bloc != null) {
      this.bloc = bloc;
    }
  }

  final void Function(S state) _onNewState;
  final void Function(S state)? _onInitialState;
  final bool Function(S previousState, S newState)? _listenWhen;

  @override
  void onNewState(S state) => _onNewState(state);

  @override
  void onInitialState(S state) => _onInitialState?.call(state);

  @override
  bool listenWhen(S previousState, S newState) {
    return _listenWhen?.call(previousState, newState) ?? true;
  }
}
