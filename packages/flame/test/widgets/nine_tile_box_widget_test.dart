import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final image = await generateImage();

  group('NineTileBoxWidget', () {
    testWidgets('has no FutureBuilder when passed an animation',
        (tester) async {
      await tester.pumpWidget(
        NineTileBoxWidget(
          image: image,
          tileSize: 1,
          destTileSize: 1,
        ),
      );

      final futureBuilderFinder = find.byType(FutureBuilder);
      final nineTileBoxWidgetFinder = find.byType(NineTileBoxWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(nineTileBoxWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder when passed an asset path',
      (tester) async {
        ///How can I test this...?
      },
      skip: true,
    );
  });
}
