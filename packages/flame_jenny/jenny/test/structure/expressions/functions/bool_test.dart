import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('BoolFn', () {
    test('bool() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {bool(0)} {bool(1)} {bool(0.005)}
          {bool(false)} {bool(true)}
          {bool("true")} {bool("True")} {bool("  TRUE  ")}
          {bool("false")} {bool("False")} {bool("FALSE")} {bool("fAlSe")}
          ===
        ''',
        testPlan: '''
          line: false true true
          line: false true
          line: true true true
          line: false false false false
        ''',
      );
    });

    test('bool() with bad argument', () {
      void expectFails(String arg) {
        final yarn = YarnProject()
          ..parse(
            'title:A\n---\n'
            '{bool("$arg")}\n'
            '===\n',
          );
        final line = yarn.nodes['A']!.lines.first as DialogueLine;
        expect(
          line.evaluate,
          hasDialogueError(
            'String value "$arg" cannot be interpreted as a boolean',
          ),
        );
      }

      expectFails('');
      expectFails('T');
      expectFails('t r u e');
      expectFails('tru');
      expectFails('true 1');
      expectFails('1');
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{bool()}\n===\n'),
        hasTypeError(
          'TypeError: function bool() requires a single argument\n'
          '>  at line 3 column 7:\n'
          '>  {bool()}\n'
          '>        ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{bool(3, 6)}\n===\n'),
        hasTypeError(
          'TypeError: function bool() requires a single argument\n'
          '>  at line 3 column 10:\n'
          '>  {bool(3, 6)}\n'
          '>           ^\n',
        ),
      );
    });
  });
}
