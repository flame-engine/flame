import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/palette/palette.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockProjectRepository() extends Mock implements ProjectRepository;

void main() {
  setUpAll(() => registerFallbackValue(const Palette()));

  group(PaletteBloc, () {
    const project = Project(path: '/projects/my_game');
    const primary = PaletteColor(name: 'primary', color: 0xFFFF0000);
    const accent = PaletteColor(name: 'accent', color: 0xFF00FF00);
    const palette = Palette(colors: [primary, accent]);
    // Saved without colors, but uses `primary` in the editor.
    const edited = RectangleComponent(
      name: 'Player',
      paint: ComponentPaint(paletteColor: 'primary'),
    );
    const enemy = RectangleComponent(
      name: 'Enemy',
      paint: ComponentPaint(paletteColor: 'primary'),
    );
    const loaded = PaletteState(
      status: PaletteStatus.ready,
      savedPalette: palette,
      usage: {
        'primary': ['Enemy', 'Player'],
      },
      entries: [
        PaletteEntry(id: 0, color: primary, savedName: 'primary'),
        PaletteEntry(id: 1, color: accent, savedName: 'accent'),
      ],
    );

    late ComponentRepository componentRepository;
    late ProjectRepository projectRepository;

    setUp(() {
      componentRepository = _MockComponentRepository();
      projectRepository = _MockProjectRepository();
      when(() => componentRepository.getPalette(project.path))
          .thenAnswer((_) async => palette);
      when(() => componentRepository.getComponents(project.path)).thenAnswer(
        (_) async => const [enemy, RectangleComponent(name: 'Player')],
      );
      when(
        () => projectRepository.getSettings(project),
      ).thenAnswer((_) async => const ProjectSettings(outputPath: 'lib/game'));
      when(() => componentRepository.savePalette(any(), any()))
          .thenAnswer((_) async {});
      when(() => componentRepository.writePaletteCode(any(), any(), any()))
          .thenAnswer((_) async {});
    });

    PaletteBloc buildBloc() => PaletteBloc(
      project: project,
      editedComponent: edited,
      componentRepository: componentRepository,
      projectRepository: projectRepository,
    );

    /// A bloc whose palette was loaded, with entries 0 and 1.
    Future<PaletteBloc> loadedBloc() async {
      final bloc = buildBloc()..add(const PaletteStarted());
      await bloc.stream.firstWhere((s) => s.status == PaletteStatus.ready);
      return bloc;
    }

    blocTest<PaletteBloc, PaletteState>(
      'PaletteStarted loads the palette and which components use it, with '
      'the unsaved changes of the edited component',
      build: buildBloc,
      act: (bloc) => bloc.add(const PaletteStarted()),
      expect: () => const [PaletteState(status: PaletteStatus.loading), loaded],
      verify: (bloc) {
        expect(bloc.state.palette, equals(palette));
        expect(bloc.state.hasChanges, isFalse);
        expect(bloc.state.usersOf(bloc.state.entries[0]), ['Enemy', 'Player']);
        expect(bloc.state.usersOf(bloc.state.entries[1]), isEmpty);
      },
    );

    blocTest<PaletteBloc, PaletteState>(
      'PaletteStarted fails when the palette can not be loaded',
      setUp: () =>
          when(() => componentRepository.getPalette(project.path))
              .thenThrow(Exception()),
      build: buildBloc,
      act: (bloc) => bloc.add(const PaletteStarted()),
      expect: () => const [
        PaletteState(status: PaletteStatus.loading),
        PaletteState(status: PaletteStatus.failure),
      ],
    );

    test('ignores edits before loading', () async {
      final bloc = buildBloc()
        ..add(const PaletteColorAdded())
        ..add(const PaletteColorRemoved(0))
        ..add(const PaletteColorValueChanged(0, 1));
      await pumpEventQueue();

      expect(bloc.state, equals(const PaletteState()));
      expect(bloc.state.canSave, isFalse);
    });

    test('PaletteColorAdded adds a white color with a unique name', () async {
      final bloc = await loadedBloc();
      bloc.add(const PaletteColorAdded());
      await pumpEventQueue();

      expect(
        bloc.state.entries.last,
        equals(
          const PaletteEntry(
            id: 2,
            color: PaletteColor(name: 'color1', color: 0xFFFFFFFF),
          ),
        ),
      );
      expect(bloc.state.hasChanges, isTrue);
      expect(bloc.state.usersOf(bloc.state.entries.last), isEmpty);
    });

    test('PaletteColorRenamed renames colors that are not used', () async {
      final bloc = await loadedBloc();
      bloc
        ..add(const PaletteColorRenamed(1, 'highlight'))
        ..add(const PaletteColorRenamed(0, 'main'));
      await pumpEventQueue();

      expect(
        bloc.state.palette.colors.map((c) => c.name),
        equals(['primary', 'highlight']),
      );
    });

    test(
      'PaletteColorRenamed keeps invalid names, which prevent saving',
      () async {
        final bloc = await loadedBloc();
        bloc.add(const PaletteColorRenamed(1, 'primary'));
        await pumpEventQueue();

        expect(bloc.state.palette.colors.last.name, equals('primary'));
        expect(bloc.state.canSave, isFalse);
      },
    );

    test('PaletteColorValueChanged changes any color', () async {
      final bloc = await loadedBloc();
      bloc.add(const PaletteColorValueChanged(0, 0xFF0000FF));
      await pumpEventQueue();

      expect(bloc.state.palette.colorOf('primary'), equals(0xFF0000FF));
    });

    test('PaletteColorRemoved removes colors that are not used', () async {
      final bloc = await loadedBloc();
      bloc
        ..add(const PaletteColorRemoved(0))
        ..add(const PaletteColorRemoved(1));
      await pumpEventQueue();

      expect(bloc.state.palette, equals(const Palette(colors: [primary])));
    });

    test('PaletteSaveRequested saves the palette and its code', () async {
      final bloc = await loadedBloc();
      bloc
        ..add(const PaletteColorRenamed(1, 'highlight'))
        ..add(const PaletteSaveRequested());
      await bloc.stream.firstWhere((s) => s.status == PaletteStatus.saved);

      const saved = Palette(
        colors: [
          primary,
          PaletteColor(name: 'highlight', color: 0xFF00FF00),
        ],
      );
      verify(() => componentRepository.savePalette(project.path, saved))
          .called(1);
      verify(
        () => componentRepository.writePaletteCode(
          project.path,
          'lib/game',
          saved,
        ),
      ).called(1);
      expect(bloc.state.savedPalette, equals(saved));
      expect(bloc.state.entries.last.savedName, equals('highlight'));
      expect(bloc.state.hasChanges, isFalse);
    });

    test('PaletteSaveRequested does nothing with invalid names', () async {
      final bloc = await loadedBloc();
      bloc
        ..add(const PaletteColorRenamed(1, 'class'))
        ..add(const PaletteSaveRequested());
      await pumpEventQueue();

      verifyNever(() => componentRepository.savePalette(any(), any()));
    });

    for (final (exception, status) in [
      (const GeneratedFileConflictException('x'), PaletteStatus.codeConflict),
      (Exception(), PaletteStatus.codeFailure),
    ]) {
      test('PaletteSaveRequested reports $status when the code is not '
          'generated', () async {
        when(() => componentRepository.writePaletteCode(any(), any(), any()))
            .thenThrow(exception);
        final bloc = await loadedBloc();
        bloc.add(const PaletteSaveRequested());
        await pumpEventQueue();

        expect(bloc.state.status, equals(status));
        expect(bloc.state.status.isSaved, isTrue);
      });
    }

    test('PaletteSaveRequested fails when the palette is not saved', () async {
      when(() => componentRepository.savePalette(any(), any()))
          .thenThrow(Exception());
      final bloc = await loadedBloc();
      bloc.add(const PaletteSaveRequested());
      await pumpEventQueue();

      expect(bloc.state.status, equals(PaletteStatus.failure));
      verifyNever(
        () => componentRepository.writePaletteCode(any(), any(), any()),
      );
    });
  });
}
