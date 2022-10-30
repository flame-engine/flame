import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(const InventoryState.empty()) {
    on<WeaponEquipped>(
      (event, emit) => emit(
        state.copyWith(weapon: event.weapon),
      ),
    );

    on<NextWeaponEquipped>((event, emit) {
      const values = Weapon.values;
      final i = values.indexOf(state.weapon);
      if (i == values.length - 1) {
        emit(state.copyWith(weapon: Weapon.bullet));
      } else {
        emit(state.copyWith(weapon: values[i + 1]));
      }
    });
  }
}
