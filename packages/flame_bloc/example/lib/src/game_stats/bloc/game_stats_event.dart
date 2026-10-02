part of 'game_stats_bloc.dart';

abstract class const GameStatsEvent() extends Equatable;

class const ScoreEventAdded(final int score) extends GameStatsEvent {
  @override
  List<Object?> get props => [score];
}

class const PlayerDied() extends GameStatsEvent {
  @override
  List<Object?> get props => [];
}

class const PlayerRespawned() extends GameStatsEvent {
  @override
  List<Object?> get props => [];
}

class const GameReset() extends GameStatsEvent {
  @override
  List<Object?> get props => [];
}
