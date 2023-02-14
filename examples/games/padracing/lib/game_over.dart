import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:padracing/menu_card.dart';
import 'package:padracing/padracing_game.dart';

class GameOver extends StatelessWidget {
  const GameOver(this.game, {super.key});

  final PadRacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            MenuCard(
              children: [
                Text(
                  'Player ${game.winner!.playerNumber + 1} wins!',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${game.timePassed}',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: game.reset,
                  child: const Text('Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
