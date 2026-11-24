part of 'home_bloc.dart';

/// Base class for [HomeBloc] events.
sealed class const HomeEvent() extends Equatable {
  /// Creates a [HomeEvent].
  this;

  @override
  List<Object> get props => [];
}

/// The recent projects should be (re)loaded.
final class const HomeRecentProjectsRequested() extends HomeEvent {
  /// Creates a [HomeRecentProjectsRequested] event.
  this;
}

/// The user asked to pick a project folder to open.
final class const HomeOpenProjectRequested() extends HomeEvent {
  /// Creates a [HomeOpenProjectRequested] event.
  this;
}

/// The user selected one of the recent projects.
final class const HomeRecentProjectSelected(
  /// The selected project.
  final Project project,
) extends HomeEvent {
  /// Creates a [HomeRecentProjectSelected] event.
  this;

  @override
  List<Object> get props => [project];
}
