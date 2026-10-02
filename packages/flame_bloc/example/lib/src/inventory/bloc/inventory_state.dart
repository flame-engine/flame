part of 'inventory_bloc.dart';

enum Weapon() {
  bullet,
  laser,
  plasma,
}

class const InventoryState({
  required final Weapon weapon,
}) extends Equatable {
  const InventoryState.empty() : this(weapon: Weapon.bullet);

  InventoryState copyWith({
    Weapon? weapon,
  }) {
    return InventoryState(weapon: weapon ?? this.weapon);
  }

  @override
  List<Object?> get props => [weapon];
}
