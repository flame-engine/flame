import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'project_event.dart';
part 'project_state.dart';

/// {@template project_bloc}
/// Lists, creates and deletes the components of an open [Project].
///
/// Deleting a component also deletes its generated code.
/// {@endtemplate}
class ProjectBloc({
  required final Project _project,
  required final ComponentRepository _componentRepository,
  required final ProjectRepository _projectRepository,
}) extends Bloc<ProjectEvent, ProjectState> {
  /// {@macro project_bloc}
  this : super(const ProjectState()) {
    on<ProjectComponentsRequested>(_onComponentsRequested);
    on<ProjectComponentCreateRequested>(_onComponentCreateRequested);
    on<ProjectComponentDeleteRequested>(_onComponentDeleteRequested);
  }

  Future<void> _onComponentsRequested(
    ProjectComponentsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      emit(
        state.copyWith(
          status: ProjectStatus.ready,
          components: await _getComponents(),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<void> _onComponentCreateRequested(
    ProjectComponentCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final component = await _componentRepository.createComponent(
        _project.path,
        event.name,
        event.type,
        polygonShape: event.polygonShape,
      );
      emit(
        state.copyWith(
          status: ProjectStatus.created,
          createdComponent: component,
          components: await _getComponents(),
        ),
      );
    } on InvalidComponentNameException {
      emit(state.copyWith(status: ProjectStatus.invalidName));
    } on ComponentAlreadyExistsException {
      emit(state.copyWith(status: ProjectStatus.alreadyExists));
    } on ComponentClassConflictException catch (e) {
      emit(
        state.copyWith(
          status: ProjectStatus.classConflict,
          conflictingComponent: e.conflictingComponent,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<void> _onComponentDeleteRequested(
    ProjectComponentDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final settings = await _projectRepository.getSettings(_project);
      await _componentRepository.deleteComponent(
        _project.path,
        event.component,
        outputPath: settings.outputPath,
      );
      emit(
        state.copyWith(
          status: ProjectStatus.ready,
          components: await _getComponents(),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<List<Component>> _getComponents() =>
      _componentRepository.getComponents(_project.path);
}
