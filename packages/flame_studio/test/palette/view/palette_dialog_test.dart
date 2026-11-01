import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/palette/palette.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockPaletteBloc()
    extends MockBloc<PaletteEvent, PaletteState>
    implements PaletteBloc;

void main() {
  const project = Project(path: '/projects/my_game');
  const component = RectangleComponent(name: 'Player');
  const primary = PaletteColor(name: 'primary', color: 0xFFFF0000);
  const accent = PaletteColor(name: 'accent', color: 0xFF00FF00);

  setUpAll(() => registerFallbackValue(const PaletteStarted()));

  group(PaletteDialog, () {
    testWidgets('show opens the dialog with the stored palette', (
      tester,
    ) async {
      final componentRepository = _MockComponentRepository();
      when(() => componentRepository.getPalette(project.path))
          .thenAnswer((_) async => const Palette(colors: [primary]));
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => const []);

      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => PaletteDialog.show(
              context,
              project: project,
              component: component,
            ),
            child: const Text('open'),
          ),
        ),
        componentRepository: componentRepository,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(PaletteView), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'primary'), findsOneWidget);
    });
  });

  group(PaletteView, () {
    const ready = PaletteState(
      status: PaletteStatus.ready,
      savedPalette: Palette(colors: [primary, accent]),
      usage: {
        'primary': ['Enemy', 'Player'],
      },
      entries: [
        PaletteEntry(id: 0, color: primary, savedName: 'primary'),
        PaletteEntry(id: 1, color: accent, savedName: 'accent'),
      ],
    );

    late PaletteBloc bloc;

    setUp(() {
      bloc = _MockPaletteBloc();
      when(() => bloc.state).thenReturn(ready);
    });

    Widget buildSubject() => Scaffold(
      body: BlocProvider.value(value: bloc, child: const PaletteView()),
    );

    testWidgets('shows a progress indicator while loading', (tester) async {
      when(() => bloc.state)
          .thenReturn(const PaletteState(status: PaletteStatus.loading));
      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('explains an empty palette', (tester) async {
      when(() => bloc.state)
          .thenReturn(const PaletteState(status: PaletteStatus.ready));
      await tester.pumpApp(buildSubject());

      expect(find.textContaining('No colors yet'), findsOneWidget);
    });

    testWidgets('locks the colors used by components', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('Used by Enemy, Player'), findsOneWidget);
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].readOnly, isTrue);
      expect(fields[1].readOnly, isFalse);

      final removeButtons = tester
          .widgetList<IconButton>(
            find.widgetWithIcon(IconButton, Icons.delete_outline),
          )
          .toList();
      expect(removeButtons[0].onPressed, isNull);
      expect(removeButtons[1].onPressed, isNotNull);
    });

    testWidgets('dispatches edits', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.enterText(find.byType(TextField).last, 'highlight');
      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.delete_outline).last,
      );
      await tester.tap(find.text('Add color'));
      await tester.tap(find.text('Save'));

      verify(() => bloc.add(const PaletteColorRenamed(1, 'highlight')))
          .called(1);
      verify(() => bloc.add(const PaletteColorRemoved(1))).called(1);
      verify(() => bloc.add(const PaletteColorAdded())).called(1);
      verify(() => bloc.add(const PaletteSaveRequested())).called(1);
    });

    testWidgets('shows name errors and disables saving', (tester) async {
      when(() => bloc.state).thenReturn(
        ready.copyWith(
          entries: const [
            PaletteEntry(id: 0, color: primary, savedName: 'primary'),
            PaletteEntry(id: 1, color: PaletteColor(name: 'primary', color: 0)),
            PaletteEntry(id: 2, color: PaletteColor(name: '1st', color: 0)),
          ],
        ),
      );
      await tester.pumpApp(buildSubject());

      expect(find.text('Another color has this name'), findsOneWidget);
      expect(find.text('Must be a valid Dart identifier'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows a failure', (tester) async {
      when(() => bloc.state)
          .thenReturn(ready.copyWith(status: PaletteStatus.failure));
      await tester.pumpApp(buildSubject());

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    for (final (status, message) in [
      (PaletteStatus.saved, null),
      (PaletteStatus.codeConflict, 'not generated by the editor'),
      (PaletteStatus.codeFailure, 'could not be generated'),
    ]) {
      testWidgets('pops with the palette when $status', (tester) async {
        final saved = ready.copyWith(status: status);
        whenListen(bloc, Stream.value(saved), initialState: ready);
        Palette? result;

        await tester.pumpApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await showDialog<Palette>(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const PaletteView(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.byType(PaletteView), findsNothing);
        expect(result, equals(saved.palette));
        if (message != null) {
          expect(find.textContaining(message), findsOneWidget);
        }
      });
    }

    testWidgets('cancel pops without a palette', (tester) async {
      Palette? result = const Palette(colors: [primary]);
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showDialog<Palette>(
              context: context,
              builder: (_) =>
                  BlocProvider.value(value: bloc, child: const PaletteView()),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
