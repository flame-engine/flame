import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('VariableStorage', () {
    test('empty', () {
      final storage = VariableStorage();
      expect(storage.length, 0);
      expect(storage.isEmpty, true);
      expect(storage.isNotEmpty, false);
      expect(storage.hasVariable('x'), false);
    });

    test('store numeric variable', () {
      final storage = VariableStorage();
      storage.setVariable('x', 42);
      expect(storage.hasVariable('x'), true);
      expect(storage.getVariable('x'), 42);
      expect(storage.getVariableType('x'), ExpressionType.numeric);
      expect(storage.getNumericValue('x'), 42);
    });

    test('store string variable', () {
      final storage = VariableStorage();
      storage.setVariable('s', 'Flame');
      expect(storage.hasVariable('s'), true);
      expect(storage.getVariable('s'), 'Flame');
      expect(storage.getVariableType('s'), ExpressionType.string);
      expect(storage.getStringValue('s'), 'Flame');
    });

    test('store boolean variable', () {
      final storage = VariableStorage();
      storage.setVariable('b', true);
      expect(storage.hasVariable('b'), true);
      expect(storage.getVariable('b'), true);
      expect(storage.getVariableType('b'), ExpressionType.boolean);
      expect(storage.getBooleanValue('b'), true);
    });

    test('unknown variable type', () {
      final storage = BadVariableStorage();
      expect(storage.hasVariable('x'), true);
      expect(storage.getVariableType('x'), ExpressionType.unknown);
    });

    test('setVariable to unknown type', () {
      final storage = VariableStorage();
      expect(
        () => storage.setVariable('xyz', [1, 2, 3]),
        hasDialogueError(
          'Cannot set variable xyz to a value with type List<int>',
        ),
      );
    });

    test('setVariable to a different type', () {
      final storage = VariableStorage();
      storage.setVariable('xyz', true);
      expect(
        () => storage.setVariable('xyz', 7),
        hasDialogueError(
          'Redefinition of variable xyz from type bool to int is not allowed',
        ),
      );
    });
  });
}

class BadVariableStorage extends VariableStorage {
  BadVariableStorage() {
    variables['x'] = null;
  }
}
