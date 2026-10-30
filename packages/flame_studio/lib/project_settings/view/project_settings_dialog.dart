import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template project_settings_dialog}
/// A dialog to edit the settings of a [Project].
/// {@endtemplate}
class const ProjectSettingsDialog({
  /// The project whose settings are edited.
  required final Project project,
  super.key,
}) extends StatelessWidget {
  /// {@macro project_settings_dialog}
  this;

  /// Shows the settings dialog of [project].
  static Future<void> show(BuildContext context, Project project) {
    return showDialog<void>(
      context: context,
      builder: (_) => ProjectSettingsDialog(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectSettingsBloc(
        project: project,
        projectRepository: context.read(),
      )..add(const ProjectSettingsRequested()),
      child: const ProjectSettingsView(),
    );
  }
}
