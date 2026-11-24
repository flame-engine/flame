import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/home/home.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

void main() {
  group(HomeBloc, () {
    const projectA = Project(path: '/a');
    const projectB = Project(path: '/b');

    late ProjectRepository projectRepository;

    setUpAll(() => registerFallbackValue(projectA));

    setUp(() {
      projectRepository = _MockProjectRepository();
    });

    HomeBloc buildBloc() => HomeBloc(projectRepository: projectRepository);

    test('initial state is HomeState', () {
      expect(buildBloc().state, equals(const HomeState()));
    });

    group(HomeRecentProjectsRequested, () {
      blocTest<HomeBloc, HomeState>(
        'emits [loading, ready] with the recent projects',
        setUp: () =>
            when(projectRepository.getRecentProjects)
                .thenAnswer((_) async => [projectA]),
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeRecentProjectsRequested()),
        expect: () => const [
          HomeState(status: HomeStatus.loading),
          HomeState(status: HomeStatus.ready, recentProjects: [projectA]),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [loading, failure] when loading fails',
        setUp: () =>
            when(projectRepository.getRecentProjects).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeRecentProjectsRequested()),
        expect: () => const [
          HomeState(status: HomeStatus.loading),
          HomeState(status: HomeStatus.failure),
        ],
      );
    });

    group(HomeOpenProjectRequested, () {
      blocTest<HomeBloc, HomeState>(
        'emits nothing when the picker is cancelled',
        setUp: () =>
            when(projectRepository.pickProject).thenAnswer((_) async => null),
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeOpenProjectRequested()),
        expect: () => const <HomeState>[],
        verify: (_) => verifyNever(() => projectRepository.openProject(any())),
      );

      blocTest<HomeBloc, HomeState>(
        'opens the picked project',
        setUp: () {
          when(projectRepository.pickProject).thenAnswer((_) async => projectA);
          when(() => projectRepository.openProject(projectA))
              .thenAnswer((_) async {});
          when(projectRepository.getRecentProjects)
              .thenAnswer((_) async => [projectA]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeOpenProjectRequested()),
        expect: () => const [
          HomeState(
            status: HomeStatus.opened,
            openedProject: projectA,
            recentProjects: [projectA],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits failure when picking fails',
        setUp: () => when(projectRepository.pickProject).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeOpenProjectRequested()),
        expect: () => const [HomeState(status: HomeStatus.failure)],
      );
    });

    group(HomeRecentProjectSelected, () {
      blocTest<HomeBloc, HomeState>(
        'opens the selected project',
        setUp: () {
          when(() => projectRepository.openProject(projectB))
              .thenAnswer((_) async {});
          when(projectRepository.getRecentProjects)
              .thenAnswer((_) async => [projectB, projectA]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeRecentProjectSelected(projectB)),
        expect: () => const [
          HomeState(
            status: HomeStatus.opened,
            openedProject: projectB,
            recentProjects: [projectB, projectA],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits projectNotFound with the refreshed recent projects',
        setUp: () {
          when(() => projectRepository.openProject(projectB))
              .thenThrow(const ProjectNotFoundException(projectB));
          when(projectRepository.getRecentProjects)
              .thenAnswer((_) async => [projectA]);
        },
        build: buildBloc,
        seed: () => const HomeState(
          status: HomeStatus.ready,
          recentProjects: [projectA, projectB],
        ),
        act: (bloc) => bloc.add(const HomeRecentProjectSelected(projectB)),
        expect: () => const [
          HomeState(
            status: HomeStatus.projectNotFound,
            recentProjects: [projectA],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits failure when opening fails',
        setUp: () =>
            when(() => projectRepository.openProject(projectB))
                .thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const HomeRecentProjectSelected(projectB)),
        expect: () => const [HomeState(status: HomeStatus.failure)],
      );
    });
  });
}
