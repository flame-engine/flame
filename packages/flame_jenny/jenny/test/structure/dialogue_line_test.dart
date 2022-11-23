import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/line_content.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueLine', () {
    test('empty line', () {
      final line = DialogueLine(content: LineContent(''));
      expect(line.character, isNull);
      expect(line.tags, isEmpty);
      expect(line.attributes, isEmpty);
      expect(line.text, '');
      expect('$line', 'DialogueLine()');
    });

    test('line with meta information', () {
      final line = DialogueLine(
        character: 'Bob',
        content: LineContent('Hello!'),
        tags: ['#red', '#fast'],
      );
      expect(line.text, 'Hello!');
      expect(line.character, 'Bob');
      expect(line.tags, ['#red', '#fast']);
      expect('$line', 'DialogueLine(Bob: Hello!)');
    });
  });
}
