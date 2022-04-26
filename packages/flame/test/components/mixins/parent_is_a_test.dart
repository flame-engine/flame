import 'package:flame/components.dart';
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

    test('throws assertion error when the wrong parent is used', () {
      final parent = DifferentComponent();
      final component = TestComponent();

      parent.add(component);

      expect(
        component.onMount,
        failsAssert('Parent must be of type ParentComponent'),
      );
    });
  });
}
