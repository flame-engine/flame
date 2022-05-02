import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';
import '../player_cubit.dart';

class InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

class InventoryListener extends Component
    with FlameBlocListenable<InventoryCubit, InventoryState> {
  InventoryState? lastState;

  @override
  void onNewState(InventoryState state) {
    lastState = state;
  }
}

class PlayerReader extends Component
    with FlameBlocReader<PlayerCubit, PlayerState> {}

class PlayerListener extends Component
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

      final inventory = InventoryReader();
      final player = PlayerReader();

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

      final inventory = InventoryListener();
      final player = PlayerListener();

      await provider.ensureAdd(inventory);
      await provider.ensureAdd(player);

      playerCubit.makeSad();
      inventoryCubit.selectBow();
      await Future<void>.microtask(() {});

      expect(player.lastState, equals(PlayerState.sad));
      expect(inventory.lastState, equals(InventoryState.bow));
    });

    group('when using children on constructor', () {
      testWithFlameGame('Provides multiple blocs down on the tree',
          (game) async {
        final inventoryCubit = InventoryCubit();
        final playerCubit = PlayerCubit();

        late InventoryReader inventory;
        late PlayerReader player;

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
            inventory = InventoryReader(),
            player = PlayerReader(),
          ],
        );
        await game.ensureAdd(provider);

        expect(inventory.bloc, equals(inventoryCubit));
        expect(player.bloc, equals(playerCubit));
      });

      testWithFlameGame('can listen to new state changes', (game) async {
        final inventoryCubit = InventoryCubit();
        final playerCubit = PlayerCubit();

        late InventoryListener inventory;
        late PlayerListener player;

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
            inventory = InventoryListener(),
            player = PlayerListener(),
          ],
        );
        await game.ensureAdd(provider);

        playerCubit.makeSad();
        inventoryCubit.selectBow();
        await Future<void>.microtask(() {});

        expect(player.lastState, equals(PlayerState.sad));
        expect(inventory.lastState, equals(InventoryState.bow));
      });
    });
  });
}
