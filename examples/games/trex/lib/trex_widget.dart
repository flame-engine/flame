import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart' hide Gradient, Image;
import 'package:trex_game/trex_game.dart';

class const TRexWidget({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'T-Rex',
      home: Container(
        color: Colors.black,
        margin: const EdgeInsets.all(45),
        child: ClipRect(
          child: GameWidget(
            game: TRexGame(),
            loadingBuilder: (_) => const Center(
              child: Text('Loading'),
            ),
          ),
        ),
      ),
    );
  }
}
