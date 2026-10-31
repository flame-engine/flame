import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockEditorPreferencesRepository()
    extends Mock
    implements EditorPreferencesRepository {
  this {
    when(
      () => getComponentZoom(
        projectPath: any(named: 'projectPath'),
        componentName: any(named: 'componentName'),
      ),
    ).thenAnswer((_) async => EditorPreferencesRepository.defaultZoom);
    when(
      () => setComponentZoom(
        projectPath: any(named: 'projectPath'),
        componentName: any(named: 'componentName'),
        zoom: any(named: 'zoom'),
      ),
    ).thenAnswer((_) async {});
  }
}

extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in the app-level dependencies (theme, providers).
  ///
  /// Add repository/bloc providers here as they are introduced so that every
  /// widget test gets the same environment.
  Future<void> pumpApp(
    Widget widget, {
    ProjectRepository? projectRepository,
    ComponentRepository? componentRepository,
    EditorPreferencesRepository? editorPreferencesRepository,
  }) {
    return pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: projectRepository ?? _MockProjectRepository(),
          ),
          RepositoryProvider.value(
            value: componentRepository ?? _MockComponentRepository(),
          ),
          RepositoryProvider.value(
            value:
                editorPreferencesRepository ??
                _MockEditorPreferencesRepository(),
          ),
        ],
        child: MaterialApp(home: widget),
      ),
    );
  }

  /// Pumps frames until a route transition has finished.
  ///
  /// Use instead of `pumpAndSettle` when the route contains a `GameWidget`,
  /// whose game loop never settles.
  Future<void> pumpRouteTransition() async {
    await pump();
    await pump(const Duration(seconds: 1));
  }
}
