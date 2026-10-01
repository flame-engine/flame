import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:rogue_shooter/rogue_shooter_game.dart';

class const RogueShooterWidget({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: RogueShooterGame(),
      loadingBuilder: (_) => const Center(
        child: Text('Loading'),
      ),
    );
  }
}
