part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
}

class WeaponEquiped extends InventoryEvent {
  final Weapon weapon;

  const WeaponEquiped(this.weapon);

  @override
  List<Object?> get props => [weapon];
}

class NextWeaponEquiped extends InventoryEvent {
  const NextWeaponEquiped();

  @override
  List<Object?> get props => [];
}
