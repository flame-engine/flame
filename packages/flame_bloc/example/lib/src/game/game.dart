import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/components/enemy_creator.dart';
import 'package:flame_bloc_example/src/game/components/player.dart';
import 'package:flame_bloc_example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';

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
          gameRef.removeWhere((element) => element is EnemyComponent);
        },
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame
    with DragCallbacks, HasCollisionDetection, HasKeyboardHandlerComponents {
  late PlayerComponent player;

  final GameStatsBloc statsBloc;
  final InventoryBloc inventoryBloc;

  SpaceShooterGame({
    required this.statsBloc,
    required this.inventoryBloc,
  });

  @override
  Future<void> onLoad() async {
    add(
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

  /// Multiple pointers would each apply their delta, accumulating ship speed.
  @override
  bool get allowsMultiPointerDrag => false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    player.beginFire();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    player.stopFire();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    player.stopFire();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    player.move(event.localDelta.x, event.localDelta.y);
  }

  void increaseScore() {
    statsBloc.add(const ScoreEventAdded(100));
  }
}
