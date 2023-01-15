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
      expect(line.isConst, true);
      expect('$line', 'DialogueLine()');
    });

    test('line with meta information', () {
      final line = DialogueLine(
        character: Character('Bob'),
        content: LineContent('Hello!'),
        tags: ['#red', '#fast'],
      );
      expect(line.text, 'Hello!');
      expect(line.character!.name, 'Bob');
      expect(line.tags, ['#red', '#fast']);
      expect('$line', 'DialogueLine(Bob: Hello!)');
    });

    test('line with markup', () {
      final line = DialogueLine(
        content: LineContent(
          'once upon a time',
          null,
          [MarkupAttribute('i', 0, 4), MarkupAttribute('b', 12, 16)],
        ),
      );
      expect(line.text, 'once upon a time');
      expect(line.isConst, true);
      expect(line.tags, isEmpty);
      expect(line.attributes[0].name, 'i');
      expect(line.attributes[1].name, 'b');
    });

    test('line with inline expressions', () {
      final yarn = YarnProject()
        ..variables.setVariable(r'$value', 'ok')
        ..parse(
          'title: A\n'
          '---\n'
          'Test line: {\$value}\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines.first as DialogueLine;
      expect('$line', 'DialogueLine(<unevaluated>)');
      line.evaluate();
      expect('$line', 'DialogueLine(Test line: ok)');
    });

    test('dynamic markup attributes', () {
      final yarn = YarnProject()
        ..variables.setVariable(r'$index', 1)
        ..parse(
          'title: A\n---\n'
          'X [box index=\$index /] Y Z\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;

      line.evaluate();
      expect(line.text, 'X Y Z');
      expect(line.attributes[0].name, 'box');
      expect(line.attributes[0].parameters['index'], 1);

      yarn.variables.setVariable(r'$index', 42);
      line.evaluate();
      expect(line.text, 'X Y Z');
      expect(line.attributes[0].name, 'box');
      expect(line.attributes[0].parameters['index'], 42);
    });

    test('space after markup attribute', () {
      final yarn = YarnProject()
        ..parse(
          'title: A\n---\n'
          'The price is 243[gp/] per item\n'
          '[test attr=0/] ?\n'
          '===\n',
        );
      final line1 = yarn.nodes['A']!.lines[0] as DialogueLine;
      line1.evaluate();
      expect(line1.text, 'The price is 243 per item');
      expect(line1.attributes[0].name, 'gp');
      expect(line1.attributes[0].length, 0);
      expect(line1.attributes[0].start, 'The price is 243'.length);

      final line2 = yarn.nodes['A']!.lines[1] as DialogueLine;
      line2.evaluate();
      expect(line2.text, ' ?');
      expect(line2.attributes[0].name, 'test');
    });
  });
}
