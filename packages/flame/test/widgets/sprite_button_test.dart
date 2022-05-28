import 'package:flame/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final image = await generateImage();
  group('SpriteButton', () {
    testWidgets('has no FutureBuilder when pass animation', (tester) async {
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

      final futureBuilder = find.byType(FutureBuilder);
      final nineTileBoxWidgetFinder = find.byType(SpriteButton);

      expect(futureBuilder, findsNothing);
      expect(nineTileBoxWidgetFinder, findsOneWidget);
    });
    testWidgets(
      'has FutureBuilder when pass asset path',
      (tester) async {
        ///How can I test this...?
      },
      skip: true,
    );
  });
}
