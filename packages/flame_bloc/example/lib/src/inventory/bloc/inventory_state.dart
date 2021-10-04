part of 'inventory_bloc.dart';

enum Weapon {
  bullet,
  laser,
  plasma,
}

class InventoryState extends Equatable {
  final Weapon weapon;

  const InventoryState({
    required this.weapon,
  });

  const InventoryState.empty() : this(weapon: Weapon.bullet);

  InventoryState copyWith({
    Weapon? weapon,
  }) {
    return InventoryState(weapon: weapon ?? this.weapon);
  }

  @override
  List<Object?> get props => [weapon];
}
