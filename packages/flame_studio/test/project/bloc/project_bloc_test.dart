import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockProjectRepository() extends Mock implements ProjectRepository;

void main() {
  group(ProjectBloc, () {
    const project = Project(path: '/projects/my_game');
    const player = RectangleComponent(name: 'Player');
    const enemy = RectangleComponent(name: 'Enemy');

    late ComponentRepository componentRepository;
    late ProjectRepository projectRepository;

    setUp(() {
      componentRepository = _MockComponentRepository();
      projectRepository = _MockProjectRepository();
      when(
        () => projectRepository.getSettings(project),
      ).thenAnswer((_) async => const ProjectSettings(outputPath: 'lib/game'));
    });

    ProjectBloc buildBloc() => ProjectBloc(
      project: project,
      componentRepository: componentRepository,
      projectRepository: projectRepository,
    );

    test('initial state is ProjectState', () {
      expect(buildBloc().state, equals(const ProjectState()));
    });

    group(ProjectComponentsRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'emits [loading, ready] with the components',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenAnswer((_) async => [enemy, player]),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentsRequested()),
        expect: () => const [
          ProjectState(status: ProjectStatus.loading),
          ProjectState(
            status: ProjectStatus.ready,
            components: [enemy, player],
          ),
        ],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits [loading, failure] when loading fails',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentsRequested()),
        expect: () => const [
          ProjectState(status: ProjectStatus.loading),
          ProjectState(status: ProjectStatus.failure),
        ],
      );
    });

    group(ProjectComponentCreateRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'creates polygons with the requested shape',
        setUp: () {
          when(
            () => componentRepository.createComponent(
              project.path,
              'Player',
              ComponentType.polygon,
              polygonShape: PolygonShape.square,
            ),
          ).thenAnswer((_) async => const PolygonComponent(name: 'Player'));
          when(() => componentRepository.getComponents(project.path))
              .thenAnswer((_) async => []);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested(
            'Player',
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
        ),
        verify: (_) => verify(
          () => componentRepository.createComponent(
            project.path,
            'Player',
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
        ).called(1),
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits created with the new component and reloaded components',
        setUp: () {
          when(
            () => componentRepository.createComponent(
              project.path,
              'Player',
              ComponentType.rectangle,
            ),
          ).thenAnswer((_) async => player);
          when(() => componentRepository.getComponents(project.path))
              .thenAnswer((_) async => [player]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested(
            'Player',
            ComponentType.rectangle,
          ),
        ),
        expect: () => const [
          ProjectState(
            status: ProjectStatus.created,
            components: [player],
            createdComponent: player,
          ),
        ],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits invalidName when the name is invalid',
        setUp: () => when(
          () => componentRepository.createComponent(
            project.path,
            '1',
            ComponentType.rectangle,
          ),
        ).thenThrow(const InvalidComponentNameException('1')),
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested('1', ComponentType.rectangle),
        ),
        expect: () => const [ProjectState(status: ProjectStatus.invalidName)],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits alreadyExists when the name is taken',
        setUp: () => when(
          () => componentRepository.createComponent(
            project.path,
            'Player',
            ComponentType.rectangle,
          ),
        ).thenThrow(const ComponentAlreadyExistsException('Player')),
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested(
            'Player',
            ComponentType.rectangle,
          ),
        ),
        expect: () => const [ProjectState(status: ProjectStatus.alreadyExists)],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits classConflict when the class of the name is taken',
        setUp: () =>
            when(
              () => componentRepository.createComponent(
                project.path,
                'player_ship_head',
                ComponentType.rectangle,
              ),
            ).thenThrow(
              const ComponentClassConflictException(
                'player_ship_head',
                'player_ship',
              ),
            ),
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested(
            'player_ship_head',
            ComponentType.rectangle,
          ),
        ),
        expect: () => const [
          ProjectState(
            status: ProjectStatus.classConflict,
            conflictingComponent: 'player_ship',
          ),
        ],
      );

      test('conflictingComponent is cleared when the status changes', () {
        const state = ProjectState(
          status: ProjectStatus.classConflict,
          conflictingComponent: 'player_ship',
        );

        expect(state.copyWith().conflictingComponent, equals('player_ship'));
        expect(
          state.copyWith(status: ProjectStatus.ready).conflictingComponent,
          isNull,
        );
      });

      blocTest<ProjectBloc, ProjectState>(
        'emits failure when creating fails',
        setUp: () => when(
          () => componentRepository.createComponent(
            project.path,
            'Player',
            ComponentType.rectangle,
          ),
        ).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectComponentCreateRequested(
            'Player',
            ComponentType.rectangle,
          ),
        ),
        expect: () => const [ProjectState(status: ProjectStatus.failure)],
      );
    });

    group(ProjectComponentDeleteRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'deletes the component and its code and emits the reloaded '
        'components',
        setUp: () {
          when(
            () => componentRepository.deleteComponent(
              project.path,
              player,
              outputPath: 'lib/game',
            ),
          ).thenAnswer((_) async {});
          when(() => componentRepository.getComponents(project.path))
              .thenAnswer((_) async => [enemy]);
        },
        build: buildBloc,
        seed: () => const ProjectState(
          status: ProjectStatus.ready,
          components: [enemy, player],
        ),
        act: (bloc) => bloc.add(const ProjectComponentDeleteRequested(player)),
        expect: () => const [
          ProjectState(status: ProjectStatus.ready, components: [enemy]),
        ],
        verify: (_) => verify(
          () => componentRepository.deleteComponent(
            project.path,
            player,
            outputPath: 'lib/game',
          ),
        ).called(1),
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits failure when deleting fails',
        setUp: () => when(
          () => componentRepository.deleteComponent(
            project.path,
            player,
            outputPath: 'lib/game',
          ),
        ).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentDeleteRequested(player)),
        expect: () => const [ProjectState(status: ProjectStatus.failure)],
      );
    });
  });
}
