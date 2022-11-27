import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Add', () {
    test('x + y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {5 + 7}
          {3.5 + 2}
          {1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9}
          {'Yarn' + 'Spinner'}
          { 'Hello' + ', ' + 'World' + '!' }
          ===
        ''',
        testPlan: '''
          line: 12
          line: 5.5
          line: 45
          line: YarnSpinner
          line: Hello, World!
        ''',
      );
    });

    test('wrong argument types 1', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{2 + false}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `+` must be numeric or '
          'strings, instead the types are (numeric, boolean)\n'
          '>  at line 3 column 4:\n'
          '>  {2 + false}\n'
          '>     ^\n',
        ),
      );
    });

    test('wrong argument types 2', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"Hey" + 3}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `+` must be numeric or '
          'strings, instead the types are (string, numeric)\n'
          '>  at line 3 column 8:\n'
          '>  {"Hey" + 3}\n'
          '>         ^\n',
        ),
      );
    });
  });
}
