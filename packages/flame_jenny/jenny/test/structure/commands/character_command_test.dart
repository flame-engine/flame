import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

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

      expect(yarn.characters['Hermione'], isNotNull);
      expect(yarn.characters['Voldemort'], isNull);
    });

    group('errors', () {
      test('invalid syntax', () {
        expect(
          () => YarnProject()..parse(r'<<character "Me" = $foo>>'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 1 column 18:\n'
              '>  <<character "Me" = \$foo>>\n'
              '>                   ^\n'),
        );
      });

      test('no character name or ids', () {
        expect(
          () => YarnProject()..parse('<<character>>'),
          hasSyntaxError('SyntaxError: at least one character id is required\n'
              '>  at line 1 column 12:\n'
              '>  <<character>>\n'
              '>             ^\n'),
        );
      });

      test('only character name', () {
        expect(
          () => YarnProject()..parse('<<character "Bozo">>'),
          hasSyntaxError('SyntaxError: at least one character id is required\n'
              '>  at line 1 column 19:\n'
              '>  <<character "Bozo">>\n'
              '>                    ^\n'),
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
    });
  });
}
