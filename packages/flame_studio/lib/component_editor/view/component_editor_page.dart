import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/component_editor/view/component_editor_view.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_editor_page}
/// The editor screen for a [Component] of a [Project].
/// {@endtemplate}
class const ComponentEditorPage({
  /// The project the component belongs to.
  required final Project project,

  /// The component being edited.
  required final Component component,
  super.key,
}) extends StatelessWidget {
  /// {@macro component_editor_page}
  this;

  /// Creates a route to the [ComponentEditorPage] for [component].
  static Route<void> route(Project project, Component component) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          ComponentEditorPage(project: project, component: component),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComponentEditorBloc(
        project: project,
        component: component,
        componentRepository: context.read<ComponentRepository>(),
        projectRepository: context.read<ProjectRepository>(),
        editorPreferencesRepository: context
            .read<EditorPreferencesRepository>(),
      )..add(const ComponentEditorStarted()),
      child: ComponentEditorView(project: project),
    );
  }
}
