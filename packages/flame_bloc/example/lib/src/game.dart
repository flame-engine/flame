import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game/game.dart';
import 'game_stats/bloc/game_stats_bloc.dart';
import 'game_stats/view/game_stat.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => GameStatsBloc(),
        child: Column(
          children: [
            const GameStat(),
            Expanded(
              child: GameWidget(
                game: SpaceShooterGame(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
