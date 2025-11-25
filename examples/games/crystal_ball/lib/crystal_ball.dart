import 'dart:ui';

import 'package:crystal_ball/src/game/game.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CrystalBallWidget extends StatefulWidget {
  const CrystalBallWidget({super.key});

  static const String description = '''
A demonstration of how to leverage the power of Fragment Shaders in Flame.
The game is a simple crystal ball that jumps around in a swampy world.
It uses custom post process shaders to create fog, fireflies, water reflections
and the glowing effect of the crystal ball.
  ''';

  @override
  State<CrystalBallWidget> createState() => _CrystalBallWidgetState();
}

class _CrystalBallWidgetState extends State<CrystalBallWidget> {
  // PreloadedPrograms is a simple data class that holds the preloaded
  late final Future<PreloadedPrograms> preloadedPrograms =
      Future.wait([
        FragmentProgram.fromAsset('packages/crystal_ball/shaders/ground.frag'),
        FragmentProgram.fromAsset('packages/crystal_ball/shaders/fog.frag'),
        FragmentProgram.fromAsset('packages/crystal_ball/shaders/firefly.frag'),
      ]).then(
        (l) => (
          waterFragmentProgram: l[0],
          fogFragmentProgram: l[1],
          fireflyFragmentProgram: l[2],
        ),
      );

  CrystalBallGame? game;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: preloadedPrograms,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error!;
        }

        // Show a loading indicator while the fragment programs are loading
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GameWidget(
          // It is a good idea to save the game instance on state
          // to avoid issues with hot reload
          game: game ??= CrystalBallGame(
            preloadedPrograms: snapshot.data!,
          ),
        );
      },
    );
  }
}
