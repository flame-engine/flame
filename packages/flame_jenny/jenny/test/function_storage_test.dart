import 'package:jenny/jenny.dart';
import 'package:jenny/src/function_storage.dart';
import 'package:test/test.dart';

import 'test_scenario.dart';
import 'utils.dart';

void main() {
  group('FunctionStorage', () {
    test('basic properties', () {
      final functions = FunctionStorage();
      expect(functions.length, 0);
      expect(functions.isEmpty, true);
      expect(functions.isNotEmpty, false);

      functions.addFunction0('t', () => 0);
      expect(functions.length, 1);
      expect(functions.isEmpty, false);
      expect(functions.isNotEmpty, true);
    });

    test('valid return types', () {
      final yarn = YarnProject();
      yarn.functions
        ..addFunction0('fn_bool', () => false)
        ..addFunction0('fn_int', () => 1)
        ..addFunction0('fn_double', () => 1.5)
        ..addFunction0('fn_num', () => num.parse('3'))
        ..addFunction0('fn_string', () => 'Jenny');
      testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          {fn_bool()}
          {fn_int()}
          {fn_double()}
          {fn_num()}
          {fn_string()}
          ===
        ''',
        testPlan: '''
          line: false
          line: 1
          line: 1.5
          line: 3
          line: Jenny
        ''',
      );
    });

    test('valid argument types', () {
      final yarn = YarnProject();
      yarn.functions
        ..addFunction2('fn_bool', (bool x, bool? y) => y ?? x)
        ..addFunction2('fn_int', (int x, int? y) => y ?? x)
        ..addFunction2('fn_double', (double x, double? y) => y ?? x)
        ..addFunction2('fn_num', (num x, num? y) => y ?? x)
        ..addFunction2('fn_string', (String x, String? y) => y ?? x)
        ..addFunction1('fn_yarn', (YarnProject yarn) => yarn.functions.length);

      testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          {fn_bool(true, false)}
          {fn_int(5, 9)}
          {fn_double(2.2, 1.5)}
          {fn_num(3, 7.5)}
          {fn_string('Jenny', 'Flame')}
          number of user-defined functions = {fn_yarn()}
          ===
        ''',
        testPlan: '''
          line: false
          line: 9
          line: 1.5
          line: 7.5
          line: Flame
          line: number of user-defined functions = 6
        ''',
      );
    });

    test('functions with different arities', () {
      final yarn = YarnProject();
      yarn.functions
        ..addFunction0('sum0', () => 0)
        ..addFunction1('sum1', (num x) => x)
        ..addFunction2('sum2', (num x, num y) => x + y)
        ..addFunction3('sum3', (num x, num y, num z) => x + y + z)
        ..addFunction4('sum4', (num w, num x, num y, num z) => w + x + y + z);

      testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          {sum0()}
          {sum1(1)}
          {sum2(1, 2)}
          {sum3(1, 2, 3)}
          {sum4(1, 2, 3, 4)}
          ===
        ''',
        testPlan: '''
          line: 0
          line: 1
          line: 3
          line: 6
          line: 10
        ''',
      );
    });

    test('functions with optional arguments', () {
      final yarn = YarnProject();
      yarn.functions.addFunction4(
        'sum',
        (num? w, num? x, num? y, num? z) =>
            (w ?? 0) + (x ?? 0) + (y ?? 0) + (z ?? 0),
      );
      testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          {sum()}
          {sum(1)}
          {sum(1, 2)}
          {sum(1, 2, 3)}
          {sum(1, 2, 3, 4)}
          {sum(100)}
          ===
        ''',
        testPlan: '''
          line: 0
          line: 1
          line: 3
          line: 6
          line: 10
          line: 100
        ''',
      );
    });

    test('Functions.yarn', () async {
      final yarn = YarnProject();
      yarn.functions.addFunction3(
        'add_three_operands',
        (num x, num y, num z) => x + y + z,
      );
      await testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          // Function tests
          // "add_three_operands" is a function that sums three operands
          assert -> { add_three_operands(1, 2, 4*1) == 7 }
          
          // function calls as parameters
          assert -> {add_three_operands(1, 2, add_three_operands(1,2,3)) == 9}
          ===
        ''',
        testPlan: '''
          line: assert -> true
          line: assert -> true
        ''',
      );
    });

    group('errors', () {
      test('invalid function name', () {
        for (final name in ['', '++', 'very nice', '1object']) {
          expect(
            () => FunctionStorage().addFunction0(name, () => 0),
            throwsAssertionError('Function name "$name" is not an identifier'),
          );
        }
      });

      test('overriding builtin functions', () {
        for (final name in ['bool', 'random', 'dice', 'string']) {
          expect(
            () => FunctionStorage().addFunction0(name, () => 0),
            throwsAssertionError('Function $name() is built-in'),
          );
        }
      });

      test('invalid return types', () {
        expect(
          () => YarnProject().functions.addFunction0('test', () => null),
          hasTypeError(
            'TypeError: Unsupported return type <Null>, expected one of: bool, '
            'int, double, num, or String',
          ),
        );
        expect(
          () => YarnProject().functions.addFunction0('test', () => [3]),
          hasTypeError(
            'TypeError: Unsupported return type <List<int>>, expected one of: '
            'bool, int, double, num, or String',
          ),
        );
        expect(
          () => YarnProject()
              .functions
              .addFunction1('test', (int x) => x > 0 ? x : null),
          hasTypeError(
            'TypeError: Unsupported return type <int?>, expected one of: '
            'bool, int, double, num, or String',
          ),
        );
      });

      test('invalid argument types', () {
        final functions = FunctionStorage();
        expect(
          () => functions.addFunction1('t', (Type t) => 1),
          hasTypeError(
            'TypeError: Unsupported type <Type> for argument at index 0',
          ),
        );
        expect(
          () => functions.addFunction2('tt', (int x, List<int> z) => 1),
          hasTypeError(
            'TypeError: Unsupported type <List<int>> for argument at index 1',
          ),
        );
      });

      test('misplaced YarnProject argument', () {
        expect(
          () => FunctionStorage()
              .addFunction2('test', (int x, YarnProject yarn) => 0),
          hasTypeError(
            'TypeError: Argument of type YarnProject must be the first in a '
            'function',
          ),
        );
      });

      test('misplaced optional arguments', () {
        expect(
          () => FunctionStorage()..addFunction2('t', (int? x, int y) => y),
          hasTypeError(
            'TypeError: Required arguments must come before the optional',
          ),
        );
      });

      test('too few arguments in a function call', () {
        final yarn = YarnProject();
        yarn.functions.addFunction3('sum', (num x, num y, num? z) => x + y);
        expect(
          () => yarn.parse(
            'title:A\n---\n'
            '{sum(5)}\n'
            '===\n',
          ),
          hasTypeError(
            'TypeError: Function sum() expects at least 2 arguments\n'
            '>  at line 3 column 7:\n'
            '>  {sum(5)}\n'
            '>        ^\n',
          ),
        );
      });

      test('too many arguments in a function call', () {
        final yarn = YarnProject();
        yarn.functions.addFunction1('add1', (num x) => x + 1);
        expect(
          () => yarn.parse(
            'title:A\n---\n'
            '{add1(5, 7, 11)}\n'
            '===\n',
          ),
          hasTypeError(
            'TypeError: Function add1() expects 1 argument\n'
            '>  at line 3 column 10:\n'
            '>  {add1(5, 7, 11)}\n'
            '>           ^\n',
          ),
        );
      });

      test('invalid argument types', () {
        final yarn = YarnProject();
        yarn.functions.addFunction3(
          'sum',
          (num x, num y, num z) => x + y + z,
        );
        expect(
          () => yarn.parse(
            'title:A\n---\n'
            '{sum(5, false, 11)}\n'
            '===\n',
          ),
          hasTypeError(
            'TypeError: Invalid type for argument 1: expected numeric but '
            'received boolean\n'
            '>  at line 3 column 9:\n'
            '>  {sum(5, false, 11)}\n'
            '>          ^\n',
          ),
        );
      });
    });
  });
}
