import 'dart:async';

import 'package:flame_studio/home/home.dart';
import 'package:flame_studio/home/widgets/widgets.dart';
import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template home_view}
/// Shows the open project button and the recent projects.
/// {@endtemplate}
class const HomeView({super.key}) extends StatelessWidget {
  /// {@macro home_view}
  this;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        switch (state.status) {
          case HomeStatus.opened:
            unawaited(_openProject(context, state.openedProject!));
          case HomeStatus.projectNotFound:
            _showMessage(context, 'Project folder not found');
          case HomeStatus.failure:
            _showMessage(context, 'Something went wrong');
          case HomeStatus.initial || HomeStatus.loading || HomeStatus.ready:
            break;
        }
      },
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Flame Studio',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.read<HomeBloc>().add(
                      const HomeOpenProjectRequested(),
                    ),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open project'),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Recent projects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Flexible(child: _RecentProjects()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProject(BuildContext context, Project project) async {
    final bloc = context.read<HomeBloc>();
    await Navigator.of(context).push(ProjectPage.route(project));
    bloc.add(const HomeRecentProjectsRequested());
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class const _RecentProjects() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recentProjects = context.select<HomeBloc, List<Project>>(
      (bloc) => bloc.state.recentProjects,
    );

    if (recentProjects.isEmpty) {
      return const Text('No recent projects');
    }

    return ListView(
      shrinkWrap: true,
      children: [
        for (final project in recentProjects)
          RecentProjectTile(
            project: project,
            onTap: () => context.read<HomeBloc>().add(
              HomeRecentProjectSelected(project),
            ),
          ),
      ],
    );
  }
}
