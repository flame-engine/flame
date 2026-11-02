import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'project_settings_event.dart';
part 'project_settings_state.dart';

/// {@template project_settings_bloc}
/// Loads, edits and saves the settings of a [Project].
/// {@endtemplate}
class ProjectSettingsBloc({
  required final Project _project,
  required final ProjectRepository _projectRepository,
}) extends Bloc<ProjectSettingsEvent, ProjectSettingsState> {
  /// {@macro project_settings_bloc}
  this : super(const ProjectSettingsState()) {
    on<ProjectSettingsRequested>(_onRequested);
    on<ProjectSettingsOutputPathChanged>(_onOutputPathChanged);
    on<ProjectSettingsBrowseRequested>(_onBrowseRequested);
    on<ProjectSettingsSubmitted>(_onSubmitted);
  }

  Future<void> _onRequested(
    ProjectSettingsRequested event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectSettingsStatus.loading));
    try {
      final settings = await _projectRepository.getSettings(_project);
      emit(
        state.copyWith(
          status: ProjectSettingsStatus.ready,
          outputPath: settings.outputPath,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectSettingsStatus.failure));
    }
  }

  void _onOutputPathChanged(
    ProjectSettingsOutputPathChanged event,
    Emitter<ProjectSettingsState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectSettingsStatus.ready,
        outputPath: event.outputPath,
      ),
    );
  }

  Future<void> _onBrowseRequested(
    ProjectSettingsBrowseRequested event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    try {
      final outputPath = await _projectRepository.pickOutputPath(_project);
      if (outputPath == null) {
        return;
      }
      emit(
        state.copyWith(
          status: ProjectSettingsStatus.ready,
          outputPath: outputPath,
        ),
      );
    } on InvalidOutputPathException {
      emit(state.copyWith(status: ProjectSettingsStatus.invalidOutputPath));
    } on Exception {
      emit(state.copyWith(status: ProjectSettingsStatus.failure));
    }
  }

  Future<void> _onSubmitted(
    ProjectSettingsSubmitted event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectSettingsStatus.saving));
    try {
      final settings = await _projectRepository.saveSettings(
        _project,
        ProjectSettings(outputPath: state.outputPath),
      );
      emit(
        state.copyWith(
          status: ProjectSettingsStatus.saved,
          outputPath: settings.outputPath,
        ),
      );
    } on InvalidOutputPathException {
      emit(state.copyWith(status: ProjectSettingsStatus.invalidOutputPath));
    } on Exception {
      emit(state.copyWith(status: ProjectSettingsStatus.failure));
    }
  }
}
