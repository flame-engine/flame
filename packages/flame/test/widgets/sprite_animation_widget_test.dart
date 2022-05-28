import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final image = await generateImage();

  group('SpriteAnimationWidget', () {
    testWidgets('has no FutureBuilder when passed an animation',
        (tester) async {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final spriteAnimation = SpriteAnimation.spriteList(
        [sprite1, sprite2],
        stepTime: 0.1,
      );

      await tester
          .pumpWidget(SpriteAnimationWidget(animation: spriteAnimation));

      final futureBuilderFinder = find.byType(FutureBuilder);
      final spriteAnimationWidgetFinder = find.byType(SpriteAnimationWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(spriteAnimationWidgetFinder, findsOneWidget);
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
