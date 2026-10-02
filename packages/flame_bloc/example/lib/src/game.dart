import 'package:flame/game.dart';
import 'package:flame_bloc_example/src/game/game.dart';
import 'package:flame_bloc_example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:flame_bloc_example/src/game_stats/view/game_stat.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';
import 'package:flame_bloc_example/src/inventory/view/inventory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class const GamePage({super.key}) extends StatelessWidget {
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

class const GameView({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        GameStat(),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: Game()),
              Positioned(top: 50, right: 10, child: Inventory()),
            ],
          ),
        ),
      ],
    );
  }
}

class const Game({super.key}) extends StatelessWidget {
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
