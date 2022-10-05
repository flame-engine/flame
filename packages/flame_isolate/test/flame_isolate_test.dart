import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class TestGame extends FlameGame with FlameIsolate {}

class IsolateComponent extends Component with FlameIsolate {}

void main() {
  testWithGame<TestGame>(
    'Test running function in isolate',
    TestGame.new,
    (game) async {
      final result = await game.isolate(_pow, 10);
      expect(result, 100);
    },
  );

  group('Test isolate in subcomponent', () {
    testWithFlameGame(
      'Running isolate in subcomponent',
      (game) async {
        final isolateComponent = IsolateComponent();
        await game.add(isolateComponent);
        await game.ready();
        final result = await isolateComponent.isolate(_pow, 4);
        expect(result, 16);
      },
    );

    testWithFlameGame(
      'Running isolate in after remove gives error',
      (game) async {
        final isolateComponent = IsolateComponent();
        await game.add(isolateComponent);
        await game.ready();

        final result = await isolateComponent.isolate(_pow, 4);
        expect(result, 16);

        game.remove(isolateComponent);
        await game.ready();

        expect(
          () => isolateComponent.isolate(_pow, 4),
          throwsA(
            isA<TypeError>().having(
              (error) => error.toString(),
              'Explicit non null assertion',
              'Null check operator used on a null value',
            ),
          ),
        );
      },
    );
  });
}

int _pow(int message) {
  return message * message;
}
