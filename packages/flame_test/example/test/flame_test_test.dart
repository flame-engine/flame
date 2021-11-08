import 'package:example/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

final myGame = FlameTester(() => MyGame());
void main() {
  group('flameTest', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    myGame.test(
      'can load the game',
      (game) {
        expect(game.children.length, 1);
      },
    );

    myGame.widgetTest(
      'render the game widget',
      (game, tester) async {
        expect(
          find.byGame<MyGame>(),
          findsOneWidget,
        );
      },
    );
  });
}
