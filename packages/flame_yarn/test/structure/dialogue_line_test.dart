import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/expressions/literal.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueLine', () {
    test('empty line', () {
      const line = DialogueLine(content: constEmptyString);
      expect(line.character, isNull);
      expect(line.tags, isNull);
      expect(line.content.value, '');
      expect(line.kind, StatementKind.line);
    });

    test('line with meta information', () {
      const line = DialogueLine(
        character: 'Bob',
        content: constEmptyString,
        tags: ['#red', '#fast'],
      );
      expect(line.kind, StatementKind.line);
      expect(line.content.value, '');
      expect(line.character, 'Bob');
      expect(line.tags!.length, 2);
      expect(line.tags![0], '#red');
      expect(line.tags![1], '#fast');
    });
  });
}
