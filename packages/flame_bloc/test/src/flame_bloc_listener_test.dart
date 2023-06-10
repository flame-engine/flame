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
      'onInitialState is called when the initial state is received',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        final states = <PlayerState>[];
        await game.ensureAdd(provider);

        final component = FlameBlocListener<PlayerCubit, PlayerState>(
          onNewState: (_) {},
          onInitialState: states.add,
        );
        await provider.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(states, equals([PlayerState.alive]));
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

    testWithFlameGame(
      'a bloc can be explicitly passed',
      (game) async {
        final bloc = PlayerCubit();
        final states = <PlayerState>[];
        final component = FlameBlocListener<PlayerCubit, PlayerState>(
          bloc: bloc,
          onNewState: states.add,
        );
        await game.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(states, equals([PlayerState.dead]));
      },
    );
  });
}
