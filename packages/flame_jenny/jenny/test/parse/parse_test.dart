import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/parse.dart';
import 'package:jenny/src/structure/commands/if_command.dart';
import 'package:jenny/src/structure/commands/jump_command.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  // The tests here are further organized into subgroups according to which
  // part of the parser they engage.
  group('parse', () {
    group('parseMain', () {
      test('empty input', () {
        final yarn = YarnProject();
        parse('', yarn);
        expect(yarn.nodes.isEmpty, true);
        expect(yarn.variables.isEmpty, true);
      });

      test('single node', () {
        final yarn = YarnProject();
        parse(
          'title: Alpha\n'
          '---\n'
          '===\n',
          yarn,
        );
        expect(yarn.nodes.length, 1);
        expect(yarn.nodes.containsKey('Alpha'), true);
      });

      test('multiple nodes', () {
        final yarn = YarnProject();
        parse(
          'title: Alpha\n---\n===\n'
          ' // another node\n'
          'title: Beta\n---\n===\n'
          'title: Gamma\n---\n===\n',
          yarn,
        );
        expect(yarn.nodes.length, 3);
        expect(yarn.nodes.containsKey('Alpha'), true);
        expect(yarn.nodes.containsKey('Beta'), true);
        expect(yarn.nodes.containsKey('Gamma'), true);
      });
    });

    group('parseNodeHeader', () {
      test('node with tags', () {
        final yarn = YarnProject();
        yarn.parse('title: Romeo v Juliette\n'
            'requires: Montagues and Capulets\n'
            '\n'
            '// comment\n'
            'location: fair Verona\n'
            '---\n===\n');
        final node = yarn.nodes['Romeo v Juliette'];
        expect(node, isNotNull);
        expect(node!.title, 'Romeo v Juliette');
        expect(node.tags, isNotNull);
        expect(node.tags!['requires'], 'Montagues and Capulets');
        expect(node.tags!['location'], 'fair Verona');
      });

      test('multiple colons', () {
        expect(
          () => YarnProject().parse('title:: Hamlet\n---\n===\n'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 1 column 7:\n'
              '>  title:: Hamlet\n'
              '>        ^\n'),
        );
      });

      test('node without a title', () {
        expect(
          () => YarnProject().parse('Title: Despicable Me!\n---\n===\n'),
          hasSyntaxError('SyntaxError: node does not have a title\n'
              '>  at line 2 column 1:\n'
              '>  ---\n'
              '>  ^\n'),
        );
      });

      test('node with multiple titles', () {
        expect(
          () => YarnProject().parse('\n'
              'title: one\n'
              'keyword: value\n'
              'title: two\n'
              '---\n===\n'),
          hasSyntaxError('SyntaxError: a node can only have one title\n'
              '>  at line 4 column 1:\n'
              '>  title: two\n'
              '>  ^\n'),
        );
      });

      test('multiple nodes with same titles', () {
        expect(
          () => YarnProject().parse('\n'
              'title: xyz\n'
              '---\n===\n'
              'title: xyz\n'
              '---\n===\n'),
          hasNameError(
            'NameError: node with title "xyz" has already been defined\n'
            '>  at line 5 column 1:\n'
            '>  title: xyz\n'
            '>  ^\n',
          ),
        );
      });
    });

    group('parseNodeBody', () {
      test('indent in a body', () {
        expect(
          () => YarnProject().parse('title:a\n---\n    hi\n===\n'),
          hasSyntaxError('SyntaxError: unexpected indent\n'
              '>  at line 3 column 1:\n'
              '>      hi\n'
              '>  ^\n'),
        );
      });
    });

    group('parseStatementList', () {
      test('multiple lines', () {
        final yarn = YarnProject()
          ..parse('title: test\n'
              '---\n'
              'Jupyter\n'
              'Saturn\n\n'
              'Uranus  // LOL\n'
              '===\n');
        final block = yarn.nodes['test']!.content;
        expect(block.lines.length, 3);
        for (var i = 0; i < 3; i++) {
          expect(block.lines[i], isA<DialogueLine>());
          final line = block.lines[i] as DialogueLine;
          expect(line.character, isNull);
          expect(line.tags, isEmpty);
          expect(line.text, ['Jupyter', 'Saturn', 'Uranus'][i]);
        }
      });
    });

    group('parseDialogueLine', () {
      test('line with a speaker', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\nMrGoo: whatever\n===\n');
        expect(yarn.nodes['A']!.lines.first, isA<DialogueLine>());
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        expect(line.character, 'MrGoo');
        expect(line.text, 'whatever');
      });

      test('line with multiple expressions', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n{1} {false} {"fake news"}\n===\n');
        expect(yarn.nodes['A']!.lines.first, isA<DialogueLine>());
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        line.evaluate();
        expect(line.character, isNull);
        expect(line.text, '1 false fake news');
      });

      test('line with hashtags', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n.hello #here #zzz\n===\n');
        final node = yarn.nodes['A']!;
        expect(node.lines.length, 1);
        final line = node.lines[0] as DialogueLine;
        expect(line.tags.length, 2);
        expect(line.tags, contains('#here'));
        expect(line.tags, contains('#zzz'));
      });

      test('line starting with an escaped character', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '\\{ curly text \\}\n'
              '===\n');
        expect(
          (yarn.nodes['A']!.lines[0] as DialogueLine).text,
          '{ curly text }',
        );
      });

      test('line with a command', () {
        expect(
          () => YarnProject().parse('title:A\n---\nz <<if true>>\n===\n'),
          hasSyntaxError(
              'SyntaxError: commands are not allowed on a dialogue line\n'
              '>  at line 3 column 3:\n'
              '>  z <<if true>>\n'
              '>    ^\n'),
        );
      });

      test('line with no content but a hashtag', () {
        expect(
          () => YarnProject().parse('title:A\n---\n#tag\n===\n'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 3 column 1:\n'
              '>  #tag\n'
              '>  ^\n'),
        );
      });
    });

    group('parseOption', () {
      test('simple options', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '-> Alpha\n'
              '-> Beta\n'
              '->    Gamma\n'
              '===\n');
        final node = yarn.nodes['test']!;
        expect(node.lines.length, 1);
        final choiceSet = node.lines.first as DialogueChoice;
        expect(choiceSet.options.length, 3);
        for (var i = 0; i < 3; i++) {
          final line = choiceSet.options[i];
          expect(line.character, isNull);
          expect(line.tags, isNull);
          expect(line.condition, isNull);
          expect(line.block, isEmpty);
          expect(line.value, ['Alpha', 'Beta', 'Gamma'][i]);
        }
      });

      test('speakers in options', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '-> Alice: Hello!\n'
              '-> Bob: Hi: there!\n'
              '===\n');
        final node = yarn.nodes['A']!;
        final choice = node.lines[0] as DialogueChoice;
        final option0 = choice.options[0];
        final option1 = choice.options[1];
        expect(option0.character, 'Alice');
        expect(option1.character, 'Bob');
        expect(option0.value, 'Hello!');
        expect(option1.value, 'Hi: there!');
      });

      test('option with a followup dialogue', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '-> choice one\n'
              '    Nice one, James!\n'
              '    Back to ya!\n'
              '-> choice two\n'
              '    My condolences...\n'
              '===\n');
        final node = yarn.nodes['A']!;
        final choiceSet = node.lines[0] as DialogueChoice;
        expect(choiceSet.options.length, 2);
        final choice1 = choiceSet.options[0];
        final choice2 = choiceSet.options[1];
        expect(choice1.value, 'choice one');
        expect(choice1.block, isNotNull);
        expect(choice1.block.length, 2);
        expect(
          (choice1.block.lines[0] as DialogueLine).text,
          'Nice one, James!',
        );
        expect(
          (choice1.block.lines[1] as DialogueLine).text,
          'Back to ya!',
        );
        expect(choice2.value, 'choice two');
        expect(choice2.block, isNotNull);
        expect(choice2.block.lines.length, 1);
        expect(
          (choice2.block.lines[0] as DialogueLine).text,
          'My condolences...',
        );
      });

      test('option with a non-if command', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n-> ok! <<stop>>\n===\n',
          ),
          hasSyntaxError(
              'SyntaxError: only "if" command is allowed for an option\n'
              '>  at line 3 column 10:\n'
              '>  -> ok! <<stop>>\n'
              '>           ^\n'),
        );
      });

      test('option with a non-boolean condition', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n'
            '-> ok! <<if 42 % 2>>\n'
            '===\n',
          ),
          hasTypeError('TypeError: the condition in "if" should be boolean\n'
              '>  at line 3 column 13:\n'
              '>  -> ok! <<if 42 % 2>>\n'
              '>              ^\n'),
        );
      });

      test('option with multiple conditions', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n'
            '-> ok! <<if true>> <<if false>>\n'
            '===\n',
          ),
          hasSyntaxError(
              'SyntaxError: multiple commands are not allowed on an option '
              'line\n'
              '>  at line 3 column 20:\n'
              '>  -> ok! <<if true>> <<if false>>\n'
              '>                     ^\n'),
        );
      });
    });

    group('parseExpression', () {
      List<String> linesToText(Iterable<DialogueEntry> lines) {
        return lines
            .whereType<DialogueLine>()
            .map((line) => (line..evaluate()).text)
            .toList();
      }

      test('unary minus', () {
        final yarn = YarnProject()
          ..setVariable(r'$x', 42)
          ..parse('title: test\n---\n'
              '{ -7 + 1 }\n'
              '{ 2 * -7 }\n'
              '{ -\$x }\n'
              '{ -(3 + 111) }\n'
              '===\n');
        final texts = linesToText(yarn.nodes['test']!.lines);
        expect(
          texts.map(num.parse).toList(),
          [-6, -14, -42, -114],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ -"banana" }\n===\n'),
          hasTypeError(
            'TypeError: unary minus can only be applied to numbers\n'
            '>  at line 3 column 4:\n'
            '>  { -"banana" }\n'
            '>     ^\n',
          ),
        );
      });

      test('add', () {
        final yarn = YarnProject()
          ..setVariable(r'$world', 'world')
          ..parse('title: test\n---\n'
              '{ 2.16 + 4.6 + 9 }\n'
              '{ "hello," + " " + \$world }\n'
              '===\n');
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['15.76', 'hello, world'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 + " swords" }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of + must be numeric or strings\n'
            '>  at line 3 column 5:\n'
            '>  { 3 + " swords" }\n'
            '>      ^\n',
          ),
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 + true }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of + must be numeric or strings\n'
            '>  at line 3 column 5:\n'
            '>  { 3 + true }\n'
            '>      ^\n',
          ),
        );
      });

      test('subtract', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 22 - 7 - 1 }\n'
              '{ "hello," - "hell" - "paradise" }\n'
              '===\n');
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['14', 'o,'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 - "zero" }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of - must be numeric or strings\n'
            '>  at line 3 column 5:\n'
            '>  { 3 - "zero" }\n'
            '>      ^\n',
          ),
        );
      });

      test('multiply', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 11 * 8 * 0.5 }\n'
              '{ 2 * -3 }\n'
              '===\n');
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['44.0', '-6'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ "x" * "zero" }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of * must be numeric\n'
            '>  at line 3 column 7:\n'
            '>  { "x" * "zero" }\n'
            '>        ^\n',
          ),
        );
      });

      test('divide', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 48 / 2 / 3 }\n'
              '===\n');
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['8.0'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ "x" / "y" }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of / must be numeric\n'
            '>  at line 3 column 7:\n'
            '>  { "x" / "y" }\n'
            '>        ^\n',
          ),
        );
      });

      test('modulo', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '{ 48 % 5 }\n'
              '{ 4 % 1.2 }\n'
              '===\n');
        final texts = linesToText(yarn.nodes['A']!.lines);
        expect(texts[0], '3');
        expect(num.parse(texts[1]), closeTo(4 % 1.2, 1e-10));
        expect(
          () => yarn.parse('title:E\n---\n{ 17 % true }\n===\n'),
          hasTypeError(
            'TypeError: both lhs and rhs of % must be numeric\n'
            '>  at line 3 column 6:\n'
            '>  { 17 % true }\n'
            '>       ^\n',
          ),
        );
      });

      test('equals', () {
        final yarn = YarnProject()
          ..setVariable(r'$famous', true)
          ..setVariable(r'$name', 'Mr.Bronze')
          ..parse('title: test\n---\n'
              '{ \$famous == true }\n'
              '{ 8 % 3 == 2 }\n'
              '{ \$name == "monkey" }\n'
              '===\n');
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['true', 'true', 'false'],
        );
        expect(
          () => yarn.parse('title:Error\n---\n'
              '{ \$name == 9.99 }\n'
              '===\n'),
          hasTypeError(
            'TypeError: equality operator between operands of unrelated '
            'types string and numeric\n'
            '>  at line 3 column 9:\n'
            '>  { \$name == 9.99 }\n'
            '>          ^\n',
          ),
        );
      });

      test('complicated expressions', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{(4 - 5)}\n'
              '{ 2 + 7 * 3 - 1 }\n'
              '{ 44 / (3 - 1) % 15 }\n'
              '===\n');
        final node = yarn.nodes['test']!;
        expect(node.lines.length, 3);
        expect(
          linesToText(yarn.nodes['test']!.lines),
          ['-1', '22', '7.0'],
        );
      });

      test('unknown variable', () {
        expect(
          () => YarnProject().parse('title:A\n---\n{ \$x + 1 }\n===\n'),
          hasNameError(
            'NameError: variable \$x is not defined\n'
            '>  at line 3 column 3:\n'
            '>  { \$x + 1 }\n'
            '>    ^\n',
          ),
        );
      });

      test('invalid expression', () {
        expect(
          () => YarnProject().parse('title:A\n---\n'
              '{ 1 + * 5 }\n'
              '===\n'),
          hasSyntaxError('SyntaxError: unexpected expression\n'
              '>  at line 3 column 7:\n'
              '>  { 1 + * 5 }\n'
              '>        ^\n'),
        );
      });

      test('mismatched parentheses', () {
        expect(
          () => YarnProject().parse('title:A\n---\n'
              '{ (12 }\n'
              '===\n'),
          hasSyntaxError('SyntaxError: missing closing ")"\n'
              '>  at line 3 column 7:\n'
              '>  { (12 }\n'
              '>        ^\n'),
        );
      });
    });

    group('parseCommand', () {
      test('<<if>>', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '<<if 2 > 0>>\n'
              '  First!\n'
              '<<else>>\n'
              '  Second\n'
              '<<endif>>\n'
              '===\n');
        final node = yarn.nodes['A']!;
        expect(node.lines.length, 1);
        expect(node.lines[0], isA<IfCommand>());
        final command = node.lines[0] as IfCommand;
        expect(command.ifs.length, 2);
        expect(command.ifs[0].condition.value, true);
        expect(command.ifs[0].block.lines[0], isA<DialogueLine>());
        expect(
          (command.ifs[0].block.lines[0] as DialogueLine).text,
          'First!',
        );
        expect(command.ifs[1].condition.value, true);
        expect(
          (command.ifs[1].block.lines[0] as DialogueLine).text,
          'Second',
        );
      });

      test('<<elseif>>s', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n'
              '<<if true>>\n'
              '  First!\n'
              '<<elseif false>>\n'
              '  Second\n'
              '<<elseif true>>\n'
              '  Third\n'
              '<<endif>>\n'
              '===\n');
        final node = yarn.nodes['A']!;
        final command = node.lines[0] as IfCommand;
        expect(command.ifs.length, 3);
        expect(command.ifs[0].condition.value, true);
        expect(command.ifs[1].condition.value, false);
        expect(command.ifs[2].condition.value, true);
      });

      test('no <<endif>> 1', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if true>>\n'
                '  ha\n'
                '===\n'),
          hasSyntaxError('SyntaxError: <<endif>> expected\n'
              '>  at line 5 column 1:\n'
              '>  ===\n'
              '>  ^\n'),
        );
      });

      test('no <<endif>> 2', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if true>>\n'
                '<<stop>>\n'
                '===\n'),
          hasSyntaxError('SyntaxError: <<endif>> expected\n'
              '>  at line 4 column 1:\n'
              '>  <<stop>>\n'
              '>  ^\n'),
        );
      });

      test('double <<else>>', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if true>>\n'
                '<<else>>\n'
                '<<else>>\n'
                '<<endif>>\n'
                '===\n'),
          hasSyntaxError('SyntaxError: only one <<else>> is allowed\n'
              '>  at line 5 column 1:\n'
              '>  <<else>>\n'
              '>  ^\n'),
        );
      });

      test('no indentation in <<if>>', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if true>>\n'
                'text\n'
                '<<endif>>\n'
                '===\n'),
          hasSyntaxError(
              'SyntaxError: the body of the <<if>> command must be indented\n'
              '>  at line 4 column 1:\n'
              '>  text\n'
              '>  ^\n'),
        );
      });

      test('no indentation in <<else>>', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if true>>\n'
                '<<else>>\n'
                'text\n'
                '<<endif>>\n'
                '===\n'),
          hasSyntaxError(
              'SyntaxError: the body of the <<else>> command must be indented\n'
              '>  at line 5 column 1:\n'
              '>  text\n'
              '>  ^\n'),
        );
      });

      test('non-boolean condition in <<if>>', () {
        expect(
          () => YarnProject()
            ..parse('title:A\n---\n'
                '<<if "true">>\n'
                '    text\n'
                '<<endif>>\n'
                '===\n'),
          hasTypeError(
              'TypeError: expression in an <<if>> command must be boolean\n'
              '>  at line 3 column 6:\n'
              '>  <<if "true">>\n'
              '>       ^\n'),
        );
      });

      test(
        '<<jump>>',
        () {
          final yarn = YarnProject()
            ..setVariable(r'$target', 'DOWN')
            ..parse('title:A\n---\n'
                '<<jump UP>>\n'
                '<<jump {\$target}>>\n'
                '===\n');
          final node = yarn.nodes['A']!;
          expect(node.lines.length, 2);
          expect(node.lines[0], isA<JumpCommand>());
          expect(node.lines[1], isA<JumpCommand>());
          expect((node.lines[0] as JumpCommand).target.value, 'UP');
          expect((node.lines[1] as JumpCommand).target.value, 'DOWN');
        },
      );
    });
  });
}
