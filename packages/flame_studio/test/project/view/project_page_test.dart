import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/component_editor/component_editor.dart';
import 'package:flame_studio/project/project.dart';
import 'package:flame_studio/project/widgets/widgets.dart';
import 'package:flame_studio/project_settings/project_settings.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockProjectBloc()
    extends MockBloc<ProjectEvent, ProjectState>
    implements ProjectBloc;

void main() {
  const project = Project(path: '/projects/my_game');
  const player = RectangleComponent(name: 'Player');

  setUpAll(() => registerFallbackValue(const ProjectComponentsRequested()));

  group(ProjectPage, () {
    testWidgets('loads the components', (tester) async {
      final componentRepository = _MockComponentRepository();
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => [player]);

      await tester.pumpApp(
        const ProjectPage(project: project),
        componentRepository: componentRepository,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProjectView), findsOneWidget);
      expect(find.text('Player'), findsOneWidget);
    });

    testWidgets('route can be pushed and popped', (tester) async {
      final componentRepository = _MockComponentRepository();
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => []);

      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context).push(ProjectPage.route(project)),
            child: const Text('open'),
          ),
        ),
        componentRepository: componentRepository,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ProjectPage), findsNothing);
    });
  });

  group(ProjectView, () {
    late ProjectBloc projectBloc;
    late ComponentRepository componentRepository;
    late ProjectRepository projectRepository;

    setUp(() {
      // The editor opened from the view loads the components and checks
      // the generated code too.
      componentRepository = _MockComponentRepository();
      projectRepository = _MockProjectRepository();
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => [player]);
      when(() => componentRepository.getPalette(project.path))
          .thenAnswer((_) async => const Palette());
      when(() => projectRepository.getSettings(project))
          .thenAnswer((_) async => const ProjectSettings());
      when(
        () => componentRepository.isComponentCodeUpToDate(
          project.path,
          const ProjectSettings().outputPath,
          player,
        ),
      ).thenAnswer((_) async => true);
      projectBloc = _MockProjectBloc();
      when(() => projectBloc.state)
          .thenReturn(const ProjectState(status: ProjectStatus.ready));
    });

    Widget buildSubject() => BlocProvider.value(
      value: projectBloc,
      child: const ProjectView(project: project),
    );

    testWidgets('shows the project name', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('my_game'), findsOneWidget);
    });

    testWidgets('shows a progress indicator while loading', (tester) async {
      when(() => projectBloc.state)
          .thenReturn(const ProjectState(status: ProjectStatus.loading));

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows an empty message without components', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.text('No components yet'), findsOneWidget);
    });

    testWidgets('shows the components', (tester) async {
      when(() => projectBloc.state).thenReturn(
        const ProjectState(
          status: ProjectStatus.ready,
          components: [
            RectangleComponent(name: 'Enemy'),
            player,
          ],
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(ComponentTile), findsNWidgets(2));
      expect(find.text('Enemy'), findsOneWidget);
      expect(find.text('Player'), findsOneWidget);
    });

    testWidgets('opens the settings', (tester) async {
      final projectRepository = _MockProjectRepository();
      when(() => projectRepository.getSettings(project))
          .thenAnswer((_) async => const ProjectSettings());

      await tester.pumpApp(
        buildSubject(),
        projectRepository: projectRepository,
      );

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectSettingsDialog), findsOneWidget);
    });

    testWidgets(
      'opens the editor on edit and reloads components when coming back',
      (tester) async {
        when(() => projectBloc.state).thenReturn(
          const ProjectState(status: ProjectStatus.ready, components: [player]),
        );

        await tester.pumpApp(
          buildSubject(),
          componentRepository: componentRepository,
          projectRepository: projectRepository,
        );
        await tester.tap(find.byTooltip('Edit'));
        await tester.pumpRouteTransition();

        expect(find.byType(ComponentEditorPage), findsOneWidget);

        await tester.pageBack();
        await tester.pumpRouteTransition();

        verify(() => projectBloc.add(const ProjectComponentsRequested()))
            .called(1);
      },
    );

    group('delete', () {
      setUp(() {
        when(() => projectBloc.state).thenReturn(
          const ProjectState(status: ProjectStatus.ready, components: [player]),
        );
      });

      testWidgets('asks for confirmation and deletes when confirmed', (
        tester,
      ) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();

        expect(find.byType(DeleteComponentDialog), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
        await tester.pumpAndSettle();

        verify(
          () => projectBloc.add(const ProjectComponentDeleteRequested(player)),
        ).called(1);
      });

      testWidgets('does nothing when cancelled', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(DeleteComponentDialog), findsNothing);
        verifyNever(() => projectBloc.add(any()));
      });
    });

    group('add', () {
      testWidgets('creates a component with the entered name', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Name'),
          ' Player ',
        );
        await tester.pump();
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();

        verify(
          () => projectBloc.add(
            const ProjectComponentCreateRequested(
              'Player',
              ComponentType.rectangle,
            ),
          ),
        ).called(1);
      });

      testWidgets('submits with the keyboard', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Name'),
          'Player',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verify(
          () => projectBloc.add(
            const ProjectComponentCreateRequested(
              'Player',
              ComponentType.rectangle,
            ),
          ),
        ).called(1);
      });

      testWidgets('offers the component types', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownMenu<ComponentType>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Rectangle').last);
        await tester.pumpAndSettle();

        expect(find.text('Rectangle'), findsWidgets);
      });

      testWidgets('does not offer hitboxes, which are only children', (
        tester,
      ) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownMenu<ComponentType>));
        await tester.pumpAndSettle();

        expect(find.text('Polygon'), findsWidgets);
        expect(find.text('Rectangle hitbox'), findsNothing);
        expect(find.text('Circle hitbox'), findsNothing);
        expect(find.text('Polygon hitbox'), findsNothing);
      });

      testWidgets('asks for the shape of polygons', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();
        expect(find.byType(DropdownMenu<PolygonShape>), findsNothing);

        await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Ship');
        await tester.tap(find.byType(DropdownMenu<ComponentType>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Polygon').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DropdownMenu<PolygonShape>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Square').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();

        verify(
          () => projectBloc.add(
            const ProjectComponentCreateRequested(
              'Ship',
              ComponentType.polygon,
              polygonShape: PolygonShape.square,
            ),
          ),
        ).called(1);
      });

      testWidgets('disables create while the name is empty', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();

        final create = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Create'),
        );
        expect(create.onPressed, isNull);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.byType(AddComponentDialog), findsOneWidget);
      });

      testWidgets('does nothing when cancelled', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Add component'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AddComponentDialog), findsNothing);
        verifyNever(() => projectBloc.add(any()));
      });
    });

    testWidgets('opens the editor when a component is created', (tester) async {
      whenListen(
        projectBloc,
        Stream.value(
          const ProjectState(
            status: ProjectStatus.created,
            components: [player],
            createdComponent: player,
          ),
        ),
        initialState: const ProjectState(status: ProjectStatus.ready),
      );

      await tester.pumpApp(
        buildSubject(),
        componentRepository: componentRepository,
        projectRepository: projectRepository,
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorPage), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Player'), findsOneWidget);
    });

    testWidgets('shows the conflicting component on classConflict', (
      tester,
    ) async {
      whenListen(
        projectBloc,
        Stream.value(
          const ProjectState(
            status: ProjectStatus.classConflict,
            conflictingComponent: 'player_ship',
          ),
        ),
        initialState: const ProjectState(status: ProjectStatus.ready),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.textContaining('"player_ship" component'), findsOneWidget);
    });

    for (final (status, message) in [
      (ProjectStatus.invalidName, 'Component names must start'),
      (ProjectStatus.alreadyExists, 'A component with that name already'),
      (ProjectStatus.failure, 'Something went wrong'),
    ]) {
      testWidgets('shows a message on ${status.name}', (tester) async {
        whenListen(
          projectBloc,
          Stream.value(ProjectState(status: status)),
          initialState: const ProjectState(status: ProjectStatus.ready),
        );

        await tester.pumpApp(buildSubject());
        await tester.pump();

        expect(find.textContaining(message), findsOneWidget);
      });
    }
  });
}
