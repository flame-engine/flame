import 'package:example/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flameTest', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    flameTest<MyGame>(
      'can load the game',
      createGame: () => MyGame(),
      verify: (game) {
        expect(game.children.length, 1);
      },
    );

    flameWidgetTest(
      'render the game widget',
      createGame: () => MyGame(),
      verify: (game, tester) async {
        expect(
          find.byGame<MyGame>(),
          findsOneWidget,
        );
      },
    );
  });
}
