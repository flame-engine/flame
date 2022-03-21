import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockForge2dGame extends Mock implements Forge2DGame {}

class MockContactCallback extends Mock
    implements ContactCallback<Object, Object> {}

class FakeContactCallback extends ContactCallback<Object, Object> {}

class MyForge2dBlueprint extends Forge2DBlueprint {
  @override
  void build() {
    addContactCallback(MockContactCallback());
    addAllContactCallback([MockContactCallback(), MockContactCallback()]);
  }
}

void main() {
  group('Forge2DBlueprint', () {
    setUpAll(() {
      registerFallbackValue(FakeContactCallback());
    });

    test('callbacks can be added to it', () {
      final blueprint = MyForge2dBlueprint()..build();

      expect(blueprint.callbacks.length, equals(3));
    });

    test('adds the callbacks to a game on attach', () async {
      final mockGame = MockForge2dGame();
      when(() => mockGame.addAll(any())).thenAnswer((_) async {});
      when(() => mockGame.addContactCallback(any())).thenAnswer((_) async {});
      await MyForge2dBlueprint().attach(mockGame);

      verify(() => mockGame.addContactCallback(any())).called(3);
    });

    test(
      'throws assertion error when adding to an already attached blueprint',
      () async {
        final mockGame = MockForge2dGame();
        when(() => mockGame.addAll(any())).thenAnswer((_) async {});
        when(() => mockGame.addContactCallback(any())).thenAnswer((_) async {});
        final blueprint = MyForge2dBlueprint();
        await blueprint.attach(mockGame);

        expect(
          () => blueprint.addContactCallback(MockContactCallback()),
          throwsAssertionError,
        );
        expect(
          () => blueprint.addAllContactCallback([MockContactCallback()]),
          throwsAssertionError,
        );
      },
    );

    test('throws assertion error when used on a non Forge2dGame', () {
      expect(
        () => MyForge2dBlueprint().attach(FlameGame()),
        throwsAssertionError,
      );
    });
  });
}
