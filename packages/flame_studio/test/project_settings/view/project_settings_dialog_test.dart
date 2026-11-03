import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockProjectSettingsBloc()
    extends MockBloc<ProjectSettingsEvent, ProjectSettingsState>
    implements ProjectSettingsBloc;

void main() {
  const project = Project(path: '/projects/my_game');

  setUpAll(() => registerFallbackValue(const ProjectSettingsRequested()));

  group(ProjectSettingsDialog, () {
    testWidgets('show opens the dialog with the stored settings', (
      tester,
    ) async {
      final projectRepository = _MockProjectRepository();
      when(
        () => projectRepository.getSettings(project),
      ).thenAnswer((_) async => const ProjectSettings(outputPath: 'lib/game'));

      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => ProjectSettingsDialog.show(context, project),
            child: const Text('open'),
          ),
        ),
        projectRepository: projectRepository,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectSettingsView), findsOneWidget);
      expect(find.text('Project settings'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'lib/game'), findsOneWidget);
    });
  });

  group(ProjectSettingsView, () {
    const ready = ProjectSettingsState(status: ProjectSettingsStatus.ready);

    late ProjectSettingsBloc bloc;

    setUp(() {
      bloc = _MockProjectSettingsBloc();
      when(() => bloc.state).thenReturn(ready);
    });

    Widget buildSubject() =>
        BlocProvider.value(value: bloc, child: const ProjectSettingsView());

    /// Pumps the view inside a dialog so that popping can be observed.
    Future<void> pumpDialog(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => buildSubject(),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows a progress indicator while loading', (tester) async {
      when(() => bloc.state).thenReturn(
        const ProjectSettingsState(status: ProjectSettingsStatus.loading),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      final save = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(save.onPressed, isNull);
    });

    testWidgets('shows the output path', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.widgetWithText(TextField, 'lib/components'), findsOneWidget);
    });

    testWidgets('dispatches changes to the output path', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.enterText(find.byType(TextField), 'lib/game');

      verify(() => bloc.add(const ProjectSettingsOutputPathChanged('lib/game')))
          .called(1);
    });

    testWidgets('updates the text field when the output path changes', (
      tester,
    ) async {
      whenListen(
        bloc,
        Stream.value(
          const ProjectSettingsState(
            status: ProjectSettingsStatus.ready,
            outputPath: 'lib/picked',
          ),
        ),
        initialState: ready,
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.widgetWithText(TextField, 'lib/picked'), findsOneWidget);
    });

    testWidgets('browses for the output path', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.byTooltip('Browse'));

      verify(() => bloc.add(const ProjectSettingsBrowseRequested())).called(1);
    });

    testWidgets('saves on tap', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Save'));

      verify(() => bloc.add(const ProjectSettingsSubmitted())).called(1);
    });

    testWidgets('saves with the keyboard', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.showKeyboard(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(() => bloc.add(const ProjectSettingsSubmitted())).called(1);
    });

    testWidgets('disables save while the output path is empty', (tester) async {
      when(() => bloc.state).thenReturn(
        const ProjectSettingsState(
          status: ProjectSettingsStatus.ready,
          outputPath: ' ',
        ),
      );

      await tester.pumpApp(buildSubject());
      await tester.showKeyboard(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final save = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(save.onPressed, isNull);
      verifyNever(() => bloc.add(const ProjectSettingsSubmitted()));
    });

    for (final (status, message) in [
      (ProjectSettingsStatus.invalidOutputPath, 'Must be a folder inside'),
      (ProjectSettingsStatus.failure, 'Something went wrong'),
    ]) {
      testWidgets('shows an error on ${status.name}', (tester) async {
        when(() => bloc.state).thenReturn(ProjectSettingsState(status: status));

        await tester.pumpApp(buildSubject());

        expect(find.textContaining(message), findsOneWidget);
      });
    }

    testWidgets('closes when saved', (tester) async {
      final controller = StreamController<ProjectSettingsState>();
      whenListen(bloc, controller.stream, initialState: ready);

      await pumpDialog(tester);
      expect(find.byType(ProjectSettingsView), findsOneWidget);

      controller.add(
        const ProjectSettingsState(status: ProjectSettingsStatus.saved),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProjectSettingsView), findsNothing);
      await controller.close();
    });

    testWidgets('closes on cancel', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectSettingsView), findsNothing);
      verifyNever(() => bloc.add(any()));
    });
  });
}
