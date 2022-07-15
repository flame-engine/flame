import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestInheritedComponentA extends InheritedComponent {}

class _TestInheritedComponentB extends InheritedComponent {}

void main() {
  group('Component Inheritance', () {
    group('dependOnInheritedComponentOfExactType', () {
      testWithFlameGame(
        'retrieves an InheritedComponent',
        (game) async {
          final parent = _TestInheritedComponentA();
          final child = Component();

          parent.add(child);
          await game.ensureAdd(parent);

          expect(
            child.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentA>(),
            parent,
          );
        },
      );

      testWithFlameGame(
        'retrieves closest InheritedComponent',
        (game) async {
          final grandParent = _TestInheritedComponentA();
          final parent = _TestInheritedComponentA();
          final child = Component();

          grandParent.add(parent);
          parent.add(child);
          await game.ensureAdd(grandParent);

          expect(
            child.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentA>(),
            parent,
          );
          expect(
            parent.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentA>(),
            grandParent,
          );
          expect(
            grandParent.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentA>(),
            null,
          );
        },
      );

      testWithFlameGame(
        'retrieves multiple InheritedComponents',
        (game) async {
          final grandParent = _TestInheritedComponentA();
          final parent = _TestInheritedComponentB();
          final child = Component();

          grandParent.add(parent);
          parent.add(child);
          await game.ensureAdd(grandParent);

          expect(
            child.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentB>(),
            parent,
          );
          expect(
            child.dependOnInheritedComponentOfExactType<
                _TestInheritedComponentA>(),
            grandParent,
          );
        },
      );
    });
  });
}
