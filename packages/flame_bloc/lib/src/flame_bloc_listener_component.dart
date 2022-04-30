import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';

import '../flame_bloc.dart';

/// {@template flame_bloc_listener_component}
/// A [Component] which exposes the ability to listen to changes in a [Bloc] state.
/// {@endtemplate}
class FlameBlocListenerComponent<B extends BlocBase<S>, S> extends Component
    with FlameBlocListener<B, S> {
  /// {@macro flame_bloc_listener_component}
  FlameBlocListenerComponent({
    required void Function(S state) onNewState,
    bool Function(S previousState, S newState)? listenWhen,
  })  : _onNewState = onNewState,
        _listenWhen = listenWhen;

  final void Function(S state) _onNewState;
  final bool Function(S previousState, S newState)? _listenWhen;

  @override
  void onNewState(S state) => _onNewState(state);

  @override
  bool listenWhen(S previousState, S newState) {
    return _listenWhen?.call(previousState, newState) ?? true;
  }
}
