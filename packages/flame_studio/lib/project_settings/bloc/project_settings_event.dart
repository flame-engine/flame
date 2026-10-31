part of 'project_settings_bloc.dart';

/// Base class for [ProjectSettingsBloc] events.
sealed class const ProjectSettingsEvent() extends Equatable {
  /// Creates a [ProjectSettingsEvent].
  this;

  @override
  List<Object> get props => [];
}

/// The project settings should be loaded.
final class const ProjectSettingsRequested() extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsRequested] event.
  this;
}

/// The user edited the output path.
final class const ProjectSettingsOutputPathChanged(
  /// The new output path.
  final String outputPath,
) extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsOutputPathChanged] event.
  this;

  @override
  List<Object> get props => [outputPath];
}

/// The user asked to pick the output path with the folder picker.
final class const ProjectSettingsBrowseRequested()
    extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsBrowseRequested] event.
  this;
}

/// The user asked to save the settings.
final class const ProjectSettingsSubmitted() extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsSubmitted] event.
  this;
}
