import 'package:material_ui/material_ui.dart' hide Gradient, Image;
import 'package:padracing/menu_card.dart';
import 'package:padracing/padracing_game.dart';

class const GameOver(final PadRacingGame game, {super.key})
    extends StatelessWidget {
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
