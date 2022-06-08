import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'loading_widget.dart';

Future<void> main() async {
  final image = await generateImage();

  group('SpriteButton', () {
    testWidgets('has no FutureBuilder when passed an animation',
        (tester) async {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);

      await tester.pumpWidget(
        SpriteButton(
          sprite: sprite1,
          pressedSprite: sprite2,
          onPressed: () {},
          width: 100,
          height: 100,
          label: const SizedBox(),
        ),
      );

      final futureBuilderFinder = find.byType(FutureBuilder);
      final nineTileBoxWidgetFinder = find.byType(SpriteButton);

      expect(futureBuilderFinder, findsNothing);
      expect(nineTileBoxWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder and LoadingWidget when passed an asset path',
      (tester) async {
        const imagePath1 = 'test_path_1';
        const imagePath2 = 'test_path_2';
        Flame.images.add(imagePath1, image);
        Flame.images.add(imagePath2, image);

        await tester.pumpWidget(
          SpriteButton.asset(
            path: imagePath1,
            pressedPath: imagePath2,
            onPressed: () {},
            width: 100,
            height: 100,
            label: const SizedBox(),
            loadingBuilder: (_) => const LoadingWidget(),
          ),
        );

        final futureBuilderFinder = find.byType(FutureBuilder<List<Sprite>>);
        final nineTileBoxWidgetFinder = find.byType(InternalSpriteButton);
        final loadingWidgetFinder = find.byType(LoadingWidget);

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsOneWidget);
        expect(nineTileBoxWidgetFinder, findsNothing);

        /// loading to be removed
        await tester.pump();

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsNothing);
        expect(nineTileBoxWidgetFinder, findsOneWidget);
      },
    );
  });
}
