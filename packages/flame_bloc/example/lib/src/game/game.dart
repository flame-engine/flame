import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/components/enemy_creator.dart';
import 'package:flame_bloc_example/src/game/components/player.dart';
import 'package:flame_bloc_example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';

class GameStatsController extends Component
    with HasGameReference<SpaceShooterGame> {
  @override
  Future<void>? onLoad() async {
    add(
      FlameBlocListener<GameStatsBloc, GameStatsState>(
        listenWhen: (previousState, newState) {
          return previousState.status != newState.status &&
              newState.status == GameStatus.initial;
        },
        onNewState: (state) {
          game.removeWhere((element) => element is EnemyComponent);
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

  /// The pointer currently flying the ship. Drag events are reported per
  /// pointer, so without this a second finger would move the ship twice as
  /// fast and stop the fire when lifted.
  int? _controllingPointerId;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_controllingPointerId != null) {
      return;
    }
    _controllingPointerId = event.pointerId;
    player.beginFire();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _releaseControl(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _releaseControl(event.pointerId);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (event.pointerId != _controllingPointerId) {
      return;
    }
    player.move(event.localDelta.x, event.localDelta.y);
  }

  void _releaseControl(int pointerId) {
    if (pointerId != _controllingPointerId) {
      return;
    }
    _controllingPointerId = null;
    player.stopFire();
  }

  void increaseScore() {
    statsBloc.add(const ScoreEventAdded(100));
  }
}
