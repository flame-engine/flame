import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
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
      final line0 = DialogueLine(content: constEmptyString);
      final line1 = DialogueLine(content: const StringLiteral('one'));
      final line2 = DialogueLine(content: const StringLiteral('two'));
      final block = Block([line0, line1, line2]);
      expect(block.length, 3);
      expect(block.isEmpty, false);
      expect(block.isNotEmpty, true);
    });
  });
}
