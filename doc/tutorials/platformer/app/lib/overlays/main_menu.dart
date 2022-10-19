import 'package:EmberQuest/ember_quest.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final EmberQuestGame gameRef;

  const MainMenu({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    const Color blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const Color whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 320,
          width: 300,
          color: blackTextColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ember Quest',
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
                    gameRef.overlays.remove('MainMenu');
                    gameRef.resumeEngine();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    gameRef.overlays.add('SettingsMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use WASD or Arrow Keys for movement.  Space bar to jump. Collect as many stars as you can and avoid enemies!',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
