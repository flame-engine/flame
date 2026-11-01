import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template project_settings_view}
/// Lets the user edit the project settings and pops once they are saved.
/// {@endtemplate}
class const ProjectSettingsView({super.key}) extends StatefulWidget {
  /// {@macro project_settings_view}
  this;

  @override
  State<ProjectSettingsView> createState() => _ProjectSettingsViewState();
}

class _ProjectSettingsViewState() extends State<ProjectSettingsView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ProjectSettingsBloc>().state.outputPath,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectSettingsBloc, ProjectSettingsState>(
      listener: (context, state) {
        if (state.status == ProjectSettingsStatus.saved) {
          Navigator.of(context).pop();
        } else if (state.outputPath != _controller.text) {
          _controller.text = state.outputPath;
        }
      },
      builder: (context, state) {
        final bloc = context.read<ProjectSettingsBloc>();
        final status = state.status;
        final loading =
            status == ProjectSettingsStatus.initial ||
            status == ProjectSettingsStatus.loading;
        final canSave =
            !loading &&
            status != ProjectSettingsStatus.saving &&
            state.outputPath.trim().isNotEmpty;

        return AlertDialog(
          title: const Text('Project settings'),
          content: SizedBox(
            width: 480,
            child: loading
                ? const Center(
                    heightFactor: 1,
                    child: CircularProgressIndicator(),
                  )
                : TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Generated code path',
                      helperText: 'Relative to the project folder',
                      errorText: switch (status) {
                        ProjectSettingsStatus.invalidOutputPath =>
                          'Must be a folder inside the project',
                        ProjectSettingsStatus.failure => 'Something went wrong',
                        _ => null,
                      },
                      suffixIcon: IconButton(
                        tooltip: 'Browse',
                        icon: const Icon(Icons.folder_open),
                        onPressed: () =>
                            bloc.add(const ProjectSettingsBrowseRequested()),
                      ),
                    ),
                    onChanged: (value) =>
                        bloc.add(ProjectSettingsOutputPathChanged(value)),
                    onSubmitted: (_) {
                      if (canSave) {
                        bloc.add(const ProjectSettingsSubmitted());
                      }
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: canSave
                  ? () => bloc.add(const ProjectSettingsSubmitted())
                  : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
