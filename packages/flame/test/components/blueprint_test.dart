import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGame extends Mock implements FlameGame {}

class MyBlueprint extends Blueprint {
  @override
  void build() {
    add(Component());
    addAll([Component(), Component()]);
  }
}

void main() {
  group('Blueprint', () {
    test('components can be added to it', () {
      final blueprint = MyBlueprint()..build();

      expect(blueprint.components.length, equals(3));
    });

    test('adds the components to a game on attach', () {
      final mockGame = MockGame();
      when(() => mockGame.addAll(any())).thenAnswer((_) async {});
      MyBlueprint().attach(mockGame);

      verify(() => mockGame.addAll(any())).called(1);
    });

    test(
      'throws assertion error when adding to an already attached blueprint',
      () async {
        final mockGame = MockGame();
        when(() => mockGame.addAll(any())).thenAnswer((_) async {});
        final blueprint = MyBlueprint();
        await blueprint.attach(mockGame);

        expect(() => blueprint.add(Component()), throwsAssertionError);
        expect(() => blueprint.addAll([Component()]), throwsAssertionError);
      },
    );
  });
}
