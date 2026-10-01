import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';

import 'package:flame_bloc/flame_bloc.dart';

/// {@template flame_bloc_listener}
/// A [Component] which can listen to changes in a [Bloc] state.
/// {@endtemplate}
class FlameBlocListener<B extends BlocBase<S>, S>({
  required final void Function(S state) _onNewState,
  final void Function(S state)? _onInitialState,
  B? bloc,
  final bool Function(S previousState, S newState)? _listenWhen,
  super.key,
}) extends Component with FlameBlocListenable<B, S> {
  /// {@macro flame_bloc_listener}
  this {
    if (bloc != null) {
      this.bloc = bloc;
    }
  }

  @override
  void onNewState(S state) => _onNewState(state);

  @override
  void onInitialState(S state) => _onInitialState?.call(state);

  @override
  bool listenWhen(S previousState, S newState) {
    return _listenWhen?.call(previousState, newState) ?? true;
  }
}
