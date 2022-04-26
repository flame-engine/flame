import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class ParentComponent extends Component {}

class DifferentComponent extends Component {}

class TestComponent extends Component with ParentIsA<ParentComponent> {}

void main() {
  group('ParentIsA', () {
    testWithFlameGame('successfully sets the parent link', (game) async {
      final parent = ParentComponent();
      final component = TestComponent();

      await parent.add(component);
      await game.add(parent);

      expect(component.parent, isA<ParentComponent>());
    });

    testWithFlameGame('throws assertion error when the wrong parent is used',
        (game) async {
      final parent = DifferentComponent();
      final component = TestComponent();

      expect(
        () => parent.add(component),
        failsAssert('Parent must be of type ParentComponent'),
      );
    });
  });
}
