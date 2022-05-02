import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';
import '../player_cubit.dart';

class PlayerListener extends Component
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  PlayerState? last;
  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);

    last = state;
  }
}

class SadPlayerListener extends Component
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  PlayerState? last;

  @override
  bool listenWhen(PlayerState previousState, PlayerState newState) {
    return newState == PlayerState.sad;
  }

  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);

    last = state;
  }
}

void main() {
  group('FlameBlocListenable', () {
    testWithFlameGame(
      'throws assertion error when the bloc is not provided',
      (game) async {
        final bloc = InventoryCubit();
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerListener();
        expect(() => provider.ensureAdd(component), throwsAssertionError);
      },
    );

    testWithFlameGame(
      'throws assertion error when the bloc set multiple times',
      (game) async {
        final bloc = PlayerCubit();
        final component = PlayerListener()..bloc = bloc;
        expect(() => component.bloc = bloc, throwsAssertionError);
      },
    );

    testWithFlameGame(
      'closes the subscription when it is removed',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerListener();
        await provider.ensureAdd(component);

        component.removeFromParent();
        await game.ready();

        bloc.makeSad();
        await Future.microtask(() {});
        expect(component.last, isNull);
      },
    );

    testWithFlameGame(
      'listen only listenWhen returns true',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = SadPlayerListener();
        await provider.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(component.last, isNull);
      },
    );
  });
}
