import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/line_content.dart';
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
      final line0 = DialogueLine(content: LineContent(''));
      final line1 = DialogueLine(content: LineContent('one'));
      final line2 = DialogueLine(content: LineContent('two'));
      final block = Block([line0, line1, line2]);
      expect(block.length, 3);
      expect(block.isEmpty, false);
      expect(block.isNotEmpty, true);
    });
  });
}
