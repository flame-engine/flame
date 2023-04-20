import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/src/sprite_animation_ticker.dart';
import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'loading_widget.dart';

Future<void> main() async {
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

      await tester.pumpWidget(
        SpriteAnimationWidget(
          animation: spriteAnimation,
          animationTicker: spriteAnimation.ticker(),
        ),
      );

      final futureBuilderFinder = find.byType(FutureBuilder);
      final spriteAnimationWidgetFinder = find.byType(SpriteAnimationWidget);

      expect(futureBuilderFinder, findsNothing);
      expect(spriteAnimationWidgetFinder, findsOneWidget);
    });

    testWidgets(
      'has FutureBuilder and LoadingWidget when passed an asset path',
      (tester) async {
        const imagePath = 'test_path';
        Flame.images.add(imagePath, image);
        final spriteAnimationData = SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 1,
          textureSize: Vector2(10, 10),
        );

        await tester.pumpWidget(
          SpriteAnimationWidget.asset(
            path: imagePath,
            data: spriteAnimationData,
            loadingBuilder: (_) => const LoadingWidget(),
          ),
        );

        final futureBuilderFinder = find.byType(FutureBuilder<SpriteAnimation>);
        final spriteAnimationWidgetFinder =
            find.byType(InternalSpriteAnimationWidget);
        final loadingWidgetFinder = find.byType(LoadingWidget);

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsOneWidget);
        expect(spriteAnimationWidgetFinder, findsNothing);

        /// loading to be removed
        await tester.pump();

        expect(futureBuilderFinder, findsOneWidget);
        expect(loadingWidgetFinder, findsNothing);
        expect(spriteAnimationWidgetFinder, findsOneWidget);
      },
    );

    testWidgets(
      'can safely change animation parameter',
      (tester) async {
        const executionCount = 10;
        final frames = List.generate(5, (_) => Sprite(image));
        final animation1 = SpriteAnimation.spriteList(frames, stepTime: 0.1);
        final animation2 = SpriteAnimation.spriteList(frames, stepTime: 0.1);
        final animationTicker1 = SpriteAnimationTicker(animation1);
        final animationTicker2 = SpriteAnimationTicker(animation2);

        var animation1Started = false;
        var animation2Started = false;

        animationTicker1.onStart = () => animation1Started = true;
        animationTicker2.onStart = () => animation2Started = true;

        for (var idx = 0; idx < executionCount; idx++) {
          animation1Started = false;
          animation2Started = false;

          await tester.pumpWidget(
            SpriteAnimationWidget(
              animation: animation1,
              animationTicker: animationTicker1,
            ),
          );
          expect(animationTicker1.onComplete, isNotNull);
          expect(animationTicker2.onComplete, isNull);

          await tester.pump();
          expect(animation1Started, true);

          // This will call didUpdateWidget lifecycle
          await tester.pumpWidget(
            SpriteAnimationWidget(
              animation: animation2,
              animationTicker: animationTicker2,
            ),
          );
          expect(animationTicker1.onComplete, isNull);
          expect(animationTicker2.onComplete, isNotNull);

          await tester.pump();
          expect(animation2Started, true);
        }
      },
    );

    testWidgets(
      'onComplete callback is called when the animation is finished',
      (tester) async {
        const imagePath = 'test_image_path';
        Flame.images.add(imagePath, image);
        final spriteAnimationData = SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
          loop: false,
        );

        var onCompleteCalled = false;

        await tester.pumpWidget(
          SpriteAnimationWidget.asset(
            path: imagePath,
            data: spriteAnimationData,
            onComplete: () => onCompleteCalled = true,
          ),
        );

        await tester.pumpAndSettle();

        expect(onCompleteCalled, isTrue);
      },
    );
  });
}
