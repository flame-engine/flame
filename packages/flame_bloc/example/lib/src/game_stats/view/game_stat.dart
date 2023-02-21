import 'package:flame_bloc_example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameStat extends StatelessWidget {
  const GameStat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameStatsBloc, GameStatsState>(
      builder: (context, state) {
        return Container(
          height: 50,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Score: ${state.score}'),
              Text('Lives: ${state.lives}'),
            ],
          ),
        );
      },
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == GameStatus.gameOver,
      listener: (context, state) {
        final bloc = context.read<GameStatsBloc>();
        showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Game Over',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          bloc.add(const GameReset());
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
