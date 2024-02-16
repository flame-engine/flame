import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class TestGame extends FlameGame with FlameIsolate {}

class IsolateComponent extends Component with FlameIsolate {}

void main() {
  testWithGame<TestGame>(
    'Test running isolateCompute on game',
    TestGame.new,
    (game) async {
      final result = game.isolateCompute(_pow, 10);
      await expectLater(result, completion(100));
    },
  );
  testWithGame<TestGame>(
    'Test running isolateComputeStream on game',
    TestGame.new,
    (game) async {
      final result = game.isolateComputeStream(_messages, 10);
      await expectLater(result, emitsInOrder([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
    },
  );

  group('Test isolate in sub-component', () {
    testWithFlameGame(
      'Running isolateCompute in sub-component',
      (game) async {
        final isolateComponent = IsolateComponent();
        await game.add(isolateComponent);
        await game.ready();
        final result = isolateComponent.isolateCompute(_pow, 4);
        await expectLater(result, completion(16));
      },
    );

    testWithFlameGame(
      'Running isolateComputeStream in sub-component',
      (game) async {
        final isolateComponent = IsolateComponent();
        await game.add(isolateComponent);
        await game.ready();
        final result = isolateComponent.isolateComputeStream(_messages, 4);
        await expectLater(result, emitsInOrder([1, 2, 3, 4]));
      },
    );

    testWithFlameGame(
      'Running isolateCompute or isolateComputeStream after remove gives error',
      (game) async {
        final isolateComponent = IsolateComponent();
        await game.add(isolateComponent);
        await game.ready();

        final result = isolateComponent.isolateCompute(_pow, 4);
        await expectLater(result, completion(16));

        game.remove(isolateComponent);
        await game.ready();

        expect(
          () => isolateComponent.isolateCompute(_pow, 4),
          throwsA(
            isA<TypeError>().having(
              (error) => error.toString(),
              'Explicit non null assertion',
              'Null check operator used on a null value',
            ),
          ),
        );

        expect(
          () => isolateComponent.isolateComputeStream(_messages, 4),
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

Stream<int> _messages(int amount) async* {
  for (var i = 1; i <= amount; i++) {
    yield i;
  }
}
