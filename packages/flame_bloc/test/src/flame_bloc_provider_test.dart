import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';

class InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

class InventoryListener extends Component
    with FlameBlocListener<InventoryCubit, InventoryState> {
  InventoryState? lastState;

  @override
  void onNewState(InventoryState state) {
    lastState = state;
  }
}

void main() {
  group('FlameBlocProvider', () {
    testWithFlameGame('Provides a bloc down on the tree', (game) async {
      final bloc = InventoryCubit();
      final provider = FlameBlocProvider<InventoryCubit, InventoryState>.value(
        value: bloc,
      );
      await game.ensureAdd(provider);

      final component = InventoryReader();
      await provider.ensureAdd(component);

      expect(component.bloc, bloc);
    });

    testWithFlameGame('can listen to new state changes', (game) async {
      final bloc = InventoryCubit();
      final provider = FlameBlocProvider<InventoryCubit, InventoryState>.value(
        value: bloc,
      );
      await game.ensureAdd(provider);

      final component = InventoryListener();
      await provider.ensureAdd(component);

      bloc.selectBow();
      await Future<void>.microtask(() {});
      expect(component.lastState, equals(InventoryState.bow));
    });

    group('when using children constructor argument', () {
      testWithFlameGame('Provides a bloc down on the tree', (game) async {
        final bloc = InventoryCubit();

        late InventoryReader component;
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
          value: bloc,
          children: [
            component = InventoryReader(),
          ],
        );
        await game.ensureAdd(provider);

        expect(component.bloc, bloc);
      });

      testWithFlameGame('can listen to new state changes', (game) async {
        final bloc = InventoryCubit();
        late InventoryListener component;
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
          value: bloc,
          children: [
            component = InventoryListener(),
          ],
        );
        await game.ensureAdd(provider);

        bloc.selectBow();
        await Future<void>.microtask(() {});
        expect(component.lastState, equals(InventoryState.bow));
      });
    });
  });
}
