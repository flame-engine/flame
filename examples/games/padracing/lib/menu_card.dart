import 'package:material_ui/material_ui.dart' hide Gradient, Image;

import 'package:padracing/game_colors.dart';

class const MenuCard({required final List<Widget> children, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shadowColor: GameColors.green.color,
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
