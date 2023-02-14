import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:jenny/src/structure/line_content.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueOption', () {
    test('empty option', () {
      final option = DialogueOption(content: LineContent(''));
      option.evaluate();
      expect(option.character, isNull);
      expect(option.tags, isEmpty);
      expect(option.attributes, isEmpty);
      expect(option.text, '');
      expect(option.isConst, true);
      expect(option.isAvailable, true);
      expect(option.isDisabled, false);
      expect('$option', 'Option()');
    });

    test('simple option', () {
      final option = DialogueOption(
        content: LineContent('me'),
        character: Character('Rook'),
        condition: constFalse,
      );
      option.evaluate();
      expect(option.character!.name, 'Rook');
      expect(option.tags, isEmpty);
      expect(option.attributes, isEmpty);
      expect(option.text, 'me');
      expect(option.isAvailable, false);
      expect(option.isDisabled, true);
      expect('$option', 'Option(Rook: me #disabled)');
    });
  });
}
