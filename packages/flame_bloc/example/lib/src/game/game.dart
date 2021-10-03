import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import './components/enemy_creator.dart';
import './components/player.dart';
import '../game_stats/bloc/game_stats_bloc.dart';

class SpaceShooterGame extends FlameBlocGame
    with PanDetector, HasCollidables, HasKeyboardHandlerComponents {
  late PlayerComponent player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(player = PlayerComponent());

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
    read<GameStatsBloc>().add(const ScoreEventAdded(100));
  }
}
