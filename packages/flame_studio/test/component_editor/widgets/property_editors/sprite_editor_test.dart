import 'dart:convert';

import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/sprite_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

void main() {
  group(SpriteEditor, () {
    const project = Project(path: '/game');

    Future<List<ComponentSprite>> pumpEditor(
      WidgetTester tester, {
      ComponentSprite value = const ComponentSprite(),
    }) async {
      final changes = <ComponentSprite>[];
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _MockComponentRepository();
      when(() => repository.getImages(project.path))
          .thenAnswer((_) async => const []);
      when(() => repository.readImage(project.path, any()))
          .thenAnswer((_) async => base64Decode('AAAA'));
      await tester.pumpApp(
        Scaffold(
          body: SpriteEditor(
            project: project,
            value: value,
            onChanged: changes.add,
          ),
        ),
        componentRepository: repository,
      );
      return changes;
    }

    testWidgets('asks for an image when there is none', (tester) async {
      await pumpEditor(tester);

      expect(find.text('No image selected'), findsOneWidget);
      expect(find.text('Select sprite'), findsOneWidget);
    });

    testWidgets('shows the image and its region', (tester) async {
      await pumpEditor(
        tester,
        value: const ComponentSprite(
          image: 'assets/images/a.png',
          srcPosition: ComponentPosition(x: 4, y: 8),
          srcSize: ComponentSize(width: 16, height: 32),
        ),
      );

      expect(find.text('assets/images/a.png'), findsOneWidget);
      expect(find.text('16 × 32 at (4, 8)'), findsOneWidget);
      expect(find.text('Edit sprite'), findsOneWidget);
    });

    testWidgets('opens the dialog, and cancelling changes nothing', (
      tester,
    ) async {
      final changes = await pumpEditor(tester);

      await tester.tap(find.text('Select sprite'));
      await tester.pumpAndSettle();
      expect(find.byType(SpriteEditorDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });
  });
}
