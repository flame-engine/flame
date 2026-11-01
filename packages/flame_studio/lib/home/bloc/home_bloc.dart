import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'home_event.dart';
part 'home_state.dart';

/// {@template home_bloc}
/// Loads the recent projects and opens projects from the home screen.
/// {@endtemplate}
class HomeBloc({required final ProjectRepository _projectRepository})
    extends Bloc<HomeEvent, HomeState> {
  /// {@macro home_bloc}
  this : super(const HomeState()) {
    on<HomeRecentProjectsRequested>(_onRecentProjectsRequested);
    on<HomeOpenProjectRequested>(_onOpenProjectRequested);
    on<HomeRecentProjectSelected>(_onRecentProjectSelected);
  }

  Future<void> _onRecentProjectsRequested(
    HomeRecentProjectsRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final recentProjects = await _projectRepository.getRecentProjects();
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          recentProjects: recentProjects,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> _onOpenProjectRequested(
    HomeOpenProjectRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final project = await _projectRepository.pickProject();
      if (project == null) {
        return;
      }
      await _openProject(project, emit);
    } on Exception {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> _onRecentProjectSelected(
    HomeRecentProjectSelected event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _openProject(event.project, emit);
    } on Exception {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> _openProject(Project project, Emitter<HomeState> emit) async {
    try {
      await _projectRepository.openProject(project);
      emit(
        state.copyWith(
          status: HomeStatus.opened,
          openedProject: project,
          recentProjects: await _projectRepository.getRecentProjects(),
        ),
      );
    } on ProjectNotFoundException {
      emit(
        state.copyWith(
          status: HomeStatus.projectNotFound,
          recentProjects: await _projectRepository.getRecentProjects(),
        ),
      );
    }
  }
}
