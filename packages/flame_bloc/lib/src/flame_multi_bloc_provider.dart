import 'package:flame/components.dart';

import 'package:flame_bloc/flame_bloc.dart';

/// {@template flame_multi_bloc_provider}
/// Similar to [FlameBlocProvider], but provides multiples blocs down
/// to the component tree
/// {@endtemplate}
class FlameMultiBlocProvider({
  required final List<FlameBlocProvider> _providers,
  List<Component>? children,
  super.key,
}) extends Component {
  /// {@macro flame_multi_bloc_provider}
  this : assert(_providers.isNotEmpty, 'At least one provider must be given') {
    _addProviders();
  }

  final List<Component>? _initialChildren = children;
  FlameBlocProvider? _lastProvider;

  void _addProviders() {
    final list = [..._providers];

    var current = list.removeAt(0);
    while (list.isNotEmpty) {
      final provider = list.removeAt(0);
      current.add(provider);
      current = provider;
    }

    add(_providers.first);
    _lastProvider = current;

    _initialChildren?.forEach(add);
  }

  @override
  void add(Component component) {
    if (_lastProvider == null) {
      super.add(component);
    }
    _lastProvider?.add(component);
  }

  @override
  void remove(Component component) {
    if (_lastProvider == null) {
      super.remove(component);
    }
    _lastProvider?.remove(component);
  }
}
