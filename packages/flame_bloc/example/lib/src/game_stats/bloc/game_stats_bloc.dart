import 'package:example/src/game_stats/bloc/game_stats_event.dart';
import 'package:example/src/game_stats/bloc/game_stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameStatsBloc extends Bloc<GameStatsEvent, GameStatsState> {
  GameStatsBloc() : super(const GameStatsState.empty()) {
    on<AddScoreEvent>(
      (event, emit) => emit(
        state.copyWith(score: state.score + event.score),
      ),
    );

    on<ResetScoreEvent>(
      (event, emit) => emit(
        state.copyWith(score: 0),
      ),
    );
  }
}
