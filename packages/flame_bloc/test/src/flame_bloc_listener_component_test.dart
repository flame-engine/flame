import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../player_cubit.dart';

class TestPlayerListener extends Component {
  TestPlayerListener({
    required void Function(PlayerState state) onNewState,
    bool Function(PlayerState? previous, PlayerState? current)? listenWhen,
  })  : _onNewState = onNewState,
        _listenWhen = listenWhen;

  final void Function(PlayerState state) _onNewState;
  final bool Function(PlayerState previous, PlayerState current)? _listenWhen;

  @override
  Future<void>? onLoad() async {
    add(
      FlameBlocListenerComponent<PlayerCubit, PlayerState>(
        listenWhen: _listenWhen ?? (_, __) => true,
        onNewState: _onNewState,
      ),
    );
  }
}

void main() {
  group('FlameBlocListenerComponent', () {
    testWithFlameGame(
      'onNewsState is called when state changes',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        final states = <PlayerState>[];
        await game.ensureAdd(provider);

        final component = TestPlayerListener(onNewState: states.add);
        await provider.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(states, equals([PlayerState.dead]));
      },
    );

    testWithFlameGame(
      'onNewsState is not called when listenWhen returns false',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        final states = <PlayerState>[];
        await game.ensureAdd(provider);

        final component = TestPlayerListener(
          onNewState: states.add,
          listenWhen: (_, __) => false,
        );
        await provider.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(states, isEmpty);
      },
    );
  });
}
