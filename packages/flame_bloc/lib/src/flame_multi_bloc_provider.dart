import 'package:flame/components.dart';

import '../flame_bloc.dart';

/// {@template flame_multi_bloc_provider}
/// Similar to [FlameBlocProvider], but provides multiples blocs down
/// tot he component tree
/// {@endtemplate}
class FlameMultiBlocProvider extends Component {
  /// {@macro flame_multi_bloc_provider}
  FlameMultiBlocProvider({
    required List<FlameBlocProvider> providers,
  })  : _providers = providers,
        assert(providers.isNotEmpty, 'At least one provider must be given') {
    _addProviders();
  }

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
  }

  @override
  Future<void> add(Component component) async {
    if (_lastProvider == null) {
      await super.add(component);
    }
    await _lastProvider?.add(component);
  }

  final List<FlameBlocProvider> _providers;
  FlameBlocProvider? _lastProvider;
}
