import 'package:equatable/equatable.dart';

abstract class GameStatsEvent extends Equatable {
  const GameStatsEvent();
}

class ScoreEventAdded extends GameStatsEvent {
  const ScoreEventAdded(this.score);

  final int score;

  @override
  List<Object?> get props => [score];
}

class ScoreEventCleared extends GameStatsEvent {
  const ScoreEventCleared();

  @override
  List<Object?> get props => [];
}
