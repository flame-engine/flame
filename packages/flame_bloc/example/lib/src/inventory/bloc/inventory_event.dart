part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
}

class WeaponEquipped extends InventoryEvent {
  final Weapon weapon;

  const WeaponEquipped(this.weapon);

  @override
  List<Object?> get props => [weapon];
}

class NextWeaponEquipped extends InventoryEvent {
  const NextWeaponEquipped();

  @override
  List<Object?> get props => [];
}
