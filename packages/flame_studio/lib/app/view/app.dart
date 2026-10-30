import 'package:flame_studio/home/home.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template app}
/// The root widget of the Flame Studio.
/// {@endtemplate}
class const App({
  /// The repository used to open projects.
  required final ProjectRepository projectRepository,

  /// The repository used to manage the components of a project.
  required final ComponentRepository componentRepository,

  /// The repository used to keep the editor preferences.
  required final EditorPreferencesRepository editorPreferencesRepository,
  super.key,
}) extends StatelessWidget {
  /// {@macro app}
  this;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: projectRepository),
        RepositoryProvider.value(value: componentRepository),
        RepositoryProvider.value(value: editorPreferencesRepository),
      ],
      child: MaterialApp(
        title: 'Flame Studio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const HomePage(),
      ),
    );
  }
}
