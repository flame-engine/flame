import 'package:EmberQuest/ember_quest.dart';
import 'package:flutter/material.dart';

class GameOver extends StatelessWidget {
  // Reference to parent game.
  final EmberQuestGame gameRef;
  const GameOver({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    const Color blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const Color whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);
    gameRef.pauseEngine();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          /* decoration: ShapeDecoration(
            shape: PixelBorder.solid(
              pixelSize: 2.0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(16.0),
              ),
              color: whiteTextColor,
            ),
          ), */
          height: 200,
          width: 300,
          color: blackTextColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    gameRef.reset();
                    gameRef.overlays.remove('GameOver');
                    gameRef.resumeEngine();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                    /* shape: PixelBorder.shape(
                      borderRadius: BorderRadius.circular(10.0),
                      pixelSize: 5.0,
                    ), */
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
