import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template project_page}
/// The dashboard of an open [Project], listing its components.
/// {@endtemplate}
class const ProjectPage({
  /// The open project.
  required final Project project,
  super.key,
}) extends StatelessWidget {
  /// {@macro project_page}
  this;

  /// Creates a route to the [ProjectPage] for [project].
  static Route<void> route(Project project) {
    return MaterialPageRoute<void>(
      builder: (_) => ProjectPage(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc(
        project: project,
        componentRepository: context.read(),
        projectRepository: context.read(),
      )..add(const ProjectComponentsRequested()),
      child: ProjectView(project: project),
    );
  }
}
