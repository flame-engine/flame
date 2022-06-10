import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'loading_widget.dart';

Future<void> main() async {
  final image = await generateImage();

  group('NineTileBoxWidget', () {
    testWidgets('has no FutureBuilder when passed an animation',
        (tester) async {
      await tester.pumpWidget(
        NineTileBoxWidget(
          image: image,
          tileSize: 10,
          destTileSize: 10,
        ),
      );

      final futureBuilderFinder = find.byType(FutureBuilder);
      final nineTileBoxWidgetFinder = find.byType(NineTileBoxWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(nineTileBoxWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder and LoadingWidget when passed an asset path',
      (tester) async {
        const imagePath = 'test_path';
        Flame.images.add(imagePath, image);

        await tester.pumpWidget(
          NineTileBoxWidget.asset(
            path: imagePath,
            tileSize: 10,
            destTileSize: 10,
            loadingBuilder: (_) => const LoadingWidget(),
          ),
        );

        final futureBuilderFinder = find.byType(FutureBuilder<ui.Image>);
        final nineTileBoxWidgetFinder = find.byType(InternalNineTileBox);
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
