import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';
import '../player_cubit.dart';

class PlayerReader extends Component
    with FlameBlocReader<PlayerCubit, PlayerState> {}

void main() {
  group('FlameBlocReader', () {
    testWithFlameGame(
      'throws assertion error when the bloc is not provided',
      (game) async {
        final bloc = InventoryCubit();
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerReader();
        expect(() => provider.ensureAdd(component), throwsAssertionError);
      },
    );
  });
}
