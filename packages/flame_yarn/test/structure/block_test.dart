
import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

void main() {
  group('Block', () {
    test('empty block', () {
      const block = Block.empty();
      expect(block.length, 0);
      expect(block.isEmpty, true);
      expect(block.isNotEmpty, false);
    });

    test('non-empty block', () {
      const line0 = DialogueLine(content: constEmptyString);
      const line1 = DialogueLine(content: StringLiteral('one'));
      const line2 = DialogueLine(content: StringLiteral('two'));
      const block = Block([line0, line1, line2]);
      expect(block.length, 3);
      expect(block.isEmpty, false);
      expect(block.isNotEmpty, true);
    });
  });
}
