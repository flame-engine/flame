part of 'home_bloc.dart';

/// The status of the [HomeBloc].
enum HomeStatus() {
  /// Nothing has been loaded yet.
  initial,

  /// The recent projects are being loaded.
  loading,

  /// The recent projects are loaded.
  ready,

  /// A project was opened; see [HomeState.openedProject].
  opened,

  /// The selected project folder no longer exists.
  projectNotFound,

  /// Something went wrong.
  failure,
}

/// {@template home_state}
/// The state of the [HomeBloc].
/// {@endtemplate}
final class const HomeState({
  /// The current status.
  final HomeStatus status = HomeStatus.initial,

  /// The recently opened projects, most recent first.
  final List<Project> recentProjects = const [],

  /// The last opened project.
  final Project? openedProject,
}) extends Equatable {
  /// {@macro home_state}
  this;

  /// Returns a copy of this state with the given fields replaced.
  HomeState copyWith({
    HomeStatus? status,
    List<Project>? recentProjects,
    Project? openedProject,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentProjects: recentProjects ?? this.recentProjects,
      openedProject: openedProject ?? this.openedProject,
    );
  }

  @override
  List<Object?> get props => [status, recentProjects, openedProject];
}
