
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaintDecorator', () {

    testWidgets('nnnn', (tester) async {
      await tester.pumpWidget(Center(
          child: SizedBox(
          height: 100,
          width: 80,
          child: RepaintBoundary(child: GameWidget(game: MyGame()))
      )));
      await tester.pump();
      expect(find.byType(GameWidget<MyGame>), findsOneWidget);
      await expectLater(
        find.byType(GameWidget<MyGame>),
        matchesGoldenFile('nnn.png'),
      );
    });
  });
}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xffff0000);
}
