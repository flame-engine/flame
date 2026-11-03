import 'dart:convert';

import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKeyValueStorageClient()
    extends Mock
    implements KeyValueStorageClient;

class _MockFileSystemClient() extends Mock implements FileSystemClient;

String _encode(List<String> paths) =>
    jsonEncode([for (final path in paths) Project(path: path).toJson()]);

void main() {
  group(ProjectRepository, () {
    const key = ProjectRepository.recentProjectsKey;

    late KeyValueStorageClient storage;
    late FileSystemClient fileSystem;
    late ProjectRepository repository;

    setUp(() {
      storage = _MockKeyValueStorageClient();
      fileSystem = _MockFileSystemClient();
      repository = ProjectRepository(storage: storage, fileSystem: fileSystem);

      when(() => storage.write(any(), any())).thenAnswer((_) async {});
      when(() => fileSystem.directoryExists(any()))
          .thenAnswer((_) async => true);
    });

    group('getRecentProjects', () {
      test('returns an empty list when nothing is stored', () async {
        when(() => storage.read(key)).thenAnswer((_) async => null);

        expect(await repository.getRecentProjects(), isEmpty);
      });

      test('returns an empty list when stored data is corrupt', () async {
        when(() => storage.read(key)).thenAnswer((_) async => 'not json');

        expect(await repository.getRecentProjects(), isEmpty);
      });

      test('returns the stored projects', () async {
        when(() => storage.read(key))
            .thenAnswer((_) async => _encode(['/a', '/b']));

        expect(
          await repository.getRecentProjects(),
          equals(const [Project(path: '/a'), Project(path: '/b')]),
        );
      });
    });

    group('pickProject', () {
      test('returns the picked project', () async {
        when(() => fileSystem.pickDirectory()).thenAnswer((_) async => '/a');

        expect(await repository.pickProject(), const Project(path: '/a'));
      });

      test('returns null when cancelled', () async {
        when(() => fileSystem.pickDirectory()).thenAnswer((_) async => null);

        expect(await repository.pickProject(), isNull);
      });
    });

    group('openProject', () {
      test('adds the project to the top of the recent projects', () async {
        when(() => storage.read(key)).thenAnswer((_) async => _encode(['/a']));

        await repository.openProject(const Project(path: '/b'));

        verify(() => storage.write(key, _encode(['/b', '/a']))).called(1);
      });

      test('moves an already recent project to the top', () async {
        when(() => storage.read(key))
            .thenAnswer((_) async => _encode(['/a', '/b', '/c']));

        await repository.openProject(const Project(path: '/b'));

        verify(() => storage.write(key, _encode(['/b', '/a', '/c']))).called(1);
      });

      test(
        'keeps at most ${ProjectRepository.maxRecentProjects} projects',
        () async {
          final paths = [for (var i = 0; i < 10; i++) '/$i'];
          when(() => storage.read(key)).thenAnswer((_) async => _encode(paths));

          await repository.openProject(const Project(path: '/new'));

          verify(() => storage.write(key, _encode(['/new', ...paths.take(9)])))
              .called(1);
        },
      );

      test(
        'removes the project and throws when its folder does not exist',
        () async {
          when(() => storage.read(key))
              .thenAnswer((_) async => _encode(['/a', '/b']));
          when(() => fileSystem.directoryExists('/b'))
              .thenAnswer((_) async => false);

          await expectLater(
            repository.openProject(const Project(path: '/b')),
            throwsA(
              isA<ProjectNotFoundException>().having(
                (e) => e.project,
                'project',
                const Project(path: '/b'),
              ),
            ),
          );
          verify(() => storage.write(key, _encode(['/a']))).called(1);
        },
      );
    });
    group('settings', () {
      const project = Project(path: '/projects/my_game');
      const settingsPath = '/projects/my_game/.flame_studio/settings.json';

      setUp(() {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
      });

      group('getSettings', () {
        test('returns the defaults when no settings were saved', () async {
          when(() => fileSystem.fileExists(settingsPath))
              .thenAnswer((_) async => false);

          expect(
            await repository.getSettings(project),
            const ProjectSettings(),
          );
        });

        test('returns the defaults when the settings are corrupt', () async {
          when(() => fileSystem.fileExists(settingsPath))
              .thenAnswer((_) async => true);
          when(() => fileSystem.readFile(settingsPath))
              .thenAnswer((_) async => 'not json');

          expect(
            await repository.getSettings(project),
            const ProjectSettings(),
          );
        });

        test('returns the saved settings', () async {
          when(() => fileSystem.fileExists(settingsPath))
              .thenAnswer((_) async => true);
          when(() => fileSystem.readFile(settingsPath))
              .thenAnswer((_) async => '{"outputPath":"lib/game"}');

          expect(
            await repository.getSettings(project),
            const ProjectSettings(outputPath: 'lib/game'),
          );
        });
      });

      group('saveSettings', () {
        test('writes the normalized settings', () async {
          final saved = await repository.saveSettings(
            project,
            const ProjectSettings(outputPath: ' lib/./game/components/ '),
          );

          expect(
            saved,
            const ProjectSettings(outputPath: 'lib/game/components'),
          );
          verify(
            () => fileSystem.writeFile(
              settingsPath,
              '{"outputPath":"lib/game/components"}',
            ),
          ).called(1);
        });

        for (final path in [
          '',
          '  ',
          '.',
          'lib/..',
          '..',
          '../other',
          '/abs',
        ]) {
          test('throws for "$path"', () async {
            await expectLater(
              repository.saveSettings(
                project,
                ProjectSettings(outputPath: path),
              ),
              throwsA(
                isA<InvalidOutputPathException>().having(
                  (e) => e.path,
                  'path',
                  path,
                ),
              ),
            );
            verifyNever(() => fileSystem.writeFile(any(), any()));
          });
        }
      });

      group('pickOutputPath', () {
        test('returns null when cancelled', () async {
          when(() => fileSystem.pickDirectory()).thenAnswer((_) async => null);

          expect(await repository.pickOutputPath(project), isNull);
        });

        test('returns the picked folder relative to the project', () async {
          when(() => fileSystem.pickDirectory())
              .thenAnswer((_) async => '/projects/my_game/lib/game');

          expect(await repository.pickOutputPath(project), 'lib/game');
        });

        for (final picked in ['/projects/other', '/projects/my_game']) {
          test('throws when picking "$picked"', () async {
            when(() => fileSystem.pickDirectory())
                .thenAnswer((_) async => picked);

            await expectLater(
              repository.pickOutputPath(project),
              throwsA(isA<InvalidOutputPathException>()),
            );
          });
        }
      });
    });
  });
}
