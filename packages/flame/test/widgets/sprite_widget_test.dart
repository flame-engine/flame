import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'loading_widget.dart';

Future<void> main() async {
  final image = await generateImage();

  group('SpriteWidget', () {
    testWidgets('has no FutureBuilder when passed an sprite', (tester) async {
      final sprite = Sprite(image);

      await tester.pumpWidget(SpriteWidget(sprite: sprite));

      final futureBuilderFinder = find.byType(FutureBuilder);
      final spriteWidgetFinder = find.byType(SpriteWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(spriteWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder and LoadingWidget when passed an asset path',
      (tester) async {
        const imagePath = 'test_path';
        Flame.images.add(imagePath, image);

        await tester.pumpWidget(
          SpriteWidget.asset(
            path: imagePath,
            loadingBuilder: (_) => const LoadingWidget(),
          ),
        );

        final futureBuilderFinder = find.byType(FutureBuilder<Sprite>);
        final spriteWidgetFinder = find.byType(InternalSpriteWidget);
        final loadingWidgetFinder = find.byType(LoadingWidget);

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsOneWidget);
        expect(spriteWidgetFinder, findsNothing);

        /// loading to be removed
        await tester.pump();

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsNothing);
        expect(spriteWidgetFinder, findsOneWidget);
      },
    );
  });
}
