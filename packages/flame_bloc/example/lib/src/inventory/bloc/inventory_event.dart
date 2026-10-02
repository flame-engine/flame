part of 'inventory_bloc.dart';

abstract class const InventoryEvent() extends Equatable;

class const WeaponEquipped(final Weapon weapon) extends InventoryEvent {
  @override
  List<Object?> get props => [weapon];
}

class const NextWeaponEquipped() extends InventoryEvent {
  @override
  List<Object?> get props => [];
}
