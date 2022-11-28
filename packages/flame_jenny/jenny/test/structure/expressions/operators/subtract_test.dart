import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Subtract', () {
    test('x - y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {5 - 7}
          {3.5 - 2}
          {'Yarn' - 'Spinner'}
          { 'Hello' - 'Hell' - 'Paradise' }
          ===
        ''',
        testPlan: '''
          line: -2
          line: 1.5
          line: Yarn
          line: o
        ''',
      );
    });

    test('x -= y', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $x = 7>>
          <<local $world = "World">>
          <<set $x -= 3>>
          <<set $world -= 'l'>>
          {$x}
          {$world}
          ===
        ''',
        testPlan: '''
          line: 4
          line: Word
        ''',
      );
    });

    test('wrong argument types 1', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{2 - false}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `-` must be numeric or '
          'strings, instead the types are (numeric, boolean)\n'
          '>  at line 3 column 4:\n'
          '>  {2 - false}\n'
          '>     ^\n',
        ),
      );
    });

    test('wrong argument types 2', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"Hey" - 3}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `-` must be numeric or '
          'strings, instead the types are (string, numeric)\n'
          '>  at line 3 column 8:\n'
          '>  {"Hey" - 3}\n'
          '>         ^\n',
        ),
      );
    });
  });
}
