import 'package:flame_test/flame_test.dart';
import 'package:flame_test_example/game.dart';
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

    myGame.testGameWidget(
      'render the game widget',
      verify: (game, tester) async {
        expect(
          find.byGame<MyGame>(),
          findsOneWidget,
        );
      },
    );

    myGame.testGameWidget(
      'render the background correctly',
      setUp: (game, _) async {
        await game.ready();
        await game.ensureAdd(Background());
      },
      verify: (game, tester) async {
        await expectLater(
          find.byGame<MyGame>(),
          matchesGoldenFile('goldens/game.png'),
        );
      },
    );
  });
}
