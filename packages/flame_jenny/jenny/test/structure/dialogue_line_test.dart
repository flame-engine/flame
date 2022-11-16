import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueLine', () {
    test('empty line', () {
      const line = DialogueLine(content: constEmptyString);
      expect(line.character, isNull);
      expect(line.tags, isNull);
      expect(line.content.value, '');
      expect('$line', 'DialogueLine()');
    });

    test('line with meta information', () {
      const line = DialogueLine(
        character: 'Bob',
        content: StringLiteral('Hello!'),
        tags: ['#red', '#fast'],
      );
      expect(line.content.value, 'Hello!');
      expect(line.character, 'Bob');
      expect(line.tags!.length, 2);
      expect(line.tags![0], '#red');
      expect(line.tags![1], '#fast');
      expect('$line', 'DialogueLine(Bob: Hello!)');
    });
  });
}
