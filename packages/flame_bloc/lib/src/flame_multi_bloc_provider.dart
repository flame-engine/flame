import 'package:flame/components.dart';

import 'package:flame_bloc/flame_bloc.dart';

/// {@template flame_multi_bloc_provider}
/// Similar to [FlameBlocProvider], but provides multiples blocs down
/// to the component tree
/// {@endtemplate}
class FlameMultiBlocProvider extends Component {
  /// {@macro flame_multi_bloc_provider}
  FlameMultiBlocProvider({
    required List<FlameBlocProvider> providers,
    List<Component>? children,
  })  : _providers = providers,
        _initialChildren = children,
        assert(providers.isNotEmpty, 'At least one provider must be given') {
    _addProviders();
  }

  final List<FlameBlocProvider> _providers;
  final List<Component>? _initialChildren;
  FlameBlocProvider? _lastProvider;

  Future<void> _addProviders() async {
    final _list = [..._providers];

    var current = _list.removeAt(0);
    while (_list.isNotEmpty) {
      final provider = _list.removeAt(0);
      await current.add(provider);
      current = provider;
    }

    await add(_providers.first);
    _lastProvider = current;

    _initialChildren?.forEach(add);
  }

  @override
  Future<void> add(Component component) async {
    if (_lastProvider == null) {
      await super.add(component);
    }
    await _lastProvider?.add(component);
  }
}
