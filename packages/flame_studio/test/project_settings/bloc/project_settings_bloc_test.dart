import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

void main() {
  group(ProjectSettingsBloc, () {
    const project = Project(path: '/projects/my_game');
    const ready = ProjectSettingsState(status: ProjectSettingsStatus.ready);

    late ProjectRepository projectRepository;

    setUpAll(() => registerFallbackValue(const ProjectSettings()));

    setUp(() {
      projectRepository = _MockProjectRepository();
    });

    ProjectSettingsBloc buildBloc() => ProjectSettingsBloc(
      project: project,
      projectRepository: projectRepository,
    );

    test('initial state is ProjectSettingsState', () {
      expect(buildBloc().state, equals(const ProjectSettingsState()));
    });

    group(ProjectSettingsRequested, () {
      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits [loading, ready] with the stored output path',
        setUp: () => when(() => projectRepository.getSettings(project))
            .thenAnswer(
              (_) async => const ProjectSettings(outputPath: 'lib/game'),
            ),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectSettingsRequested()),
        expect: () => const [
          ProjectSettingsState(status: ProjectSettingsStatus.loading),
          ProjectSettingsState(
            status: ProjectSettingsStatus.ready,
            outputPath: 'lib/game',
          ),
        ],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits [loading, failure] when loading fails',
        setUp: () =>
            when(() => projectRepository.getSettings(project))
                .thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectSettingsRequested()),
        expect: () => const [
          ProjectSettingsState(status: ProjectSettingsStatus.loading),
          ProjectSettingsState(status: ProjectSettingsStatus.failure),
        ],
      );
    });

    group(ProjectSettingsOutputPathChanged, () {
      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'updates the output path and clears errors',
        build: buildBloc,
        seed: () => const ProjectSettingsState(
          status: ProjectSettingsStatus.invalidOutputPath,
        ),
        act: (bloc) => bloc.add(const ProjectSettingsOutputPathChanged('lib')),
        expect: () => const [
          ProjectSettingsState(
            status: ProjectSettingsStatus.ready,
            outputPath: 'lib',
          ),
        ],
      );
    });

    group(ProjectSettingsBrowseRequested, () {
      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits the picked output path',
        setUp: () =>
            when(() => projectRepository.pickOutputPath(project))
                .thenAnswer((_) async => 'lib/game'),
        build: buildBloc,
        seed: () => ready,
        act: (bloc) => bloc.add(const ProjectSettingsBrowseRequested()),
        expect: () => const [
          ProjectSettingsState(
            status: ProjectSettingsStatus.ready,
            outputPath: 'lib/game',
          ),
        ],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits nothing when cancelled',
        setUp: () =>
            when(() => projectRepository.pickOutputPath(project))
                .thenAnswer((_) async => null),
        build: buildBloc,
        seed: () => ready,
        act: (bloc) => bloc.add(const ProjectSettingsBrowseRequested()),
        expect: () => const <ProjectSettingsState>[],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits invalidOutputPath when picking a folder outside the project',
        setUp: () =>
            when(() => projectRepository.pickOutputPath(project))
                .thenThrow(const InvalidOutputPathException('/other')),
        build: buildBloc,
        seed: () => ready,
        act: (bloc) => bloc.add(const ProjectSettingsBrowseRequested()),
        expect: () => const [
          ProjectSettingsState(status: ProjectSettingsStatus.invalidOutputPath),
        ],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits failure when picking fails',
        setUp: () =>
            when(() => projectRepository.pickOutputPath(project))
                .thenThrow(Exception()),
        build: buildBloc,
        seed: () => ready,
        act: (bloc) => bloc.add(const ProjectSettingsBrowseRequested()),
        expect: () => const [
          ProjectSettingsState(status: ProjectSettingsStatus.failure),
        ],
      );
    });

    group(ProjectSettingsSubmitted, () {
      const seed = ProjectSettingsState(
        status: ProjectSettingsStatus.ready,
        outputPath: 'lib/./game',
      );
      const saving = ProjectSettingsState(
        status: ProjectSettingsStatus.saving,
        outputPath: 'lib/./game',
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits [saving, saved] with the normalized output path',
        setUp: () =>
            when(
              () => projectRepository.saveSettings(
                project,
                const ProjectSettings(outputPath: 'lib/./game'),
              ),
            ).thenAnswer(
              (_) async => const ProjectSettings(outputPath: 'lib/game'),
            ),
        build: buildBloc,
        seed: () => seed,
        act: (bloc) => bloc.add(const ProjectSettingsSubmitted()),
        expect: () => const [
          saving,
          ProjectSettingsState(
            status: ProjectSettingsStatus.saved,
            outputPath: 'lib/game',
          ),
        ],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits [saving, invalidOutputPath] when the path is invalid',
        setUp: () =>
            when(() => projectRepository.saveSettings(project, any()))
                .thenThrow(const InvalidOutputPathException('lib/./game')),
        build: buildBloc,
        seed: () => seed,
        act: (bloc) => bloc.add(const ProjectSettingsSubmitted()),
        expect: () => const [
          saving,
          ProjectSettingsState(
            status: ProjectSettingsStatus.invalidOutputPath,
            outputPath: 'lib/./game',
          ),
        ],
      );

      blocTest<ProjectSettingsBloc, ProjectSettingsState>(
        'emits [saving, failure] when saving fails',
        setUp: () =>
            when(() => projectRepository.saveSettings(project, any()))
                .thenThrow(Exception()),
        build: buildBloc,
        seed: () => seed,
        act: (bloc) => bloc.add(const ProjectSettingsSubmitted()),
        expect: () => const [
          saving,
          ProjectSettingsState(
            status: ProjectSettingsStatus.failure,
            outputPath: 'lib/./game',
          ),
        ],
      );
    });
  });
}
