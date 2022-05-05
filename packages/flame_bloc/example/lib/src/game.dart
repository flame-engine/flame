import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game/game.dart';
import 'game_stats/bloc/game_stats_bloc.dart';
import 'game_stats/view/game_stat.dart';
import 'inventory/bloc/inventory_bloc.dart';
import 'inventory/view/inventory.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<GameStatsBloc>(create: (_) => GameStatsBloc()),
          BlocProvider<InventoryBloc>(create: (_) => InventoryBloc()),
        ],
        child: const GameView(),
      ),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GameStat(),
        Expanded(
          child: Stack(
            children: const [
              Positioned.fill(child: Game()),
              Positioned(top: 50, right: 10, child: Inventory()),
            ],
          ),
        ),
      ],
    );
  }
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: SpaceShooterGame(
        statsBloc: context.read<GameStatsBloc>(),
        inventoryBloc: context.read<InventoryBloc>(),
      ),
    );
  }
}
