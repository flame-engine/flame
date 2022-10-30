import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  Color _mapWeaponColor(Weapon weapon) {
    switch (weapon) {
      case Weapon.bullet:
        return Colors.orange;
      case Weapon.laser:
        return Colors.red;
      case Weapon.plasma:
        return Colors.blue;
    }
  }

  String _mapWeaponName(Weapon weapon) {
    switch (weapon) {
      case Weapon.bullet:
        return 'Kinect';
      case Weapon.laser:
        return 'Laser';
      case Weapon.plasma:
        return 'Plasma';
    }
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
