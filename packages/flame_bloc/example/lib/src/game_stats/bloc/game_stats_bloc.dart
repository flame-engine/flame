import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_stats_event.dart';
part 'game_stats_state.dart';

class GameStatsBloc extends Bloc<GameStatsEvent, GameStatsState> {
  GameStatsBloc() : super(const GameStatsState.empty()) {
    on<ScoreEventAdded>(
      (event, emit) => emit(
        state.copyWith(score: state.score + event.score),
      ),
    );

    on<ScoreEventCleared>(
      (event, emit) => emit(
        state.copyWith(score: 0),
      ),
    );

    on<PlayerRespawned>(
      (event, emit) => emit(
        state.copyWith(status: GameStatus.respawned),
      ),
    );

    on<PlayerDied>((event, emit) {
      if (state.lives > 1) {
        emit(
          state.copyWith(
            lives: state.lives - 1,
            status: GameStatus.respawn,
          ),
        );
      } else {
        emit(
          state.copyWith(
            lives: 0,
            status: GameStatus.gameOver,
          ),
        );
      }
    });

    on<GameReset>(
      (event, emit) => emit(
        const GameStatsState.empty(),
      ),
    );
  }
}
