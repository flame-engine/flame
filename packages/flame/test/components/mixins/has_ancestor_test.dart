import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasAncestor', () {
    testWithFlameGame('successfully sets the ancestor link', (game) async {
      final ancestor = _AncestorComponent()..addToParent(game);
      final inBetween = _InBetweenComponent()..addToParent(ancestor);
      final component = _TestComponent()..addToParent(inBetween);
      await game.ready();

      expect(component.isMounted, true);
      expect(component.ancestor, isA<_AncestorComponent>());
    });

    testWithFlameGame(
      'throws assertion error if the wrong ancestor is used',
      (game) async {
        final ancestor = _DifferentComponent()..addToParent(game);
        final inBetween = _InBetweenComponent()..addToParent(ancestor);
        await game.ready();

        expect(
          () {
            inBetween.add(_TestComponent());
            game.update(0);
          },
          failsAssert(
            '''An ancestor must be of type _AncestorComponent in the component tree''',
          ),
        );
      },
    );
  });
}

class _AncestorComponent extends Component {}

class _InBetweenComponent extends Component {}

class _DifferentComponent extends Component {}

class _TestComponent extends Component with HasAncestor<_AncestorComponent> {}
