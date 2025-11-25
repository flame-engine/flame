import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';
import '../player_cubit.dart';

class _InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

class _InventoryListener extends Component
    with FlameBlocListenable<InventoryCubit, InventoryState> {
  InventoryState? lastState;

  @override
  void onNewState(InventoryState state) {
    lastState = state;
  }
}

class _PlayerReader extends Component
    with FlameBlocReader<PlayerCubit, PlayerState> {}

class _PlayerListener extends Component
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  PlayerState? lastState;

  @override
  void onNewState(PlayerState state) {
    lastState = state;
  }
}

void main() {
  group('FlameMultiBlocProvider', () {
    testWithFlameGame('Provides multiple blocs down on the tree', (game) async {
      final inventoryCubit = InventoryCubit();
      final playerCubit = PlayerCubit();

      final provider = FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<InventoryCubit, InventoryState>.value(
            value: inventoryCubit,
          ),
          FlameBlocProvider<PlayerCubit, PlayerState>.value(
            value: playerCubit,
          ),
        ],
      );
      await game.ensureAdd(provider);

      final inventory = _InventoryReader();
      final player = _PlayerReader();

      await provider.ensureAdd(inventory);
      await provider.ensureAdd(player);

      expect(inventory.bloc, equals(inventoryCubit));
      expect(player.bloc, equals(playerCubit));
    });

    testWithFlameGame('can listen to new state changes', (game) async {
      final inventoryCubit = InventoryCubit();
      final playerCubit = PlayerCubit();

      final provider = FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<InventoryCubit, InventoryState>.value(
            value: inventoryCubit,
          ),
          FlameBlocProvider<PlayerCubit, PlayerState>.value(
            value: playerCubit,
          ),
        ],
      );
      await game.ensureAdd(provider);

      final inventory = _InventoryListener();
      final player = _PlayerListener();

      await provider.ensureAdd(inventory);
      await provider.ensureAdd(player);

      playerCubit.makeSad();
      inventoryCubit.selectBow();
      await Future<void>.microtask(() {});

      expect(player.lastState, equals(PlayerState.sad));
      expect(inventory.lastState, equals(InventoryState.bow));
    });

    testWithFlameGame('Add and remove a child with two providers', (
      game,
    ) async {
      final inventoryCubit = InventoryCubit();
      final playerCubit = PlayerCubit();

      late FlameBlocProvider inventoryCubitProvider;
      late FlameBlocProvider playerCubitProvider;

      final provider = FlameMultiBlocProvider(
        providers: [
          inventoryCubitProvider =
              FlameBlocProvider<InventoryCubit, InventoryState>.value(
                value: inventoryCubit,
              ),
          playerCubitProvider =
              FlameBlocProvider<PlayerCubit, PlayerState>.value(
                value: playerCubit,
              ),
        ],
      );
      await game.ensureAdd(provider);

      final myTestComponent = PositionComponent(position: Vector2.all(10));

      await provider.ensureAdd(myTestComponent);
      expect(inventoryCubitProvider.children.length, 1);
      expect(inventoryCubitProvider.firstChild(), playerCubitProvider);
      expect(myTestComponent.parent, equals(playerCubitProvider));
      expect(playerCubitProvider.firstChild(), equals(myTestComponent));
      await provider.ensureRemove(myTestComponent);
      expect(myTestComponent.parent, null);
      expect(playerCubitProvider.children.length, 0);
    });

    group('when using children on constructor', () {
      testWithFlameGame('Provides multiple blocs down on the tree', (
        game,
      ) async {
        final inventoryCubit = InventoryCubit();
        final playerCubit = PlayerCubit();

        late _InventoryReader inventory;
        late _PlayerReader player;

        final provider = FlameMultiBlocProvider(
          providers: [
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
              value: inventoryCubit,
            ),
            FlameBlocProvider<PlayerCubit, PlayerState>.value(
              value: playerCubit,
            ),
          ],
          children: [
            inventory = _InventoryReader(),
            player = _PlayerReader(),
          ],
        );
        await game.ensureAdd(provider);

        expect(inventory.bloc, equals(inventoryCubit));
        expect(player.bloc, equals(playerCubit));
      });

      testWithFlameGame('can listen to new state changes', (game) async {
        final inventoryCubit = InventoryCubit();
        final playerCubit = PlayerCubit();

        late _InventoryListener inventory;
        late _PlayerListener player;

        final provider = FlameMultiBlocProvider(
          providers: [
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
              value: inventoryCubit,
            ),
            FlameBlocProvider<PlayerCubit, PlayerState>.value(
              value: playerCubit,
            ),
          ],
          children: [
            inventory = _InventoryListener(),
            player = _PlayerListener(),
          ],
        );
        await game.ensureAdd(provider);

        playerCubit.makeSad();
        inventoryCubit.selectBow();
        await Future<void>.microtask(() {});

        expect(player.lastState, equals(PlayerState.sad));
        expect(inventory.lastState, equals(InventoryState.bow));
      });

      testWithFlameGame(
        'can listen to multiple subsequent state changes',
        (game) async {
          final playerCubit = PlayerCubit();
          late _PlayerListener player;

          final provider = FlameMultiBlocProvider(
            providers: [
              FlameBlocProvider<PlayerCubit, PlayerState>.value(
                value: playerCubit,
              ),
            ],
            children: [
              player = _PlayerListener(),
            ],
          );
          await game.ensureAdd(provider);

          playerCubit.kill();
          await Future<void>.microtask(() {});
          expect(player.lastState, equals(PlayerState.dead));

          playerCubit.riseFromTheDead();
          await Future<void>.microtask(() {});
          expect(player.lastState, equals(PlayerState.alive));
        },
      );
    });
  });
}
