import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
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
      'has FutureBuilder when passed an asset path',
      (tester) async {
        ///How can I test this...?
      },
      skip: true,
    );
  });
}
