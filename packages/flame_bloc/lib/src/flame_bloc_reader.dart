import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';

/// Adds [Bloc] access to a [Component].
///
/// Useful for components that needs to only read
/// a bloc current state or to trigger an event on it
mixin FlameBlocReader<B extends BlocBase<S>, S> on Component {
  late B _bloc;

  /// Returns the bloc that this component is reading from
  B get bloc => _bloc;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    final providers = ancestors().whereType<FlameBlocProvider<B, S>>();
    assert(
      providers.isNotEmpty,
      'No FlameBlocProvider<$B, $S> available on the component tree',
    );

    final provider = providers.first;
    _bloc = provider.bloc;
  }
}
