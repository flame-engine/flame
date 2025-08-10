import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';

class _InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

class _InventoryListener extends Component
    with FlameBlocListenable<InventoryCubit, InventoryState> {
  InventoryState? lastState;

  @override
  void onNewState(InventoryState state) {
    super.onNewState(state);
    lastState = state;
  }

  @override
  void onInitialState(InventoryState state) {
    super.onInitialState(state);

    lastState ??= state;
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

      final component = _InventoryReader();
      await provider.ensureAdd(component);

      expect(component.bloc, bloc);
    });

    testWithFlameGame('can listen to new state changes', (game) async {
      final bloc = InventoryCubit();
      final provider = FlameBlocProvider<InventoryCubit, InventoryState>.value(
        value: bloc,
      );
      await game.ensureAdd(provider);

      final component = _InventoryListener();
      await provider.ensureAdd(component);

      bloc.selectBow();
      await Future<void>.microtask(() {});
      expect(component.lastState, equals(InventoryState.bow));
    });

    group('when using children constructor argument', () {
      testWithFlameGame('Provides a bloc down on the tree', (game) async {
        final bloc = InventoryCubit();

        late _InventoryReader component;
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
              value: bloc,
              children: [
                component = _InventoryReader(),
              ],
            );
        await game.ensureAdd(provider);

        expect(component.bloc, bloc);
      });

      testWithFlameGame(
        'initial state is used to properly track last state',
        (game) async {
          final bloc = InventoryCubit();
          late _InventoryListener component;
          final provider =
              FlameBlocProvider<InventoryCubit, InventoryState>.value(
                value: bloc,
                children: [
                  component = _InventoryListener(),
                ],
              );
          await game.ensureAdd(provider);
          expect(component.lastState, equals(InventoryState.sword));
        },
      );
      testWithFlameGame('can listen to new state changes', (game) async {
        final bloc = InventoryCubit();
        late _InventoryListener component;
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
              value: bloc,
              children: [
                component = _InventoryListener(),
              ],
            );
        await game.ensureAdd(provider);

        bloc.selectBow();
        await Future<void>.microtask(() {});

        bloc.selectSword();
        await Future<void>.microtask(() {});

        expect(component.lastState, equals(InventoryState.sword));
      });
    });

    group('onRemove', () {
      testWithFlameGame('dispose created blocs', (game) async {
        final provider = FlameBlocProvider<InventoryCubit, InventoryState>(
          create: InventoryCubit.new,
        );
        await game.ensureAdd(provider);
        expect(provider.bloc.isClosed, isFalse);

        provider.removeFromParent();
        await game.ready();
        expect(provider.bloc.isClosed, isTrue);
      });

      testWithFlameGame("don't dispose value bloc", (game) async {
        final bloc = InventoryCubit();
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
              value: bloc,
            );
        await game.ensureAdd(provider);
        expect(provider.bloc.isClosed, isFalse);

        provider.removeFromParent();
        await game.ready();
        expect(provider.bloc.isClosed, isFalse);
      });
    });
  });
}
