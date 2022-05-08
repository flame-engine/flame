import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParentIsA', () {
    testWithFlameGame('successfully sets the parent link', (game) async {
      final parent = _ParentComponent()..addToParent(game);
      final component = _TestComponent()..addToParent(parent);
      await game.ready();

      expect(component.isMounted, true);
      expect(component.parent, isA<_ParentComponent>());
    });

    testWithFlameGame(
      'throws assertion error if the wrong parent is used',
      (game) async {
        final parent = _DifferentComponent()..addToParent(game);
        await game.ready();

        expect(
          () {
            parent.add(_TestComponent());
            game.update(0);
          },
          failsAssert('Parent must be of type _ParentComponent'),
        );
      },
    );
  });
}

class _ParentComponent extends Component {}

class _DifferentComponent extends Component {}

class _TestComponent extends Component with ParentIsA<_ParentComponent> {}
