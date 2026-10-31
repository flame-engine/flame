import 'dart:async';

import 'package:flame_studio/component_editor/component_editor.dart';
import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/project/widgets/widgets.dart';
import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template project_view}
/// Lists the components of [project] and lets the user add, edit and
/// delete them.
/// {@endtemplate}
class const ProjectView({
  /// The open project.
  required final Project project,
  super.key,
}) extends StatelessWidget {
  /// {@macro project_view}
  this;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        switch (state.status) {
          case ProjectStatus.created:
            unawaited(_editComponent(context, state.createdComponent!));
          case ProjectStatus.invalidName:
            _showMessage(
              context,
              'Component names must start with a letter or underscore and '
              'contain only letters, digits and underscores',
            );
          case ProjectStatus.alreadyExists:
            _showMessage(context, 'A component with that name already exists');
          case ProjectStatus.classConflict:
            _showMessage(
              context,
              'That name generates the same class as a part of the '
              '"${state.conflictingComponent}" component',
            );
          case ProjectStatus.failure:
            _showMessage(context, 'Something went wrong');
          case ProjectStatus.initial ||
              ProjectStatus.loading ||
              ProjectStatus.ready:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => ProjectSettingsDialog.show(context, project),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Components',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _addComponent(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add component'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _Components(
                      onEdit: (component) => _editComponent(context, component),
                      onDelete: (component) =>
                          _deleteComponent(context, component),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addComponent(BuildContext context) async {
    final bloc = context.read<ProjectBloc>();
    final result = await AddComponentDialog.show(context);
    if (result == null) {
      return;
    }
    bloc.add(
      ProjectComponentCreateRequested(
        result.name,
        result.type,
        polygonShape: result.polygonShape,
      ),
    );
  }

  Future<void> _editComponent(BuildContext context, Component component) async {
    final bloc = context.read<ProjectBloc>();
    await Navigator.of(context)
        .push(ComponentEditorPage.route(project, component));
    bloc.add(const ProjectComponentsRequested());
  }

  Future<void> _deleteComponent(
    BuildContext context,
    Component component,
  ) async {
    final bloc = context.read<ProjectBloc>();
    final confirmed = await DeleteComponentDialog.show(context, component);
    if (!confirmed) {
      return;
    }
    bloc.add(ProjectComponentDeleteRequested(component));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class const _Components({
  required final ValueChanged<Component> onEdit,
  required final ValueChanged<Component> onDelete,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.select<ProjectBloc, (ProjectStatus, List<Component>)>(
      (bloc) => (bloc.state.status, bloc.state.components),
    );
    final (status, components) = state;

    if (components.isEmpty) {
      if (status == ProjectStatus.initial || status == ProjectStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const Text('No components yet');
    }

    return ListView(
      children: [
        for (final component in components)
          ComponentTile(
            component: component,
            onEdit: () => onEdit(component),
            onDelete: () => onDelete(component),
          ),
      ],
    );
  }
}
