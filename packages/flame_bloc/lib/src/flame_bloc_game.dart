import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// {@template flame_bloc_game}
/// An enhanced [FlameGame] that has the capability to listen
/// and emit changes to a [Bloc] state
///
/// When [bloc] is omitted, [FlameBlocGame] will try to find it
//  on the context
///
/// {@endtemplate}
class FlameBlocGame<B extends BlocBase<S>, S> extends FlameGame {

  final B? _bloc;
  late B _currentBloc;

  StreamSubscription<S>? _subscription;

  /// {@macro flame_bloc_game}
  FlameBlocGame({
    B? bloc,
  }) : _bloc = bloc;

  @override
  void onAttach() {

    final foundBloc = _bloc ?? buildContext?.read<B>();
    if (foundBloc == null) {
      throw Exception("No bloc received and can't be found on the context");
    }

    _currentBloc = foundBloc;
    _subscribe();
  }


  @override
  @mustCallSuper
  void onDetach() {

    _unsubscribe();
  }

  B get bloc => _currentBloc;

  void _subscribe() {
    _subscription = _currentBloc.stream.listen((state) {
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
