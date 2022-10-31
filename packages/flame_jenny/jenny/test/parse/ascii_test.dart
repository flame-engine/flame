import 'package:jenny/src/parse/ascii.dart';
import 'package:test/test.dart';

void main() {
  test('ASCII', () {
    check($tab, '\t');
    check($lineFeed, '\n');
    check($carriageReturn, '\r');
    check($space, ' ');
    check($exclamation, '!');
    check($doubleQuote, '"');
    check($hash, '#');
    check($dollar, r'$');
    check($percent, '%');
    check($ampersand, '&');
    check($singleQuote, "'");
    check($leftParen, '(');
    check($rightParen, ')');
    check($asterisk, '*');
    check($plus, '+');
    check($comma, ',');
    check($minus, '-');
    check($dot, '.');
    check($slash, '/');
    check($digit0, '0');
    check($digit9, '9');
    check($colon, ':');
    check($lessThan, '<');
    check($equals, '=');
    check($greaterThan, '>');
    check($uppercaseA, 'A');
    check($uppercaseZ, 'Z');
    check($leftBracket, '[');
    check($backslash, r'\');
    check($rightBracket, ']');
    check($caret, '^');
    check($underscore, '_');
    check($lowercaseA, 'a');
    check($lowercaseN, 'n');
    check($lowercaseZ, 'z');
    check($leftBrace, '{');
    check($pipe, '|');
    check($rightBrace, '}');
  });
}

void check(int codeUnit, String text) {
  expect(String.fromCharCode(codeUnit), text);
}
