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
  }
}
