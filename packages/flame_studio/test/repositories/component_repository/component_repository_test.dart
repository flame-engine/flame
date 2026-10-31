import 'dart:convert';

import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class _MockFileSystemClient() extends Mock implements FileSystemClient;

void main() {
  group(ComponentRepository, () {
    const projectPath = '/projects/my_game';
    final directory = p.join(
      projectPath,
      ComponentRepository.componentsDirectory,
    );
    String fileOf(String name) => p.join(directory, '$name.json');

    late FileSystemClient fileSystem;
    late ComponentRepository repository;

    final paletteFile = p.join(projectPath, ComponentRepository.paletteFile);
    final paletteCodeFile = p.join(
      projectPath,
      'lib/components',
      PaletteCodeGenerator.fileName,
    );
    const palette = Palette(
      colors: [PaletteColor(name: 'primary', color: 0xFFFF0000)],
    );

    setUp(() {
      fileSystem = _MockFileSystemClient();
      repository = ComponentRepository(fileSystem: fileSystem);
      when(() => fileSystem.fileExists(paletteFile))
          .thenAnswer((_) async => false);
    });

    group('getComponents', () {
      test('returns the components sorted by name', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Player'), fileOf('Enemy')]);
        when(() => fileSystem.readFile(fileOf('Player')))
            .thenAnswer((_) async => jsonEncode({'name': 'Player'}));
        when(() => fileSystem.readFile(fileOf('Enemy')))
            .thenAnswer((_) async => jsonEncode({'name': 'Enemy'}));

        expect(
          await repository.getComponents(projectPath),
          equals(const [
            RectangleComponent(name: 'Enemy'),
            RectangleComponent(name: 'Player'),
          ]),
        );
      });

      test('skips unreadable files', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Player'), fileOf('Broken')]);
        when(() => fileSystem.readFile(fileOf('Player')))
            .thenAnswer((_) async => jsonEncode({'name': 'Player'}));
        when(() => fileSystem.readFile(fileOf('Broken')))
            .thenAnswer((_) async => 'not json');

        expect(
          await repository.getComponents(projectPath),
          equals(const [RectangleComponent(name: 'Player')]),
        );
      });
    });

    group('createComponent', () {
      test('writes the component file and returns the component', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Enemy')]);
        when(() => fileSystem.readFile(fileOf('Enemy')))
            .thenAnswer((_) async => jsonEncode({'name': 'Enemy'}));
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});

        expect(
          await repository.createComponent(
            projectPath,
            'Player',
            ComponentType.rectangle,
          ),
          equals(const RectangleComponent(name: 'Player')),
        );
        verify(
          () => fileSystem.writeFile(
            fileOf('Player'),
            jsonEncode(const RectangleComponent(name: 'Player').toJson()),
          ),
        ).called(1);
      });

      test('throws an ArgumentError for hitboxes', () async {
        await expectLater(
          repository.createComponent(
            projectPath,
            'Player',
            ComponentType.rectangleHitbox,
          ),
          throwsArgumentError,
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });

      test('creates polygons with the given shape', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => []);
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});

        expect(
          await repository.createComponent(
            projectPath,
            'Player',
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
          equals(
            const PolygonComponent(
              name: 'Player',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ),
        );
      });

      for (final name in [
        '',
        '1Player',
        'My Player',
        'a/b',
        '../x',
        '_',
        '_1',
        // Its code would take the place of the palette's.
        'palette',
        'Palette',
      ]) {
        test('throws InvalidComponentNameException for "$name"', () {
          expect(
            () => repository.createComponent(
              projectPath,
              name,
              ComponentType.rectangle,
            ),
            throwsA(isA<InvalidComponentNameException>()),
          );
        });
      }

      for (final name in ['Player', 'player', 'PLAYER']) {
        test('throws ComponentAlreadyExistsException for "$name" '
            'when Player exists', () {
          when(() => fileSystem.listFiles(directory, extension: '.json'))
              .thenAnswer((_) async => [fileOf('Player')]);

          expect(
            () => repository.createComponent(
              projectPath,
              name,
              ComponentType.rectangle,
            ),
            throwsA(isA<ComponentAlreadyExistsException>()),
          );
        });
      }
    });

    for (final (name, existing) in [
      ('AB', const RectangleComponent(name: 'a_b')),
      (
        'player_ship_head',
        const RectangleComponent(
          name: 'player_ship',
          children: [RectangleComponent(name: 'head')],
        ),
      ),
    ]) {
      test('createComponent throws ComponentClassConflictException for '
          '"$name" when ${existing.name} generates its class', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf(existing.name)]);
        when(() => fileSystem.readFile(fileOf(existing.name)))
            .thenAnswer((_) async => jsonEncode(existing.toJson()));

        await expectLater(
          repository.createComponent(
            projectPath,
            name,
            ComponentType.rectangle,
          ),
          throwsA(
            isA<ComponentClassConflictException>()
                .having((e) => e.name, 'name', name)
                .having(
                  (e) => e.conflictingComponent,
                  'conflictingComponent',
                  existing.name,
                ),
          ),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });
    }

    group('saveComponent', () {
      test('writes the component file', () async {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
        const component = RectangleComponent(
          name: 'Player',
          size: ComponentSize(width: 10, height: 20),
        );

        await repository.saveComponent(projectPath, component);

        verify(
          () => fileSystem.writeFile(
            fileOf('Player'),
            jsonEncode(component.toJson()),
          ),
        ).called(1);
      });
    });

    group('writeComponentCode', () {
      const component = RectangleComponent(name: 'PlayerShip');
      const generator = ComponentCodeGenerator();
      final codeFile = p.join(
        projectPath,
        'lib/components',
        'player_ship.generated.dart',
      );

      setUp(() {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
      });

      test('writes the generated code to the output folder', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);

        await repository.writeComponentCode(
          projectPath,
          'lib/components',
          component,
        );

        verify(
          () => fileSystem.writeFile(codeFile, generator.generate(component)),
        ).called(1);
      });

      test('replaces previously generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => '${ComponentCodeGenerator.header}\n');

        await repository.writeComponentCode(
          projectPath,
          'lib/components',
          component,
        );

        verify(
          () => fileSystem.writeFile(codeFile, generator.generate(component)),
        ).called(1);
      });

      test('throws GeneratedFileConflictException and keeps a file that was '
          'not generated', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => 'class PlayerShip {}');

        await expectLater(
          repository.writeComponentCode(
            projectPath,
            'lib/components',
            component,
          ),
          throwsA(
            isA<GeneratedFileConflictException>().having(
              (e) => e.path,
              'path',
              codeFile,
            ),
          ),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });

      test('throws GeneratedFileConflictException for a component whose '
          'code would replace the palette', () async {
        await expectLater(
          repository.writeComponentCode(
            projectPath,
            'lib/components',
            const RectangleComponent(name: 'palette'),
          ),
          throwsA(isA<GeneratedFileConflictException>()),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });

      test('references the palette and writes its code when the component '
          'uses it', () async {
        const painted = RectangleComponent(
          name: 'PlayerShip',
          paint: ComponentPaint(paletteColor: 'primary'),
        );
        when(() => fileSystem.fileExists(paletteFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(paletteFile))
            .thenAnswer((_) async => jsonEncode(palette.toJson()));
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);
        when(() => fileSystem.fileExists(paletteCodeFile))
            .thenAnswer((_) async => false);

        await repository.writeComponentCode(
          projectPath,
          'lib/components',
          painted,
        );

        verify(
          () => fileSystem.writeFile(
            paletteCodeFile,
            const PaletteCodeGenerator().generate(palette),
          ),
        ).called(1);
        verify(
          () => fileSystem.writeFile(
            codeFile,
            generator.generate(painted, palette: palette),
          ),
        ).called(1);
      });
    });

    group('getPalette', () {
      test('returns the stored palette', () async {
        when(() => fileSystem.fileExists(paletteFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(paletteFile))
            .thenAnswer((_) async => jsonEncode(palette.toJson()));

        expect(await repository.getPalette(projectPath), equals(palette));
      });

      test('returns an empty palette when none was saved', () async {
        expect(
          await repository.getPalette(projectPath),
          equals(const Palette()),
        );
      });

      test('returns an empty palette when unreadable', () async {
        when(() => fileSystem.fileExists(paletteFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(paletteFile))
            .thenAnswer((_) async => 'not json');

        expect(
          await repository.getPalette(projectPath),
          equals(const Palette()),
        );
      });
    });

    group('savePalette', () {
      test('writes the palette file', () async {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});

        await repository.savePalette(projectPath, palette);

        verify(
          () => fileSystem.writeFile(paletteFile, jsonEncode(palette.toJson())),
        ).called(1);
      });

      test('throws InvalidPaletteException for invalid names', () async {
        await expectLater(
          repository.savePalette(
            projectPath,
            const Palette(colors: [PaletteColor(name: 'class', color: 0)]),
          ),
          throwsA(isA<InvalidPaletteException>()),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });
    });

    group('writePaletteCode', () {
      setUp(() {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
      });

      test('writes the generated code to the output folder', () async {
        when(() => fileSystem.fileExists(paletteCodeFile))
            .thenAnswer((_) async => false);

        await repository.writePaletteCode(
          projectPath,
          'lib/components',
          palette,
        );

        verify(
          () => fileSystem.writeFile(
            paletteCodeFile,
            const PaletteCodeGenerator().generate(palette),
          ),
        ).called(1);
      });

      test('throws GeneratedFileConflictException and keeps a file that was '
          'not generated', () async {
        when(() => fileSystem.fileExists(paletteCodeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(paletteCodeFile))
            .thenAnswer((_) async => 'class GamePalette {}');

        await expectLater(
          repository.writePaletteCode(projectPath, 'lib/components', palette),
          throwsA(isA<GeneratedFileConflictException>()),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });
    });

    group('isComponentCodeUpToDate', () {
      const component = RectangleComponent(name: 'PlayerShip');
      const generator = ComponentCodeGenerator();
      final codeFile = p.join(
        projectPath,
        'lib/components',
        'player_ship.generated.dart',
      );

      Future<bool> isUpToDate() => repository.isComponentCodeUpToDate(
        projectPath,
        'lib/components',
        component,
      );

      test('is false without generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);

        expect(await isUpToDate(), isFalse);
      });

      test('is true when the file holds the current code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => generator.generate(component));

        expect(await isUpToDate(), isTrue);
      });

      test('is false when the file holds other code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => '// hand-written');

        expect(await isUpToDate(), isFalse);
      });
    });

    group('deleteComponent', () {
      const component = RectangleComponent(name: 'Player');
      final codeFile = p.join(projectPath, 'lib/game', 'player.generated.dart');

      setUp(() {
        when(() => fileSystem.deleteFile(any())).thenAnswer((_) async {});
      });

      Future<void> delete() => repository.deleteComponent(
        projectPath,
        component,
        outputPath: 'lib/game',
      );

      test('deletes the component file and its generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => '${ComponentCodeGenerator.header}\n');

        await delete();

        verify(() => fileSystem.deleteFile(fileOf('Player'))).called(1);
        verify(() => fileSystem.deleteFile(codeFile)).called(1);
      });

      test('works when there is no generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);

        await delete();

        verify(() => fileSystem.deleteFile(fileOf('Player'))).called(1);
        verifyNever(() => fileSystem.deleteFile(codeFile));
      });

      test('keeps a file that was not generated', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => 'class Player {}');

        await delete();

        verifyNever(() => fileSystem.deleteFile(codeFile));
      });
    });
  });
}
