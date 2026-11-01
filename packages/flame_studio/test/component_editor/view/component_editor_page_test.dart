import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/component_editor/component_editor.dart';
import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/palette/palette.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockComponentEditorBloc()
    extends MockBloc<ComponentEditorEvent, ComponentEditorState>
    implements ComponentEditorBloc;

void main() {
  const project = Project(path: '/projects/my_game');
  const component = RectangleComponent(name: 'Player');
  const edited = RectangleComponent(
    name: 'Player',
    size: ComponentSize(width: 10),
  );

  setUpAll(() => registerFallbackValue(const ComponentEditorSaveRequested()));

  group(ComponentEditorPage, () {
    testWidgets('route shows the editor for the component', (tester) async {
      final componentRepository = _MockComponentRepository();
      final projectRepository = _MockProjectRepository();
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => const [component]);
      when(() => componentRepository.getPalette(project.path))
          .thenAnswer((_) async => const Palette());
      when(() => projectRepository.getSettings(project))
          .thenAnswer((_) async => const ProjectSettings());
      when(
        () => componentRepository.isComponentCodeUpToDate(
          project.path,
          const ProjectSettings().outputPath,
          component,
        ),
      ).thenAnswer((_) async => true);
      await tester.pumpApp(
        componentRepository: componentRepository,
        projectRepository: projectRepository,
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(ComponentEditorPage.route(project, component)),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Player'), findsOneWidget);
      verify(() => componentRepository.getComponents(project.path)).called(1);
    });
  });

  group(ComponentEditorView, () {
    late ComponentEditorBloc bloc;

    setUp(() {
      bloc = _MockComponentEditorBloc();
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(
          component: component,
          savedComponent: component,
        ),
      );
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const ComponentEditorView(project: project),
    );

    testWidgets('shows the preview and the property editors', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(ComponentPreview), findsOneWidget);
      expect(find.byType(GameWidget<ComponentPreviewGame>), findsOneWidget);
      expect(find.byType(SizeEditor), findsOneWidget);
      expect(find.byType(PaintEditor), findsOneWidget);
    });

    group('highlight toggle', () {
      IconButton toggle(WidgetTester tester) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.highlight_alt),
          matching: find.byType(IconButton),
        ),
      );

      testWidgets('is selected while highlighting', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(toggle(tester).isSelected, isTrue);
      });

      testWidgets('is not selected while not highlighting', (tester) async {
        when(() => bloc.state).thenReturn(
          const ComponentEditorState(
            component: component,
            savedComponent: component,
            isSelectionHighlighted: false,
          ),
        );
        await tester.pumpApp(buildSubject());

        expect(toggle(tester).isSelected, isFalse);
      });

      testWidgets('is filled only when selected', (tester) async {
        await tester.pumpApp(buildSubject());
        final colorScheme = Theme.of(tester.element(find.byType(EditorToolbar)))
            .colorScheme;
        final background = toggle(tester).style!.backgroundColor!;

        expect(
          background.resolve({WidgetState.selected}),
          equals(colorScheme.primaryContainer),
        );
        expect(background.resolve({}), isNull);
      });
    });

    testWidgets('toolbar sits above the preview only', (tester) async {
      await tester.pumpApp(buildSubject());

      final toolbar = tester.getRect(find.byType(EditorToolbar));
      final preview = tester.getRect(find.byType(ComponentPreview));
      expect(toolbar.left, equals(preview.left));
      expect(toolbar.width, equals(preview.width));
      expect(toolbar.bottom, lessThanOrEqualTo(preview.top));
    });

    testWidgets('top bar sits above the panels', (tester) async {
      await tester.pumpApp(buildSubject());

      final topBar = tester.getRect(find.byType(EditorTopBar));
      final tree = tester.getRect(find.byType(ComponentTreePanel));
      final properties = tester.getRect(find.byType(PropertiesPanel));
      expect(topBar.left, equals(tree.left));
      expect(topBar.right, equals(properties.right));
      expect(topBar.bottom, lessThanOrEqualTo(tree.top));
    });

    testWidgets('top bar opens the palette and passes on the saved palette', (
      tester,
    ) async {
      const palette = Palette(
        colors: [PaletteColor(name: 'color1', color: 0xFFFFFFFF)],
      );
      final componentRepository = _MockComponentRepository();
      final projectRepository = _MockProjectRepository();
      when(() => componentRepository.getPalette(project.path))
          .thenAnswer((_) async => const Palette());
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => const [component]);
      when(() => componentRepository.savePalette(project.path, palette))
          .thenAnswer((_) async {});
      when(() => projectRepository.getSettings(project))
          .thenAnswer((_) async => const ProjectSettings());
      when(
        () => componentRepository.writePaletteCode(
          project.path,
          const ProjectSettings().outputPath,
          palette,
        ),
      ).thenAnswer((_) async {});
      await tester.pumpApp(
        buildSubject(),
        componentRepository: componentRepository,
        projectRepository: projectRepository,
      );

      await tester.tap(find.byTooltip('Palette'));
      await tester.pumpRouteTransition();
      expect(find.byType(PaletteView), findsOneWidget);

      await tester.tap(find.text('Add color'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpRouteTransition();

      expect(find.byType(PaletteView), findsNothing);
      verify(() => bloc.add(const ComponentEditorPaletteChanged(palette)))
          .called(1);
    });

    testWidgets('dispatches highlight toggles', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.byTooltip('Highlight selection'));

      verify(() => bloc.add(const ComponentEditorSelectionHighlightToggled()))
          .called(1);
    });

    group('hitboxes toggle', () {
      IconButton toggle(WidgetTester tester) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.border_style),
          matching: find.byType(IconButton),
        ),
      );

      testWidgets('is selected while the hitboxes are shown', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(toggle(tester).isSelected, isTrue);
      });

      testWidgets('dispatches hitboxes toggles', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Show hitboxes'));

        verify(() => bloc.add(const ComponentEditorHitboxesVisibilityToggled()))
            .called(1);
      });

      testWidgets('preview outlines the hitboxes while shown', (tester) async {
        const withHitbox = PositionComponent(
          name: 'Player',
          children: [RectangleHitboxComponent(name: 'rectangleHitbox1')],
        );
        const state = ComponentEditorState(
          component: withHitbox,
          savedComponent: withHitbox,
        );
        final states = StreamController<ComponentEditorState>();
        whenListen(bloc, states.stream, initialState: state);
        await tester.pumpApp(buildSubject());
        await tester.pump();
        final game = tester
            .widget<GameWidget<ComponentPreviewGame>>(
              find.byType(GameWidget<ComponentPreviewGame>),
            )
            .game!;
        PreviewHitbox hitbox() =>
            game.preview.children.whereType<PreviewHitbox>().single;
        expect(hitbox().isVisible, isTrue);

        states.add(state.copyWith(areHitboxesVisible: false));
        await tester.pump();

        expect(game.areHitboxesVisible, isFalse);
        expect(hitbox().isVisible, isFalse);
        await states.close();
      });
    });

    testWidgets('preview highlights the selection while enabled', (
      tester,
    ) async {
      const state = ComponentEditorState(
        component: component,
        savedComponent: component,
      );
      final states = StreamController<ComponentEditorState>();
      whenListen(bloc, states.stream, initialState: state);
      await tester.pumpApp(buildSubject());
      await tester.pump();
      final game = tester
          .widget<GameWidget<ComponentPreviewGame>>(
            find.byType(GameWidget<ComponentPreviewGame>),
          )
          .game!;
      expect(game.highlight.target, same(game.preview));

      states.add(state.copyWith(isSelectionHighlighted: false));
      await tester.pump();

      expect(game.highlight.target, isNull);
      await states.close();
    });

    group('zoom', () {
      testWidgets('dispatches zooms from the toolbar', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Zoom in'));
        await tester.tap(find.byTooltip('Zoom out'));
        await tester.tap(find.text('100%'));

        verify(() => bloc.add(const ComponentEditorZoomedIn())).called(1);
        verify(() => bloc.add(const ComponentEditorZoomedOut())).called(1);
        verify(() => bloc.add(const ComponentEditorZoomReset())).called(1);
      });

      testWidgets('shows the zoom and disables zooming past the limits', (
        tester,
      ) async {
        when(() => bloc.state).thenReturn(
          const ComponentEditorState(
            component: component,
            savedComponent: component,
            zoom: 8,
          ),
        );
        await tester.pumpApp(buildSubject());

        expect(find.text('800%'), findsOneWidget);
        IconButton button(String tooltip) => tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );
        expect(button('Zoom in').onPressed, isNull);
        expect(button('Zoom out').onPressed, isNotNull);
      });

      for (final (control, key, event) in [
        (
          LogicalKeyboardKey.metaLeft,
          LogicalKeyboardKey.equal,
          const ComponentEditorZoomedIn(),
        ),
        (
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.minus,
          const ComponentEditorZoomedOut(),
        ),
        (
          LogicalKeyboardKey.metaLeft,
          LogicalKeyboardKey.digit0,
          const ComponentEditorZoomReset(),
        ),
      ]) {
        testWidgets('dispatches $event with ${control.keyLabel}+'
            '${key.keyLabel}', (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.pump();

          await tester.sendKeyDownEvent(control);
          await tester.sendKeyEvent(key);
          await tester.sendKeyUpEvent(control);

          verify(() => bloc.add(event)).called(1);
        });
      }

      testWidgets('zooms the preview', (tester) async {
        const state = ComponentEditorState(
          component: component,
          savedComponent: component,
          zoom: 2,
        );
        final states = StreamController<ComponentEditorState>();
        whenListen(bloc, states.stream, initialState: state);
        await tester.pumpApp(buildSubject());
        await tester.pump();
        final game = tester
            .widget<GameWidget<ComponentPreviewGame>>(
              find.byType(GameWidget<ComponentPreviewGame>),
            )
            .game!;
        expect(game.camera.viewfinder.zoom, 2);

        states.add(state.copyWith(zoom: 0.5));
        await tester.pump();

        expect(game.camera.viewfinder.zoom, 0.5);
        await states.close();
      });
    });

    testWidgets('dispatches size changes', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.enterText(find.widgetWithText(TextField, 'Width'), '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(
        () => bloc.add(
          const ComponentEditorSizeChanged(ComponentSize(width: 10)),
        ),
      ).called(1);
    });

    testWidgets('edits the vertices of polygons', (tester) async {
      const polygon = PolygonComponent(name: 'Player');
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(component: polygon, savedComponent: polygon),
      );
      await tester.pumpApp(buildSubject());

      expect(find.byType(SizeEditor), findsNothing);
      expect(find.byType(VerticesEditor), findsOneWidget);
      expect(find.byType(PaintEditor), findsOneWidget);
    });

    testWidgets('edits the radius of circles', (tester) async {
      const circle = CircleComponent(name: 'Player');
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(component: circle, savedComponent: circle),
      );
      await tester.pumpApp(buildSubject());

      expect(find.byType(SizeEditor), findsNothing);
      expect(find.byType(PaintEditor), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Radius'), '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(
        () => bloc.add(
          const ComponentEditorRadiusChanged(ComponentRadius(radius: 10)),
        ),
      ).called(1);
    });

    testWidgets('dispatches paint changes', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Stroke'));

      verify(
        () => bloc.add(
          const ComponentEditorPaintChanged(
            ComponentPaint(style: PaintStyle.stroke),
          ),
        ),
      ).called(1);
    });

    group('component tree', () {
      const child = RectangleComponent(
        name: 'rectangle1',
        position: ComponentPosition(x: 5, y: 6),
      );
      const tree = RectangleComponent(name: 'Player', children: [child]);

      void stubTree({List<int> selectedPath = const []}) {
        when(() => bloc.state).thenReturn(
          ComponentEditorState(
            component: tree,
            savedComponent: tree,
            selectedPath: selectedPath,
            takenClassNames: const {
              r'$PlayerEye': RectangleComponent(name: 'player_eye'),
            },
          ),
        );
      }

      testWidgets('lists the root and its children', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        final panel = find.byType(ComponentTreePanel);
        expect(panel, findsOneWidget);
        expect(
          find.descendant(of: panel, matching: find.text('Player')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: panel, matching: find.text('rectangle1')),
          findsOneWidget,
        );
        final root = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Player'),
        );
        expect(root.selected, isTrue);
      });

      testWidgets('selects a node when tapped', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('rectangle1'));

        verify(() => bloc.add(const ComponentEditorNodeSelected([0])))
            .called(1);
      });

      testWidgets('adds a child of the picked type', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Add child'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Rectangle'));

        verify(
          () => bloc.add(
            const ComponentEditorChildAdded(ComponentType.rectangle),
          ),
        ).called(1);
      });

      testWidgets('adds polygons with the picked shape', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Add child'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Polygon (triangle)'), findsOneWidget);
        await tester.tap(find.text('Polygon (square)'));

        verify(
          () => bloc.add(
            const ComponentEditorChildAdded(
              ComponentType.polygon,
              polygonShape: PolygonShape.square,
            ),
          ),
        ).called(1);
      });

      testWidgets('adds hitboxes, with the picked shape for polygons', (
        tester,
      ) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Add child'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Rectangle hitbox'), findsOneWidget);
        expect(find.text('Circle hitbox'), findsOneWidget);
        expect(find.text('Polygon hitbox (triangle)'), findsOneWidget);
        await tester.tap(find.text('Polygon hitbox (square)'));

        verify(
          () => bloc.add(
            const ComponentEditorChildAdded(
              ComponentType.polygonHitbox,
              polygonShape: PolygonShape.square,
            ),
          ),
        ).called(1);
      });

      testWidgets('edits the collision of a hitbox, which has no paint and '
          'no children', (tester) async {
        const withHitbox = PositionComponent(
          name: 'Player',
          children: [CircleHitboxComponent(name: 'circleHitbox1')],
        );
        when(() => bloc.state).thenReturn(
          const ComponentEditorState(
            component: withHitbox,
            savedComponent: withHitbox,
            selectedPath: [0],
          ),
        );
        await tester.pumpApp(buildSubject());

        expect(
          tester
              .widget<PopupMenuButton<ComponentEditorChildAdded>>(
                find.byType(PopupMenuButton<ComponentEditorChildAdded>),
              )
              .enabled,
          isFalse,
        );

        await tester.scrollUntilVisible(
          find.byType(CollisionEditor),
          100,
          scrollable: find
              .descendant(
                of: find.byType(PropertiesPanel),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(find.byType(RadiusEditor), findsOneWidget);
        expect(find.byType(PaintEditor), findsNothing);
        tester
            .widget<CollisionEditor>(find.byType(CollisionEditor))
            .onChanged(const ComponentCollision(isSolid: true));

        verify(
          () => bloc.add(
            const ComponentEditorCollisionChanged(
              ComponentCollision(isSolid: true),
            ),
          ),
        ).called(1);
      });

      testWidgets('cannot remove the root', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        final remove = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.delete_outline),
        );
        expect(remove.onPressed, isNull);
      });

      testWidgets('removes the selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Remove'));

        verify(() => bloc.add(const ComponentEditorNodeRemoved([0]))).called(1);
      });

      testWidgets('hides the position, the anchor and the angle of the root', (
        tester,
      ) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        expect(find.byType(PositionEditor), findsNothing);
        expect(find.byType(AnchorEditor), findsNothing);
        expect(find.byType(AngleEditor), findsNothing);
        expect(find.byType(SizeEditor), findsOneWidget);
      });

      testWidgets('hides the name of the root', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        expect(find.byType(NameField), findsNothing);
      });

      testWidgets('renames a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        final field = find.byType(NameField);
        expect(
          find.descendant(of: field, matching: find.text('rectangle1')),
          findsOneWidget,
        );

        await tester.enterText(field, 'head');

        verify(() => bloc.add(const ComponentEditorNameChanged('head')))
            .called(1);
      });

      for (final (name, message) in [
        ('1head', 'Use a valid Dart identifier'),
        ('size', 'Already a member of the parent component in Flame'),
        ('Player', 'Another component already uses this name'),
        ('eye', 'Generates the same class as a part of another component'),
      ]) {
        testWidgets('rejects the child name "$name"', (tester) async {
          stubTree(selectedPath: [0]);
          await tester.pumpApp(buildSubject());

          await tester.enterText(find.byType(NameField), name);
          await tester.pump();

          expect(find.textContaining(message), findsOneWidget);
          verifyNever(() => bloc.add(ComponentEditorNameChanged(name)));
        });
      }

      testWidgets('edits the position of a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        expect(find.byType(PositionEditor), findsOneWidget);
        expect(find.widgetWithText(TextField, '5'), findsOneWidget);

        await tester.enterText(
          find.descendant(
            of: find.byType(PositionEditor),
            matching: find.widgetWithText(TextField, 'X'),
          ),
          '-10',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);

        verify(
          () => bloc.add(
            const ComponentEditorPositionChanged(
              ComponentPosition(x: -10, y: 6),
            ),
          ),
        ).called(1);
      });

      testWidgets('edits the anchor of a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('center'));

        verify(
          () => bloc.add(
            const ComponentEditorAnchorChanged(ComponentAnchor.center),
          ),
        ).called(1);
      });

      testWidgets('edits the angle of a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        await tester.enterText(
          find.widgetWithText(TextField, 'Degrees'),
          '180',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);

        verify(
          () => bloc.add(
            ComponentEditorAngleChanged(ComponentAngle.fromDegrees(180)),
          ),
        ).called(1);
      });
    });

    testWidgets('disables save without changes', (tester) async {
      await tester.pumpApp(buildSubject());

      final save = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save_outlined),
      );
      expect(save.onPressed, isNull);
      expect(find.widgetWithText(AppBar, 'Player'), findsOneWidget);
    });

    testWidgets('saves without changes when the code is outdated', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(
          status: ComponentEditorStatus.classConflict,
          component: component,
          savedComponent: component,
          isCodeOutdated: true,
        ),
      );
      await tester.pumpApp(buildSubject());

      expect(find.text('Player •'), findsNothing);
      await tester.tap(find.byTooltip('Save'));

      verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
    });

    group('with changes', () {
      setUp(() {
        when(() => bloc.state).thenReturn(
          const ComponentEditorState(
            component: edited,
            savedComponent: component,
          ),
        );
      });

      testWidgets('marks the title', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.text('Player •'), findsOneWidget);
      });

      testWidgets('saves with the save button', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Save'));

        verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
      });

      testWidgets('saves with the keyboard shortcut', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);

        verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
      });
    });

    testWidgets('shows a message when saving fails', (tester) async {
      whenListen(
        bloc,
        Stream.value(
          const ComponentEditorState(
            status: ComponentEditorStatus.failure,
            component: edited,
            savedComponent: component,
          ),
        ),
        initialState: const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.text('Could not save the component'), findsOneWidget);
    });

    const playerHead = RectangleComponent(name: 'player_head');
    const playerRoot = RectangleComponent(name: 'player_');
    const owner = RectangleComponent(
      name: 'pla',
      children: [RectangleComponent(name: 'yer')],
    );
    for (final (description, takenClassNames, messages) in [
      (
        'children',
        {
          r'$PlayerHead': playerHead,
          r'$Enemy': const RectangleComponent(name: 'Enemy'),
        },
        [
          r'Rename the children that generate $PlayerHead',
          r'$PlayerHead (also generated by "player_head").',
        ],
      ),
      (
        'the root, with another root',
        {r'$Player': playerRoot},
        [
          r'"player_" generates the same class, $Player',
          'delete one of the two components.',
        ],
      ),
      (
        'the root, with a child of another component',
        {r'$Player': owner},
        [r'A child of "pla" generates $Player', 'rename that child.'],
      ),
      (
        'the root and children',
        {r'$Player': playerRoot, r'$PlayerHead': playerHead},
        [
          'delete one of the two components',
          r'Rename the children that generate $PlayerHead',
        ],
      ),
    ]) {
      testWidgets('tells how to fix a classConflict of $description', (
        tester,
      ) async {
        const tree = RectangleComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'head')],
        );
        whenListen(
          bloc,
          Stream.value(
            ComponentEditorState(
              status: ComponentEditorStatus.classConflict,
              component: tree,
              savedComponent: tree,
              takenClassNames: takenClassNames,
            ),
          ),
          initialState: const ComponentEditorState(
            component: tree,
            savedComponent: component,
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.pump();

        for (final message in messages) {
          expect(find.textContaining(message), findsOneWidget);
        }
        if (takenClassNames.containsKey(r'$PlayerHead')) {
          return;
        }
        expect(find.textContaining('Rename the children'), findsNothing);
      });
    }

    for (final (status, message) in [
      (ComponentEditorStatus.codeConflict, 'a file that was not generated'),
      (ComponentEditorStatus.codeFailure, 'the code could not be generated'),
    ]) {
      testWidgets('shows a message for $status', (tester) async {
        whenListen(
          bloc,
          Stream.value(
            ComponentEditorState(
              status: status,
              component: edited,
              savedComponent: edited,
            ),
          ),
          initialState: const ComponentEditorState(
            component: edited,
            savedComponent: component,
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.pump();

        expect(find.textContaining(message), findsOneWidget);
      });
    }
  });

  group('leaving the editor', () {
    const unsaved = ComponentEditorState(
      component: edited,
      savedComponent: component,
    );

    late ComponentEditorBloc bloc;
    late StreamController<ComponentEditorState> states;

    setUp(() {
      bloc = _MockComponentEditorBloc();
      states = StreamController.broadcast();
      whenListen(bloc, states.stream, initialState: unsaved);
      when(() => bloc.isClosed).thenReturn(false);
    });

    tearDown(() => states.close());

    Future<void> openEditor(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: const ComponentEditorView(project: project),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpRouteTransition();
    }

    Future<void> leave(WidgetTester tester) async {
      await tester.pageBack();
      await tester.pumpRouteTransition();
    }

    testWidgets('leaves directly without changes', (tester) async {
      whenListen(
        bloc,
        const Stream<ComponentEditorState>.empty(),
        initialState: const ComponentEditorState(
          component: component,
          savedComponent: component,
        ),
      );
      await openEditor(tester);

      await leave(tester);

      expect(find.byType(UnsavedChangesDialog), findsNothing);
      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('asks before leaving with changes', (tester) async {
      await openEditor(tester);

      await leave(tester);

      expect(find.byType(UnsavedChangesDialog), findsOneWidget);
    });

    testWidgets('stays when cancelled', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpRouteTransition();

      expect(find.byType(UnsavedChangesDialog), findsNothing);
      expect(find.byType(ComponentEditorView), findsOneWidget);
    });

    testWidgets('leaves without saving when discarded', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Discard'));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('saves and leaves when saving succeeds', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);

      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.saved,
          component: edited,
          savedComponent: edited,
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('leaves when saved without generating the code', (
      tester,
    ) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.codeFailure,
          component: edited,
          savedComponent: edited,
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('leaves when a save finished while asking', (tester) async {
      await openEditor(tester);
      await leave(tester);

      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.saved,
          component: edited,
          savedComponent: edited,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
      verifyNever(() => bloc.add(const ComponentEditorSaveRequested()));
    });

    testWidgets('stays when the clash was fixed while saving', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states
        ..add(unsaved.copyWith(status: ComponentEditorStatus.saving))
        ..add(unsaved.copyWith(status: ComponentEditorStatus.ready));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
    });

    testWidgets('stays when edited while saving', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.saved,
          component: component,
          savedComponent: edited,
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
    });

    testWidgets('stays when the classes clash', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(
        unsaved.copyWith(
          status: ComponentEditorStatus.classConflict,
          takenClassNames: {
            r'$Player': const RectangleComponent(name: 'player_'),
          },
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
      expect(
        find.textContaining("This component can't be saved."),
        findsOneWidget,
      );
    });

    testWidgets('stays when saving fails', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(unsaved.copyWith(status: ComponentEditorStatus.failure));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
      expect(find.text('Could not save the component'), findsOneWidget);
    });
  });
}
