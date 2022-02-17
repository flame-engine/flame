import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import './components/enemy.dart';
import './components/enemy_creator.dart';
import './components/player.dart';
import '../game_stats/bloc/game_stats_bloc.dart';

class GameStatsController extends Component
    with
        HasGameRef<SpaceShooterGame>,
        BlocComponent<GameStatsBloc, GameStatsState> {
  @override
  bool listenWhen(GameStatsState? previousState, GameStatsState newState) {
    return previousState?.status != newState.status &&
        newState.status == GameStatus.initial;
  }

  @override
  void onNewState(GameStatsState state) {
    gameRef.children.removeWhere((element) => element is EnemyComponent);
  }
}

class SpaceShooterGame extends FlameGame
    with
        FlameBloc,
        PanDetector,
        HasCollisionDetection,
        HasKeyboardHandlerComponents {
  late PlayerComponent player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(player = PlayerComponent());
    add(PlayerController());

    add(EnemyCreator());
    add(GameStatsController());
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
    read<GameStatsBloc>().add(const ScoreEventAdded(100));
  }
}
