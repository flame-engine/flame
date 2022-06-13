import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:trex_game/trex_game.dart';

class TRexWidget extends StatelessWidget {
  const TRexWidget({super.key});

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
