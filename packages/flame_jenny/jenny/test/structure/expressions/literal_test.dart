import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';

void main() {
  group('NumLiteral', () {
    test('simple literal', () {
      const literal = NumLiteral(3.14);
      expect(literal.value, 3.14);
    });

    test('constZero', () {
      expect(constZero.value, 0);
    });

    testScenario(
      testName: 'DecimalNumbers.yarn',
      input: r'''
        // Declarations (i.e. constant values)
        <<declare $myInteger = 1 as Number>>
        <<declare $myFloat = 1.2 as Number>>

        title: Start
        ---

        // Expressions
        <<if 1.2 >= 1.2>>
            Success
        <<endif>>

        // Inline expressions
        Here's a number: {45.1}

        ===
      ''',
      testPlan: '''
        line: Success
        line: Here's a number: 45.1
      ''',
    );
  });

  group('StringLiteral', () {
    test('simple literal', () {
      const literal = StringLiteral('Jenny');
      expect(literal.value, 'Jenny');
    });

    test('constEmptyString', () {
      expect(constEmptyString.value, '');
    });
  });

  group('BoolLiteral', () {
    test('simple literal', () {
      const literal = BoolLiteral(true);
      expect(literal.value, true);
    });

    test('consts', () {
      expect(constTrue.value, true);
      expect(constFalse.value, false);
    });
  });

  group('VoidLiteral', () {
    test('constVoid', () {
      expect(constVoid.value, null);
    });
  });
}
