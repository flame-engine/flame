import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import './components/enemy.dart';
import './components/enemy_creator.dart';
import './components/player.dart';
import '../game_stats/bloc/game_stats_bloc.dart';
import '../inventory/bloc/inventory_bloc.dart';

class GameStatsController extends Component with HasGameRef<SpaceShooterGame> {
  @override
  Future<void>? onLoad() async {
    add(
      FlameBlocListener<GameStatsBloc, GameStatsState>(
        listenWhen: (previousState, newState) {
          return previousState.status != newState.status &&
              newState.status == GameStatus.initial;
        },
        onNewState: (state) {
          gameRef.children.removeWhere((element) => element is EnemyComponent);
        },
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  late PlayerComponent player;

  final GameStatsBloc statsBloc;
  final InventoryBloc inventoryBloc;

  SpaceShooterGame({
    required this.statsBloc,
    required this.inventoryBloc,
  });

  @override
  Future<void> onLoad() async {

    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<InventoryBloc, InventoryState>.value(
            value: inventoryBloc,
          ),
          FlameBlocProvider<GameStatsBloc, GameStatsState>.value(
            value: statsBloc,
          ),
        ],
        children: [
          player = PlayerComponent(),
          PlayerController(),
          GameStatsController(),
        ],
      ),
    );

    add(EnemyCreator());
  }

  @override
  void onPanStart(_) {
    player.beginFire();
  }

  @override
  void onPanEnd(_) {
    player.stopFire();
  }

  @override
  void onPanCancel() {
    player.stopFire();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game.x, info.delta.game.y);
  }

  void increaseScore() {
    statsBloc.add(const ScoreEventAdded(100));
  }
}
