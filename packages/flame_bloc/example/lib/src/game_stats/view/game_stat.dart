import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_stats_bloc.dart';

class GameStat extends StatelessWidget {
  const GameStat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameStatsBloc>().state;

    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          Text('Score: ${state.score}'),
        ],
      ),
    );
  }
}
