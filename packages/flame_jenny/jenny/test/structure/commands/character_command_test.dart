import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('CharacterCommand', () {
    test('tokenize <<character>> command', () {
      expect(
        tokenize('<<character "Agent Smith" Smith AgSmith>>'),
        const [
          Token.startCommand,
          Token.commandCharacter,
          Token.startExpression,
          Token.string('Agent Smith'),
          Token.id('Smith'),
          Token.id('AgSmith'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('<<character>> command declares new characters', () {
      final yarn = YarnProject();
      yarn.parse(
        '<<character "Harry Potter" Harry HP>>\n'
        '<<character "Hermione Granger" Hermione HG>>\n'
        '<<character "Ron Weasley" Ron RW>>\n'
        '<<character Peeves>>\n',
      );
      expect(yarn.characters.isEmpty, false);
      expect(yarn.characters.isNotEmpty, true);

      expect(yarn.characters.contains('HP'), true);
      expect(yarn.characters.contains('HG'), true);
      expect(yarn.characters.contains('RW'), true);
      expect(yarn.characters.contains('HW'), false);
      expect(yarn.characters.contains('Hermione'), true);
      expect(yarn.characters.contains('Peeves'), true);
      expect(yarn.characters.contains('Harry'), true);
      expect(yarn.characters.contains('Ron'), true);
      expect(yarn.characters.contains('harry'), false);

      final harry = yarn.characters['Harry']!;
      expect(harry.name, 'Harry Potter');
      expect(harry.aliases, ['Harry', 'HP']);
      expect(harry.data, isEmpty);
      harry.data['age'] = 11;
      harry.data['affiliation'] = 'Dumbledore';
      expect(harry.data['age'], 11);
      expect(harry.data['affiliation'], 'Dumbledore');

      final peeves = yarn.characters['Peeves']!;
      expect(peeves.name, 'Peeves');
      expect(peeves.aliases, isEmpty);

      expect(yarn.characters['Hermione'], isNotNull);
      expect(yarn.characters['Voldemort'], isNull);
    });

    test('script with strict characters', () async {
      await testScenario(
        input: '''
          <<character Alice>>
          <<character Cat>>
          ---
          title: Start
          ---
          Alice: Cheshire Puss, would you tell me which way to go from here?
          Cat:   That depends a great deal on where you want to get to
          Alice: I don't much care where --
          Cat:   Then it doesn't matter which way you go
          Alice: so long as I get [i]somewhere[/i]
          Cat:   Oh, you're sure to do that, if you only walk long enough
          ===
        ''',
        testPlan: '''
          line: Alice: Cheshire Puss, would you tell me which way to go from here?
          line: Cat: That depends a great deal on where you want to get to
          line: Alice: I don't much care where --
          line: Cat: Then it doesn't matter which way you go
          line: Alice: so long as I get somewhere
          line: Cat: Oh, you're sure to do that, if you only walk long enough
        ''',
      );
    });

    test('script without character declared', () {
      expect(
        () => YarnProject()
          ..parse(
            'title: Start\n'
            '---\n'
            'Alice: Do cats eat bats?\n'
            '===\n',
          ),
        hasNameError(
          'NameError: unknown character "Alice"\n'
          '>  at line 3 column 1:\n'
          '>  Alice: Do cats eat bats?\n'
          '>  ^\n',
        ),
      );
    });

    group('errors', () {
      test('invalid syntax', () {
        expect(
          () => YarnProject()..parse(r'<<character "Me" = $foo>>'),
          hasSyntaxError(
            'SyntaxError: unexpected token\n'
            '>  at line 1 column 18:\n'
            '>  <<character "Me" = \$foo>>\n'
            '>                   ^\n',
          ),
        );
      });

      test('no character name or ids', () {
        expect(
          () => YarnProject()..parse('<<character>>'),
          hasSyntaxError(
            'SyntaxError: at least one character id is required\n'
            '>  at line 1 column 12:\n'
            '>  <<character>>\n'
            '>             ^\n',
          ),
        );
      });

      test('only character name', () {
        expect(
          () => YarnProject()..parse('<<character "Bozo">>'),
          hasSyntaxError(
            'SyntaxError: at least one character id is required\n'
            '>  at line 1 column 19:\n'
            '>  <<character "Bozo">>\n'
            '>                    ^\n',
          ),
        );
      });

      test('duplicate character id', () {
        expect(
          () => YarnProject()
            ..parse(
              '<<character "Fancy Bob" FancyBob bob>>\n'
              '<<character "Lame Bob" LameBob bob>>\n',
            ),
          hasNameError(
            'NameError: character "bob" was already defined: Character(Fancy '
            'Bob)\n'
            '>  at line 2 column 32:\n'
            '>  <<character "Lame Bob" LameBob bob>>\n'
            '>                                 ^\n',
          ),
        );
      });

      test('character command inside a node', () {
        expect(
          () => YarnProject()
            ..parse(
              'title: X\n'
              '---\n'
              '<<character Charlie>>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: <<character>> command cannot be used inside a node\n'
            '>  at line 3 column 1:\n'
            '>  <<character Charlie>>\n'
            '>  ^\n',
          ),
        );
      });
    });
  });
}
