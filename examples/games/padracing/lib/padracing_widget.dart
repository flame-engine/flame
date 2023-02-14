import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'package:padracing/game_over.dart';
import 'package:padracing/menu.dart';
import 'package:padracing/padracing_game.dart';

class PadracingWidget extends StatelessWidget {
  const PadracingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      textTheme: TextTheme(
        displayLarge: GoogleFonts.vt323(
          fontSize: 35,
          color: Colors.white,
        ),
        labelLarge: GoogleFonts.vt323(
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.vt323(
          fontSize: 28,
          color: Colors.grey,
        ),
        bodyMedium: GoogleFonts.vt323(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(150, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hoverColor: Colors.red.shade700,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade700,
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'PadRacing',
      home: GameWidget<PadRacingGame>(
        game: PadRacingGame(),
        loadingBuilder: (context) => Center(
          child: Text(
            'Loading...',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
          'game_over': (_, game) => GameOver(game),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: theme,
    );
  }
}
