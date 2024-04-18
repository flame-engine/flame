import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  Color _mapWeaponColor(Weapon weapon) {
    return switch (weapon) {
      Weapon.bullet => Colors.orange,
      Weapon.laser => Colors.red,
      Weapon.plasma => Colors.blue,
    };
  }

  String _mapWeaponName(Weapon weapon) {
    return switch (weapon) {
      Weapon.bullet => 'Kinetic',
      Weapon.laser => 'Laser',
      Weapon.plasma => 'Plasma',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InventoryBloc>().state;

    return Column(
      children: [
        for (final weapon in Weapon.values)
          GestureDetector(
            onTap: () {
              if (weapon != state.weapon) {
                context.read<InventoryBloc>().add(WeaponEquipped(weapon));
              }
            },
            child: Opacity(
              opacity: weapon == state.weapon ? 0.8 : 0.6,
              child: Container(
                color: Colors.white,
                width: 50,
                height: 50,
                child: Center(
                  child: Text(
                    _mapWeaponName(weapon),
                    style: TextStyle(color: _mapWeaponColor(weapon)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
