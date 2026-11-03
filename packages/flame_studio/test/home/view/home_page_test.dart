import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/home/home.dart';
import 'package:flame_studio/home/widgets/widgets.dart';
import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockHomeBloc()
    extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc;

void main() {
  const project = Project(path: '/projects/my_game');

  group(HomePage, () {
    testWidgets('loads the recent projects', (tester) async {
      final projectRepository = _MockProjectRepository();
      when(projectRepository.getRecentProjects)
          .thenAnswer((_) async => [project]);

      await tester.pumpApp(
        const HomePage(),
        projectRepository: projectRepository,
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text('my_game'), findsOneWidget);
    });
  });

  group(HomeView, () {
    late HomeBloc homeBloc;

    setUp(() {
      homeBloc = _MockHomeBloc();
      when(() => homeBloc.state).thenReturn(const HomeState());
    });

    Widget buildSubject() =>
        BlocProvider.value(value: homeBloc, child: const HomeView());

    testWidgets('shows an empty message without recent projects', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('No recent projects'), findsOneWidget);
    });

    testWidgets('shows the recent projects', (tester) async {
      when(() => homeBloc.state).thenReturn(
        const HomeState(
          status: HomeStatus.ready,
          recentProjects: [
            project,
            Project(path: '/other'),
          ],
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(RecentProjectTile), findsNWidgets(2));
      expect(find.text('my_game'), findsOneWidget);
      expect(find.text('/projects/my_game'), findsOneWidget);
    });

    testWidgets('adds HomeOpenProjectRequested when tapping open', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Open project'));

      verify(() => homeBloc.add(const HomeOpenProjectRequested())).called(1);
    });

    testWidgets('adds HomeRecentProjectSelected when tapping a recent', (
      tester,
    ) async {
      when(() => homeBloc.state).thenReturn(
        const HomeState(status: HomeStatus.ready, recentProjects: [project]),
      );

      await tester.pumpApp(buildSubject());
      await tester.tap(find.byType(RecentProjectTile));

      verify(() => homeBloc.add(const HomeRecentProjectSelected(project)))
          .called(1);
    });

    testWidgets(
      'navigates to the project and reloads recent projects when coming back',
      (tester) async {
        whenListen(
          homeBloc,
          Stream.value(
            const HomeState(status: HomeStatus.opened, openedProject: project),
          ),
        );

        final componentRepository = _MockComponentRepository();
        when(() => componentRepository.getComponents(project.path))
            .thenAnswer((_) async => []);

        await tester.pumpApp(
          buildSubject(),
          componentRepository: componentRepository,
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProjectPage), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(ProjectPage), findsNothing);
        verify(() => homeBloc.add(const HomeRecentProjectsRequested()))
            .called(1);
      },
    );

    testWidgets('shows a message when the project is not found', (
      tester,
    ) async {
      whenListen(
        homeBloc,
        Stream.value(const HomeState(status: HomeStatus.projectNotFound)),
        initialState: const HomeState(),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.text('Project folder not found'), findsOneWidget);
    });

    testWidgets('shows a message on failure', (tester) async {
      whenListen(
        homeBloc,
        Stream.value(const HomeState(status: HomeStatus.failure)),
        initialState: const HomeState(),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
