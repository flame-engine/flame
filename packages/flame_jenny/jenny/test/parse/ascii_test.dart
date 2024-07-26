import 'package:jenny/src/parse/ascii.dart';
import 'package:test/test.dart';

void main() {
  test('ASCII', () {
    _check($tab, '\t');
    _check($lineFeed, '\n');
    _check($carriageReturn, '\r');
    _check($space, ' ');
    _check($exclamation, '!');
    _check($doubleQuote, '"');
    _check($hash, '#');
    _check($dollar, r'$');
    _check($percent, '%');
    _check($ampersand, '&');
    _check($singleQuote, "'");
    _check($leftParenthesis, '(');
    _check($rightParenthesis, ')');
    _check($asterisk, '*');
    _check($plus, '+');
    _check($comma, ',');
    _check($minus, '-');
    _check($dot, '.');
    _check($slash, '/');
    _check($digit0, '0');
    _check($digit9, '9');
    _check($colon, ':');
    _check($lessThan, '<');
    _check($equals, '=');
    _check($greaterThan, '>');
    _check($uppercaseA, 'A');
    _check($uppercaseZ, 'Z');
    _check($leftBracket, '[');
    _check($backslash, r'\');
    _check($rightBracket, ']');
    _check($caret, '^');
    _check($underscore, '_');
    _check($lowercaseA, 'a');
    _check($lowercaseN, 'n');
    _check($lowercaseZ, 'z');
    _check($leftBrace, '{');
    _check($pipe, '|');
    _check($rightBrace, '}');
  });
}

void _check(int codeUnit, String text) {
  expect(String.fromCharCode(codeUnit), text);
}
