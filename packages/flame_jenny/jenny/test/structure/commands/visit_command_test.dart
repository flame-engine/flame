import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('VisitCommand', () {
    test('tokenize bare-word node target', () {
      expect(
        tokenize('<<visit WhiteHouse>>'),
        const [
          Token.startCommand,
          Token.commandVisit,
          Token.id('WhiteHouse'),
          Token.endCommand,
        ],
      );
    });

    test('tokenize expression node target', () {
      expect(
        tokenize(r'<<visit {$destination}>>'),
        const [
          Token.startCommand,
          Token.commandVisit,
          Token.startExpression,
          Token.variable(r'$destination'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('<<visit>> command parsing', () {
      final yarn = YarnProject()
        ..variables.setVariable(r'$target', 'Y')
        ..parse(
          'title:A\n---\n'
          '<<visit X>>\n'
          '<<visit {\$target}>>\n'
          '===\n',
        );
      final node = yarn.nodes['A']!;
      expect(node.lines.length, 2);
      expect(node.lines[0], isA<VisitCommand>());
      expect(node.lines[1], isA<VisitCommand>());
      expect((node.lines[0] as VisitCommand).target.value, 'X');
      expect((node.lines[1] as VisitCommand).target.value, 'Y');
    });

    test('visiting another node', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          First line
          <<visit Second>>
          Second line
          ===

          title: Second
          ---
          Just visiting!
          ===
        ''',
        testPlan: '''
          line: First line
          line: Just visiting!
          line: Second line
        ''',
      );
    });

    test('nested visits', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          Alpha
          <<visit V1>>
          Beta
          <<visit V2>>
          Gamma
          ===

          title: V1
          ---
          Delta
          <<visit V2>>
          Eta
          ===

          title: V2
          ---
          <<visit V3>>
          Omega
          ===

          title: V3
          ---
          Rho
          ===
        ''',
        testPlan: '''
          line: Alpha
          line: Delta
          line: Rho
          line: Omega
          line: Eta
          line: Beta
          line: Rho
          line: Omega
          line: Gamma
        ''',
      );
    });

    test('visit node from expression', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $index = 2>>
          Line before
          <<visit {"Destination" + "_" + string($index)}>>
          Line after
          ===
          ---
          title: Destination_2
          ---
          Here
          ===
        ''',
        testPlan: '''
          line: Line before
          line: Here
          line: Line after
        ''',
      );
    });

    test('visit node with jumps', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          First line of <Start> node
          <<visit Another>>
          And we're back in the <Start> node
          ===
          --------------
          title: Another
          --------------
          Inside <Another> node
          <<jump Somewhere>>
          This line shouldn't be seen...
          ===
          ----------------
          title: Somewhere
          ----------------
          Reached <Somewhere> node
          <<stop>>
          ERROR!
          ===
        ''',
        testPlan: '''
          line: First line of <Start> node
          line: Inside <Another> node
          line: Reached <Somewhere> node
          line: And we're back in the <Start> node
        ''',
      );
    });

    group('errors', () {
      test('<<visit>> at root level', () {
        expect(
          () => YarnProject()..parse('<<visit Start>>\n'),
          hasTypeError(
            'TypeError: command <<visit>> is only allowed inside nodes\n'
            '>  at line 1 column 1:\n'
            '>  <<visit Start>>\n'
            '>  ^\n',
          ),
        );
      });

      test('<<visit>> invalid syntax', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n'
              '<<visit "Target_\$index">>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: an ID or an expression in curly braces expected\n'
            '>  at line 3 column 9:\n'
            '>  <<visit "Target_\$index">>\n'
            '>          ^\n',
          ),
        );
      });

      test('<<visit>> with unknown destination', () {
        final yarn = YarnProject()
          ..parse(
            'title: A\n'
            '---\n'
            '<<visit Somewhere>>\n'
            '===\n',
          );
        expect(
          () => DialogueRunner(
            yarnProject: yarn,
            dialogueViews: [],
          ).startDialogue('A'),
          hasNameError('NameError: Node "Somewhere" could not be found'),
        );
      });
    });
  });
}
