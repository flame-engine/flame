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

    test('various numeric literals', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          Integers\: {5} {0} {-0} {777} {1000000000}
          Decimals\: {3.5} {0.0} {-0.0} {16.99} {-7.00000}
          // Scientific\: {7e5} {1.6e-2} {2e+100}
          // Hexadecimal: {0x100}
          ===
        ''',
        testPlan: '''
          line: Integers: 5 0 0 777 1000000000
          line: Decimals: 3.5 0 0 16.99 -7
          // line: Scientific: 700000 0.16 2.0e100
          // line: Hexadecimal: 256
        ''',
      );
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

    test('various string literals', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          Double quoted: { "one two three" }
          Single quoted: { 'four five six' }
          Escapes\: { '12 o\'clock' }
          No interpolation: { "Hello, {$world}" }
          ===
        ''',
        testPlan: r'''
          line: Double quoted: one two three
          line: Single quoted: four five six
          line: Escapes: 12 o'clock
          line: No interpolation: Hello, {$world}
        ''',
      );
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
