import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/sprite_editor.dart';
import 'package:flame_studio/sprite_editor/widgets/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

/// A 1x1 PNG.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
  'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  group(SpriteEditorDialog, () {
    const project = Project(path: '/game');
    const image = 'assets/images/a.png';

    late ComponentRepository repository;
    late ComponentSprite? result;

    setUp(() {
      repository = _MockComponentRepository();
      when(() => repository.getImages(project.path))
          .thenAnswer((_) async => const [image]);
      when(() => repository.readImage(project.path, image))
          .thenAnswer((_) async => _png);
    });

    Future<void> openDialog(
      WidgetTester tester, {
      ComponentSprite sprite = const ComponentSprite(),
    }) async {
      result = null;
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await SpriteEditorDialog.show(
                context,
                project: project,
                sprite: sprite,
              );
            },
            child: const Text('Open'),
          ),
        ),
        componentRepository: repository,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    /// Lets the engine decode the image, which fake time doesn't.
    Future<void> decode(WidgetTester tester) async {
      await tester.runAsync(() async {
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (find.byType(SpritePainter).evaluate().isNotEmpty) {
            break;
          }
          await tester.pump();
        }
      });
      await tester.pump();
    }

    Finder canvas() => find.descendant(
      of: find.byType(SpriteCanvas),
      matching: find.byType(CustomPaint),
    );

    testWidgets('applying is disabled until an image is picked', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.text(image), findsOneWidget);
      expect(find.text('Select an image from the list'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNull,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('tells when the project has no images', (tester) async {
      when(() => repository.getImages(project.path))
          .thenAnswer((_) async => const []);
      await openDialog(tester);

      expect(find.textContaining('No images found'), findsOneWidget);
    });

    testWidgets('picking an image selects all of it', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text(image));
      await tester.pump();
      await tester.pump();
      await decode(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pumpAndSettle();

      expect(
        result,
        equals(
          const ComponentSprite(
            image: image,
            srcSize: ComponentSize(width: 1, height: 1),
          ),
        ),
      );
    });

    testWidgets('marks an image that cannot be decoded', (tester) async {
      when(() => repository.readImage(project.path, image))
          .thenAnswer((_) async => base64Decode('AAAA'));
      await openDialog(tester);
      await tester.tap(find.text(image));
      await tester.pump();
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(find.text('The image could not be read'), findsOneWidget);
    });

    group('on a bigger image', () {
      /// Opens the dialog on a 40x20 image with this region, drawn 10 canvas
      /// pixels per image pixel in the [transform] of its painter.
      Future<SpriteViewTransform> openBig(
        WidgetTester tester,
        ComponentSprite sprite,
      ) async {
        final bytes = await tester.runAsync(() async {
          final image = await generateImage(40, 20);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          return data!.buffer.asUint8List();
        });
        when(() => repository.readImage(project.path, image))
            .thenAnswer((_) async => bytes!);
        await openDialog(tester, sprite: sprite);
        await decode(tester);
        return (tester.widget<CustomPaint>(canvas()).painter! as SpritePainter)
            .transform;
      }

      Offset global(
        WidgetTester tester,
        SpriteViewTransform transform,
        Offset imagePoint,
      ) {
        return tester.getTopLeft(canvas()) + transform.toCanvas(imagePoint);
      }

      Future<void> apply(WidgetTester tester) async {
        await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
        await tester.pumpAndSettle();
      }

      testWidgets('dragging on the image selects a region', (tester) async {
        final transform = await openBig(
          tester,
          const ComponentSprite(
            image: image,
            srcSize: ComponentSize(width: 2, height: 2),
          ),
        );

        await tester.dragFrom(
          global(tester, transform, const Offset(10, 5)),
          const Offset(8, 6) * transform.scale,
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        await apply(tester);

        expect(
          result,
          equals(
            const ComponentSprite(
              image: image,
              srcPosition: ComponentPosition(x: 10, y: 5),
              srcSize: ComponentSize(width: 8, height: 6),
            ),
          ),
        );
      });

      testWidgets('dragging the selection moves it', (tester) async {
        final transform = await openBig(
          tester,
          const ComponentSprite(
            image: image,
            srcPosition: ComponentPosition(x: 10, y: 5),
            srcSize: ComponentSize(width: 8, height: 6),
          ),
        );

        await tester.dragFrom(
          global(tester, transform, const Offset(14, 8)),
          const Offset(4, 2) * transform.scale,
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        await apply(tester);

        expect(
          result,
          equals(
            const ComponentSprite(
              image: image,
              srcPosition: ComponentPosition(x: 14, y: 7),
              srcSize: ComponentSize(width: 8, height: 6),
            ),
          ),
        );
      });

      testWidgets('dragging a handle resizes the selection', (tester) async {
        final transform = await openBig(
          tester,
          const ComponentSprite(
            image: image,
            srcPosition: ComponentPosition(x: 10, y: 5),
            srcSize: ComponentSize(width: 8, height: 6),
          ),
        );

        await tester.dragFrom(
          global(tester, transform, const Offset(18, 11)),
          const Offset(2, 3) * transform.scale,
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        await apply(tester);

        expect(
          result,
          equals(
            const ComponentSprite(
              image: image,
              srcPosition: ComponentPosition(x: 10, y: 5),
              srcSize: ComponentSize(width: 10, height: 9),
            ),
          ),
        );
      });

      testWidgets('typing in the fields edits the region', (tester) async {
        await openBig(
          tester,
          const ComponentSprite(
            image: image,
            srcSize: ComponentSize(width: 8, height: 6),
          ),
        );

        await tester.enterText(find.widgetWithText(TextField, 'X'), '3');
        await tester.pump();
        await apply(tester);

        expect(result?.srcPosition.x, equals(3));
      });
    });

    testWidgets('scrolling pans the canvas', (tester) async {
      await openDialog(
        tester,
        sprite: const ComponentSprite(
          image: image,
          srcSize: ComponentSize(width: 1, height: 1),
        ),
      );
      await decode(tester);
      final context = tester.element(find.byType(SpriteCanvas));
      final before =
          tester.widget<CustomPaint>(canvas()).painter! as SpritePainter;

      final pointer = TestPointer(1, PointerDeviceKind.mouse)
        ..hover(tester.getCenter(canvas()));
      await tester.sendEventToBinding(pointer.scroll(const Offset(10, 20)));
      await tester.pump();

      final after =
          tester.widget<CustomPaint>(canvas()).painter! as SpritePainter;
      expect(
        after.transform.offset,
        equals(before.transform.offset - const Offset(10, 20)),
      );
      expect(context.mounted, isTrue);
    });
  });
}
