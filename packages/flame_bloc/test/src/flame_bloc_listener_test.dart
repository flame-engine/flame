import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../player_cubit.dart';

void main() {
  group('FlameBlocListener', () {
    testWithFlameGame(
      'onNewsState is called when state changes',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        final states = <PlayerState>[];
        await game.ensureAdd(provider);

        final component = FlameBlocListener<PlayerCubit, PlayerState>(
          onNewState: states.add,
        );
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

        final component = FlameBlocListener<PlayerCubit, PlayerState>(
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
