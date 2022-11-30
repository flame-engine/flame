import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/parse.dart';
import 'package:jenny/src/structure/commands/if_command.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:test/test.dart';

import '../test_scenario.dart';
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

      test('Headers.yarn', () {
        final yarn = YarnProject();
        yarn.parse(
          dedent('''
            title: EmptyTags
            tags:
            ---
            In this test, the 'tags' header is provided, but has no value.
            ===
            title: Tags
            tags: one two three
            ---
            In this test, the 'tags' header is provided, and has three values.
            ===
            title: ArbitraryHeaderWithValue
            // test
            arbitraryHeader: some-arbitrary-text
            ---
            In this test, an arbitrary header is defined with some text.
            ===
            title: Comments
            tags: one two three
            metadata:
            ---
            This node demonstrates the use of comments in node headers.
            ===
          '''),
        );
        final node1 = yarn.nodes['EmptyTags']!;
        expect(node1.tags, isNotNull);
        expect(node1.tags!['tags'], '');

        final node2 = yarn.nodes['Tags']!;
        expect(node2.tags!['tags'], 'one two three');

        final node3 = yarn.nodes['ArbitraryHeaderWithValue']!;
        expect(node3.tags!['arbitraryHeader'], 'some-arbitrary-text');

        final node4 = yarn.nodes['Comments']!;
        expect(node4.tags!['tags'], 'one two three');
        expect(node4.tags!['metadata'], '');
      });

      test(
        'InvalidNodeTitle.yarn',
        () {
          expect(
            () => YarnProject().parse('title: \$InvalidTitle\n---\n===\n'),
            hasNameError(r'NameError: invalid title name "$InvalidTitle"'),
          );
        },
        skip: true,
      );
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
          expect(line.tags, isEmpty);
          expect(line.condition, isNull);
          expect(line.block, isEmpty);
          expect(line.text, ['Alpha', 'Beta', 'Gamma'][i]);
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
        expect(option0.text, 'Hello!');
        expect(option1.text, 'Hi: there!');
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
        expect(choice1.text, 'choice one');
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
        expect(choice2.text, 'choice two');
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

      test('unknown function', () {
        expect(
          () => YarnProject().parse('title:A\n---\n{ foo() }\n===\n'),
          hasNameError(
            'NameError: unknown function name foo\n'
            '>  at line 3 column 3:\n'
            '>  { foo() }\n'
            '>    ^\n',
          ),
        );
      });

      test('invalid expression', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n'
            '{ 1 + * 5 }\n'
            '===\n',
          ),
          hasSyntaxError('SyntaxError: unexpected expression\n'
              '>  at line 3 column 7:\n'
              '>  { 1 + * 5 }\n'
              '>        ^\n'),
        );
      });

      test('mismatched parentheses', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n'
            '{ (12 }\n'
            '===\n',
          ),
          hasSyntaxError('SyntaxError: missing closing ")"\n'
              '>  at line 3 column 7:\n'
              '>  { (12 }\n'
              '>        ^\n'),
        );
      });

      test('invalid function expression', () {
        expect(
          () => YarnProject().parse(
            'title:A\n---\n'
            '{ random_range(1, 3 ()) }\n'
            '===\n',
          ),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 3 column 21:\n'
              '>  { random_range(1, 3 ()) }\n'
              '>                      ^\n'),
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

      test('double command on a line', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n'
              '<<wait 1>> <<wait 2>>\n'
              '===\n',
            ),
          hasSyntaxError('SyntaxError: expected end of line\n'
              '>  at line 3 column 12:\n'
              '>  <<wait 1>> <<wait 2>>\n'
              '>             ^\n'),
        );
      });
    });

    group('parseMarkupTag', () {
      test('parse simple markup tag', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              'Hello, [big]world[/big]!\n'
              '===\n');
        expect(yarn.nodes['A']!.lines.length, 1);
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        expect(line.text, 'Hello, world!');
        expect(line.tags, isEmpty);
        expect(line.attributes.length, 1);
        final attribute = line.attributes[0];
        expect(attribute.name, 'big');
        expect(attribute.start, 7);
        expect(attribute.end, 12);
        expect(attribute.parameters, isEmpty);
        expect(line.text.substring(attribute.start, attribute.end), 'world');
      });

      test('parse self-closing tag', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              'Hello, [wave /] world!\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        final attribute = line.attributes[0];
        // Note that the space after the tag was removed
        expect(line.text, 'Hello, world!');
        expect(attribute.name, 'wave');
        expect(attribute.start, 7);
        expect(attribute.end, 7);
        expect(attribute.parameters, isEmpty);
      });

      test('parse nested tags', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              'Warning: [a]Spinning [b][c]Je[/c]nny[/b][/a]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        expect(line.character, 'Warning');
        expect(line.text, 'Spinning Jenny');

        expect(line.attributes.length, 3);
        final attrA = line.attributes[2];
        final attrB = line.attributes[1];
        final attrC = line.attributes[0];
        expect(attrA.name, 'a');
        expect(attrB.name, 'b');
        expect(attrC.name, 'c');
        expect(line.text.substring(attrA.start, attrA.end), 'Spinning Jenny');
        expect(line.text.substring(attrB.start, attrB.end), 'Jenny');
        expect(line.text.substring(attrC.start, attrC.end), 'Je');
      });

      test('markup tags at start of line', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              '[blue]wave[/blue]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        final attribute = line.attributes[0];
        expect(line.text, 'wave');
        expect(attribute.name, 'blue');
        expect(attribute.start, 0);
        expect(attribute.end, 4);
      });

      test('close-all tag [/]', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              '[a][b][c] hello [/]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        expect(line.text, ' hello ');
        for (final attribute in line.attributes) {
          expect(attribute.name, isIn(['a', 'b', 'c']));
          expect(attribute.start, 0);
          expect(attribute.end, 7);
        }
      });

      test('markup tag with parameters', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              '[color r=0 g=false b=100 name="BLUE"]wave[/color]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        final attr = line.attributes[0];
        expect(line.text, 'wave');
        expect(attr.name, 'color');
        expect(attr.start, 0);
        expect(attr.end, 4);
        expect(attr.parameters, isNotNull);
        final parameters = attr.parameters;
        expect(parameters.length, 4);
        expect(parameters.keys.toSet(), {'r', 'g', 'b', 'name'});
        expect(parameters['r'], 0);
        expect(parameters['g'], false);
        expect(parameters['b'], 100);
        expect(parameters['name'], 'BLUE');
      });

      test('markup tag with bare parameters', () {
        final yarn = YarnProject()
          ..parse('title: A\n---\n'
              '[color blue]wave[/color]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        final attr = line.attributes[0];
        expect(attr.parameters, isNotNull);
        final parameters = attr.parameters;
        expect(parameters.length, 1);
        expect(parameters['blue'], true);
      });

      test('markup tags with inline expressions', () {
        final yarn = YarnProject()
          ..variables.setVariable(r'$x', 'world')
          ..parse('title: A\n---\n'
              'Hello [color]{\$x}[/color]\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        line.evaluate();
        expect(line.text, 'Hello world');
        final attr = line.attributes[0];
        expect(attr.name, 'color');
        expect(attr.start, 6);
        expect(attr.end, 11);
        expect(line.text.substring(attr.start, attr.end), 'world');

        for (final x in ['YarnSpinner', 'Blue Fire', 'me']) {
          yarn.variables.setVariable(r'$x', x);
          line.evaluate();
          expect(line.text, 'Hello $x');
          expect(line.text.substring(attr.start, attr.end), x);
        }
      });

      test('more inline expressions', () {
        final yarn = YarnProject()
          ..variables.setVariable(r'$w', 'welcome')
          ..variables.setVariable(r'$x', 'citizen')
          ..variables.setVariable(r'$y', 'Paradise City')
          ..variables.setVariable(r'$z', '...')
          ..parse('title: A\n---\n'
              'Hello {\$x}, and [color]{\$w} to {\$y}[/color] {\$z}\n'
              '===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        line.evaluate();
        expect(line.text, 'Hello citizen, and welcome to Paradise City ...');
        final attr = line.attributes[0];
        expect(attr.name, 'color');
        expect(
          line.text.substring(attr.start, attr.end),
          'welcome to Paradise City',
        );

        yarn.variables
          ..setVariable(r'$x', 'unidentified')
          ..setVariable(r'$y', '[INVALID]')
          ..setVariable(r'$z', '😠');
        line.evaluate();
        expect(line.text, 'Hello unidentified, and welcome to [INVALID] 😠');
        expect(
          line.text.substring(attr.start, attr.end),
          'welcome to [INVALID]',
        );
      });

      test('adjacent inline expressions 1', () {
        final yarn = YarnProject()
          ..variables.setVariable(r'$w', 'some ')
          ..variables.setVariable(r'$x', 'arbitrary ')
          ..variables.setVariable(r'$y', 'text')
          ..variables.setVariable(r'$z', '?')
          ..parse('title: A\n---\n'
              r'{$w}[wavy]{$x}{$y}[/]{$z}'
              '\n===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        line.evaluate();
        expect(line.text, 'some arbitrary text?');
        expect(line.attributes.length, 1);

        final attr = line.attributes[0];
        expect(line.text.substring(attr.start, attr.end), 'arbitrary text');
      });

      test('adjacent inline expressions 2', () {
        final yarn = YarnProject()
          ..variables.setVariable(r'$x1', 'One')
          ..variables.setVariable(r'$x2', 'Double')
          ..variables.setVariable(r'$x3', 'Three')
          ..parse('title: A\n---\n'
              r'{$x1}[a/]{$x2}[b/]{$x3}'
              '\n===\n');
        final line = yarn.nodes['A']!.lines[0] as DialogueLine;
        line.evaluate();
        expect(line.text, 'OneDoubleThree');
        expect(line.attributes.length, 2);

        final attrA = line.attributes[0];
        expect(attrA.name, 'a');
        expect(attrA.length, 0);
        expect(attrA.start, 'One'.length);

        final attrB = line.attributes[1];
        expect(attrB.name, 'b');
        expect(attrB.length, 0);
        expect(attrB.start, 'OneDouble'.length);
      });

      group('errors', () {
        test('invalid opening markup tag', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                '[+1]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: a markup tag name is expected\n'
              '>  at line 3 column 2:\n'
              '>  [+1]\n'
              '>   ^\n',
            ),
          );
        });

        test('invalid closing markup tag', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                '[/1]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: a markup tag name is expected\n'
              '>  at line 3 column 3:\n'
              '>  [/1]\n'
              '>    ^\n',
            ),
          );
        });

        test('closing tag without opening', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                'text [/rgb]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: unexpected closing markup tag\n'
              '>  at line 3 column 7:\n'
              '>  text [/rgb]\n'
              '>        ^\n',
            ),
          );
        });

        test('close-all tag without opening', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                'text [/]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: unexpected closing markup tag\n'
              '>  at line 3 column 7:\n'
              '>  text [/]\n'
              '>        ^\n',
            ),
          );
        });

        test('incorrectly nested markup tags', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                '[r][g][b] text [/g][/r][/b]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: Expected closing tag for [b]\n'
              '>  at line 3 column 18:\n'
              '>  [r][g][b] text [/g][/r][/b]\n'
              '>                   ^\n',
            ),
          );
        });

        test('unclosed markup tag', () {
          expect(
            () => YarnProject()
              ..parse(
                'title:X\n---\n'
                '[hi] text\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: markup tag [hi] was not closed\n'
              '>  at line 3 column 10:\n'
              '>  [hi] text\n'
              '>           ^\n',
            ),
          );
        });

        test('unfinished markup tag', () {
          expect(
            () => YarnProject()
              ..parse(
                'title: X\n---\n'
                '[hi text\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: missing markup tag close token "]"\n'
              '>  at line 3 column 9:\n'
              '>  [hi text\n'
              '>          ^\n',
            ),
          );
        });

        test('repeated attribute name', () {
          expect(
            () => YarnProject()
              ..parse(
                'title: X\n---\n'
                '[color r=1 r=2]text[/color]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: duplicate parameter r in a markup attribute\n'
              '>  at line 3 column 12:\n'
              '>  [color r=1 r=2]text[/color]\n'
              '>             ^\n',
            ),
          );
        });

        test('invalid attribute content', () {
          expect(
            () => YarnProject()
              ..parse(
                'title: X\n---\n'
                '[color r += 1]text[/color]\n'
                '===\n',
              ),
            hasSyntaxError(
              'SyntaxError: unexpected token\n'
              '>  at line 3 column 10:\n'
              '>  [color r += 1]text[/color]\n'
              '>           ^\n',
            ),
          );
        });
      });
    });

    testScenario(
      testName: 'Escaping.yarn',
      input: r'''
        title: Start
        ---
        Here's a line with a hashtag #hashtag
        Here's a line with an escaped hashtag \#hashtag
        Here's a line with an expression {0}
        Here's a line with an escaped expression \{0\}

        // Commented out because this isn't actually allowed, but we're just
        // maintaining the pattern here:
        // Here's a line with a command <<foo>
        Here's a line with an escaped command \<\<foo\>\>
        Here's a line with a comment // wow
        Here's a line with an escaped comment \/\/ wow
        Here's a line with an escaped backslash \\
        Here's some styling with a color code: <color=\#fff>wow</color>
        Here's a url: http:\/\/github.com\/YarnSpinnerTool

        // Escaped markup is handled by the LineParser class, not the main
        // grammar itself
        Here's some markup: [a]hello[/a]
        Here's some escaped markup: \[a\]hello\[/a\]

        -> Here's an option with a hashtag #hashtag
        -> Here's an option with an escaped hashtag \#hashtag

        -> Here's an option with an expression {0}
        -> Here's an option with an escaped expression \{0\}

        // Commented out because this isn't actually allowed, but we're just
        // maintaining the pattern here:
        -> Here's an option with a condition <<if true>>
        -> Here's an option with an escaped condition \<\<if true\>\>
        -> Here's an option with a comment // wow
        -> Here's an option with an escaped comment \/\/ wow
        -> Here's an option with an escaped backslash \\
        -> Here's some styling with a color code: <color=\#fff>wow</color>
        -> Here's a url: http:\/\/github.com\/YarnSpinnerTool

        // Escaped markup is handled by the LineParser class, not the main
        // grammar itself
        -> Here's some markup: [a]hello[/a]
        -> Here's some escaped markup: \[a\]hello\[/a\]
        ===
      ''',
      testPlan: r'''
        line: Here's a line with a hashtag
        line: Here's a line with an escaped hashtag #hashtag
        line: Here's a line with an expression 0
        line: Here's a line with an escaped expression {0}
        line: Here's a line with an escaped command <<foo>>
        line: Here's a line with a comment
        line: Here's a line with an escaped comment // wow
        line: Here's a line with an escaped backslash \
        line: Here's some styling with a color code: <color=#fff>wow</color>
        line: Here's a url: http://github.com/YarnSpinnerTool
        line: Here's some markup: hello
        line: Here's some escaped markup: [a]hello[/a]

        option: Here's an option with a hashtag
        option: Here's an option with an escaped hashtag #hashtag
        option: Here's an option with an expression 0
        option: Here's an option with an escaped expression {0}
        option: Here's an option with a condition
        option: Here's an option with an escaped condition <<if true>>
        option: Here's an option with a comment
        option: Here's an option with an escaped comment // wow
        option: Here's an option with an escaped backslash \
        option: Here's some styling with a color code: <color=#fff>wow</color>
        option: Here's a url: http://github.com/YarnSpinnerTool
        option: Here's some markup: hello
        option: Here's some escaped markup: [a]hello[/a]
        select: 1
      ''',
    );
  });
}
