import 'dart:math';
import 'dart:ui';

import 'package:crystal_ball/src/game/game.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const GamePage());
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final Future<PreloadedPrograms> preloadedPrograms = Future.wait([
    FragmentProgram.fromAsset('shaders/ground.frag'),
    FragmentProgram.fromAsset('shaders/fog.frag'),
  ]).then(
    (l) => (
      waterFragmentProgram: l[0],
      fogFragmentProgram: l[1],
    ),
  );

  late final random = Random();

  CrystalBallGame? game;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: preloadedPrograms,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error!;
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GameWidget(
          game: game ??= CrystalBallGame(
            preloadedPrograms: snapshot.data!,
            random: random,
            // You may want to adjust this value based on your device's
            // pixel ratio
            pixelRatio: 1,
          ),
        );
      },
    );
  }
}
