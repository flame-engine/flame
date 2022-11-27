import 'package:jenny/src/command_storage.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('CommandStorage', () {
    test('A dialogue command', () {
      final storage = CommandStorage();
      storage.addDialogueCommand('simple');
      expect(storage.hasCommand('simple'), true);
      storage.runCommand('simple', '');
      storage.runCommand('simple', '1 2 3');
      expect(
        () => storage.addCommand0('simple', () => null),
        throwsAssertionError('Command <<simple>> has already been defined'),
      );
    });

    test('A no-argument command', () {
      final storage = CommandStorage();
      storage.addCommand0('foo', () => null);

      expect(storage.hasCommand('foo'), true);
      expect(storage.hasCommand('bar'), false);
    });

    test('An integer-argument command', () {
      var value = -1;
      final storage = CommandStorage();
      storage.addCommand1('one', (int x) => value = x);
      expect(storage.hasCommand('one'), true);

      void check(String arg, int expectedValue) {
        storage.runCommand('one', arg);
        expect(value, expectedValue);
      }

      check('23', 23);
      check('  117 ', 117);
      check('-3', -3);
      check('+666', 666);
      check(' "42" ', 42);
      expect(
        () => storage.runCommand('one', '2.0'),
        hasTypeError(
          'TypeError: Argument 1 for command <<one>> has value "2.0", which '
          'is not integer',
        ),
      );
    });

    test('A boolean-argument command', () {
      var value = false;
      final storage = CommandStorage();
      storage.addCommand1('check', (bool x) => value = x);
      expect(storage.hasCommand('check'), true);

      void check(String arg, bool expectedValue) {
        storage.runCommand('check', arg);
        expect(value, expectedValue);
      }

      check('true', true);
      check('  false ', false);
      check('+', true);
      check('-', false);
      check(' "on"', true);
      check('off ', false);
      check('yes', true);
      check('no', false);
      check('T', true);
      check('F', false);
      check('1', true);
      check('0', false);
      expect(
        () => storage.runCommand('check', '12'),
        hasTypeError(
          'TypeError: Argument 1 for command <<check>> has value "12", which '
          'is not a boolean',
        ),
      );
    });

    test('A two-argument command', () {
      var value1 = double.nan;
      var value2 = '';
      final storage = CommandStorage();
      storage.addCommand2('two', (double x, String y) {
        value1 = x;
        value2 = y;
      });
      expect(storage.hasCommand('two'), true);

      void check(String args, double expectedValue1, String expectedValue2) {
        storage.runCommand('two', args);
        expect(value1, expectedValue1);
        expect(value2, expectedValue2);
      }

      check('1 2', 1.0, '2');
      check('2.12 Jenny', 2.12, 'Jenny');
      check('-0.001 "Yarn Spinner"', -0.001, 'Yarn Spinner');
      check(r'+3e+100 "\""', 3e100, '"');
      expect(
        () => storage.runCommand('two', '2.0.3 error'),
        hasTypeError(
          'TypeError: Argument 1 for command <<two>> has value "2.0.3", which '
          'is not a floating-point value',
        ),
      );
    });

    test('A three-argument command', () {
      num value1 = 0;
      num value2 = 0;
      num value3 = 0;
      final storage = CommandStorage();
      storage.addCommand3('three', (num x, num y, num z) {
        value1 = x;
        value2 = y;
        value3 = z;
      });
      expect(storage.hasCommand('three'), true);

      void check(String args, num v1, num v2, num v3) {
        storage.runCommand('three', args);
        expect(value1, v1);
        expect(value2, v2);
        expect(value3, v3);
      }

      check('1 2 3', 1, 2, 3);
      check('1.1 2.2 3.3', 1.1, 2.2, 3.3);
      check('Infinity -0.0 333', double.infinity, 0, 333);
      expect(
        () => storage.runCommand('three', '0 0 error'),
        hasTypeError(
          'TypeError: Argument 3 for command <<three>> has value "error", '
          'which is not numeric',
        ),
      );
    });

    test('Command with trailing booleans', () {
      var value1 = false;
      var value2 = false;
      var value3 = false;
      final storage = CommandStorage();
      storage.addCommand3('three', (bool x, bool y, bool z) {
        value1 = x;
        value2 = y;
        value3 = z;
      });
      expect(storage.hasCommand('three'), true);

      void check(String args, bool v1, bool v2, bool v3) {
        storage.runCommand('three', args);
        expect(value1, v1);
        expect(value2, v2);
        expect(value3, v3);
      }

      check('true true true', true, true, true);
      check('true true', true, true, false);
      check('true', true, false, false);
      check('', false, false, false);
    });

    group('errors', () {
      test('Add a duplicate command', () {
        final storage = CommandStorage();
        storage.addCommand0('foo', () => null);
        expect(
          () => storage.addCommand0('foo', () => null),
          throwsAssertionError('Command <<foo>> has already been defined'),
        );
      });

      test('Add a built-in command', () {
        for (final cmd in ['if', 'set', 'for', 'while', 'local']) {
          expect(
            () => CommandStorage().addCommand0(cmd, () => null),
            throwsAssertionError('Command <<$cmd>> is built-in'),
          );
        }
      });

      test('Bad command name', () {
        for (final cmd in ['', '---', 'hello world', r'$fun']) {
          expect(
            () => CommandStorage().addCommand0(cmd, () => null),
            throwsAssertionError('Command name "$cmd" is not an identifier'),
          );
        }
      });

      test('Command with unsupported type', () {
        expect(
          () => CommandStorage().addCommand1('abc', (List x) => null),
          throwsAssertionError('Unsupported type List<dynamic> of argument 1'),
        );
      });

      test('Wrong number of arguments', () {
        final storage = CommandStorage()
          ..addCommand2('xyz', (int z, bool f) => null);
        expect(
          () => storage.runCommand('xyz', '1 true 3'),
          hasTypeError(
            'TypeError: Command <<xyz>> expects 2 arguments but received 3 '
            'arguments',
          ),
        );
        expect(
          () => storage.runCommand('xyz', ''),
          hasTypeError(
            'TypeError: Command <<xyz>> expects 2 arguments but received 0 '
            'arguments',
          ),
        );
      });
    });
  });

  group('ArgumentsLexer', () {
    List<String> tokenize(String text) => ArgumentsLexer(text).tokenize();

    test('empty string', () {
      expect(tokenize(''), <String>[]);
      expect(tokenize(' '), <String>[]);
      expect(tokenize(' \t  '), <String>[]);
    });

    test('single argument', () {
      expect(tokenize('bob'), ['bob']);
      expect(tokenize('   mary '), ['mary']);
      expect(tokenize(' 1234.5'), ['1234.5']);
      expect(tokenize('["Flame"]'), ['["Flame"]']);
    });

    test('quoted argument', () {
      expect(tokenize('"Hello"'), ['Hello']);
      expect(tokenize('"Hello World"'), ['Hello World']);
      expect(tokenize(r' "Hel\"lo\" World\\"'), [r'Hel"lo" World\']);
      expect(tokenize(r'"\n"'), ['\n']);
    });

    test('multiple arguments', () {
      expect(tokenize('1 2 3 4 53'), ['1', '2', '3', '4', '53']);
      expect(tokenize('Hello World'), ['Hello', 'World']);
      expect(tokenize('flame   \t awesome'), ['flame', 'awesome']);
      expect(tokenize(' "one"  "two" "three"'), ['one', 'two', 'three']);
    });

    group('errors', () {
      test('unterminated quoted string', () {
        expect(
          () => tokenize('"hello'),
          hasDialogueError('Unterminated quoted string'),
        );
      });

      test('unrecognized escape sequence', () {
        expect(
          () => tokenize(r'"hello \u1234 world"'),
          hasDialogueError(r'Unrecognized escape sequence \u'),
        );
      });

      test('no space after a quoted string', () {
        expect(
          () => tokenize('"hello"next'),
          hasDialogueError('Whitespace is required after a quoted argument'),
        );
      });
    });
  });
}
