import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// {@template flame_bloc_provider}
/// A [Component] that provides a [Bloc] to its children
/// {@endtemplate}
class FlameBlocProvider<B extends BlocBase<S>, S> extends Component {
  /// {@macro flame_bloc_provider}
  ///
  /// Will provide the [Bloc] returned by the [create] function,
  /// when this constructor is used, the bloc will only live while
  /// this component is alive.
  FlameBlocProvider({
    required B Function() create,
    List<Component>? children,
  })  : _bloc = create(),
        _created = true {
    _addChildren(children);
  }

  /// {@macro flame_bloc_provider}
  ///
  /// Will provide the given [value] to its children,
  /// when this constructor is used, the user is responsable for
  /// disposing the bloc.
  FlameBlocProvider.value({
    required B value,
    List<Component>? children,
  })  : _bloc = value,
        _created = false {
    _addChildren(children);
  }

  final B _bloc;
  final bool _created;

  void _addChildren(List<Component>? children) {
    if (children != null) {
      children.forEach(add);
    }
  }

  /// Return the [Bloc] provided by this [FlameBlocProvider]
  B get bloc => _bloc;

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();

    if (_created) {
      _bloc.close();
    }
  }
}
