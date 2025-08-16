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
    testWidgets('has no FutureBuilder when passed an animation', (
      tester,
    ) async {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final spriteAnimation = SpriteAnimation.spriteList(
        [sprite1, sprite2],
        stepTime: 0.1,
      );

      await tester.pumpWidget(
        SpriteAnimationWidget(
          animation: spriteAnimation,
          animationTicker: spriteAnimation.createTicker(),
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
        final spriteAnimationWidgetFinder = find.byType(
          InternalSpriteAnimationWidget,
        );
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
        final animation2 = SpriteAnimation.spriteList(frames, stepTime: 0.2);
        final animationTicker1 = SpriteAnimationTicker(animation1);
        final animationTicker2 = SpriteAnimationTicker(animation2);

        var animation1Started = false;
        var animation2Started = false;

        animationTicker1.onStart = () => animation1Started = true;
        animationTicker2.onStart = () => animation2Started = true;

        for (var index = 0; index < executionCount; index++) {
          animation1Started = false;
          animation2Started = false;

          await tester.pumpWidget(
            SpriteAnimationWidget(
              animation: animation1,
              animationTicker: animationTicker1,
            ),
          );
          await tester.pump();

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

          await tester.pump();

          expect(animationTicker1.onComplete, isNull);
          expect(animationTicker2.onComplete, isNotNull);

          await tester.pump();
          expect(animation2Started, true);
        }
      },
    );

    testWidgets(
      'does not resets the ticker when has a new animation',
      (tester) async {
        final frames = List.generate(5, (_) => Sprite(image));
        final animation = SpriteAnimation.spriteList(
          frames,
          stepTime: 0.1,
          loop: false,
        );
        final animationTicker = SpriteAnimationTicker(animation);

        animationTicker.setToLast();

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SpriteAnimationWidget(
                      animation: animation,
                      animationTicker: animationTicker,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Change animations'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        animationTicker.setToLast();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(animationTicker.isLastFrame, isTrue);
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

    group('when the image changes', () {
      testWidgets('updates the widget', (tester) async {
        const imagePath = 'test_path_2';
        const imagePath2 = 'test_path_3';

        final image = await generateImage(100, 100);
        final image2 = await generateImage(100, 102);

        Flame.images.add(imagePath, image);
        Flame.images.add(imagePath2, image2);

        final spriteAnimationData = SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
          loop: false,
        );

        var flag = false;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    height: 200,
                    width: 200,
                    child: Wrap(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              flag = !flag;
                            });
                          },
                          child: const Text('Change sprite'),
                        ),
                        SpriteAnimationWidget.asset(
                          path: flag ? imagePath2 : imagePath,
                          data: spriteAnimationData,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );

        await tester.pump();
        await tester.pump();
        await tester.pump();
        await tester.pump();

        var internalWidget = tester.widget<InternalSpriteAnimationWidget>(
          find.byType(InternalSpriteAnimationWidget),
        );

        expect(internalWidget.animation.frames.first.sprite.image, image);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();
        await tester.pump();
        await tester.pump();

        internalWidget = tester.widget<InternalSpriteAnimationWidget>(
          find.byType(InternalSpriteAnimationWidget),
        );

        expect(internalWidget.animation.frames.first.sprite.image, image2);
      });
    });

    group('when the sprite data changes', () {
      group('when the frame length changes', () {
        testWidgets('updates the widget', (tester) async {
          const imagePath = 'test_path_2';

          final image = await generateImage(100, 100);

          Flame.images.add(imagePath, image);

          final spriteAnimationData = SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
            loop: false,
          );

          final spriteAnimationData2 = SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
            loop: false,
          );

          var flag = false;
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: SizedBox(
                      height: 200,
                      width: 200,
                      child: Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                            child: const Text('Change sprite'),
                          ),
                          SpriteAnimationWidget.asset(
                            path: imagePath,
                            data: flag
                                ? spriteAnimationData2
                                : spriteAnimationData,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          await tester.pump();
          await tester.pump();

          var internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(internalWidget.animation.frames, hasLength(1));

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.pump();
          await tester.pump();
          await tester.pump();

          internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(internalWidget.animation.frames, hasLength(2));
        });
      });

      group('when a single frame  changes', () {
        testWidgets('updates the widget', (tester) async {
          const imagePath = 'test_path_2';

          final image = await generateImage(100, 100);

          Flame.images.add(imagePath, image);

          final spriteAnimationData = SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
            loop: false,
          );

          final spriteAnimationData2 = SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 0.1,
            textureSize: Vector2(12, 12),
            loop: false,
          );

          var flag = false;
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: SizedBox(
                      height: 200,
                      width: 200,
                      child: Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                            child: const Text('Change sprite'),
                          ),
                          SpriteAnimationWidget.asset(
                            path: imagePath,
                            data: flag
                                ? spriteAnimationData2
                                : spriteAnimationData,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          await tester.pump();
          await tester.pump();
          await tester.pump();
          await tester.pump();

          var internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(
            internalWidget.animation.frames.first.sprite.srcSize,
            Vector2.all(16),
          );

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.pump();
          await tester.pump();
          await tester.pump();

          internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(
            internalWidget.animation.frames.first.sprite.srcSize,
            Vector2.all(12),
          );
        });
      });

      group('when looping changes', () {
        testWidgets('updates the widget', (tester) async {
          const imagePath = 'test_path_2';

          final image = await generateImage(100, 100);

          Flame.images.add(imagePath, image);

          final spriteAnimationData = SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
            loop: false,
          );

          final spriteAnimationData2 = SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          );

          var flag = false;
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: SizedBox(
                      height: 200,
                      width: 200,
                      child: Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                            child: const Text('Change sprite'),
                          ),
                          SpriteAnimationWidget.asset(
                            path: imagePath,
                            data: flag
                                ? spriteAnimationData2
                                : spriteAnimationData,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          await tester.pump();
          await tester.pump();
          await tester.pump();
          await tester.pump();

          var internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(
            internalWidget.animation.loop,
            isFalse,
          );

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.pump();
          await tester.pump();
          await tester.pump();

          internalWidget = tester.widget<InternalSpriteAnimationWidget>(
            find.byType(InternalSpriteAnimationWidget),
          );

          expect(
            internalWidget.animation.loop,
            isTrue,
          );
        });
      });
    });
  });
}
