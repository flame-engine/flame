import 'package:example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:example/src/game_stats/bloc/game_stats_event.dart';
import 'package:example/src/game_stats/bloc/game_stats_state.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame/input.dart';

import './components/player.dart';
import './components/enemy_creator.dart';

class SpaceShooterGame extends FlameBlocGame<GameStatsBloc, GameStatsState> with PanDetector, HasCollidables {

  late PlayerComponent player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(player = PlayerComponent());

    add(EnemyCreator());
  }

  @override
  void onPanStart(info) {
    player.beginFire();
  }

  @override
  void onPanEnd(info) {
    player.stopFire();
  }

  @override
  void onPanCancel() {
    player.stopFire();
  }

  @override
  void onPanUpdate(info) {
    player.move(info.delta.game.x, info.delta.game.y);
  }

  void increaseScore() {
    bloc.add(const AddScoreEvent(100));
  }
}
