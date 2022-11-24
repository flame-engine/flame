import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/dialogue_option.dart';
import 'package:jenny/src/structure/line_content.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:test/test.dart';

void main() {
  group('Node', () {
    test('simple node', () {
      const node = Node(
        title: 'Introduction',
        content: Block.empty(),
      );

      expect(node.title, 'Introduction');
      expect(node.lines, <DialogueEntry>[]);
      expect(node.tags, isNull);
      expect('$node', 'Node(Introduction)');
    });

    test('node with tags', () {
      const node = Node(
        title: 'Conclusion',
        content: Block.empty(),
        tags: {'line': 'af451', 'characters': 'Alice, Bob'},
      );
      expect(node.title, 'Conclusion');
      expect(node.tags, isNotEmpty);
      expect(node.tags!.length, 2);
      expect(node.tags!['line'], 'af451');
      expect(node.tags!['characters'], 'Alice, Bob');
    });

    group('iterators', () {
      test('iterating an empty node', () {
        const node = Node(title: 'X', content: Block.empty());
        final statements = List<DialogueEntry>.from(node);
        expect(statements, isEmpty);
      });

      test('iterating node with one line', () {
        final line0 = DialogueLine(content: LineContent(''));
        final node = Node(title: 'X', content: Block([line0]));
        expect(node.toList(), [line0]);
      });

      test('iterating multi-line node', () {
        final line1 = DialogueLine(content: LineContent('one'));
        final line2 = DialogueLine(content: LineContent('two'));
        final line3 = DialogueLine(content: LineContent('three'));
        final line4 = DialogueLine(content: LineContent('four'));
        final node = Node(
          title: 'quadruple',
          content: Block([line1, line2, line3, line4]),
        );
        expect(List<DialogueEntry>.from(node), [line1, line2, line3, line4]);
      });

      test('iterating deep node', () {
        final node = Node(
          title: 'complicated',
          content: Block([
            DialogueLine(content: LineContent('one')),
            DialogueLine(content: LineContent('two')),
            DialogueChoice([
              DialogueOption(
                content: LineContent('select 1'),
                block: Block([
                  DialogueLine(content: LineContent('so one it is')),
                  DialogueLine(content: LineContent('good choice!')),
                ]),
              ),
              DialogueOption(
                content: LineContent('select 2'),
                block: Block([
                  DialogueLine(content: LineContent('oops!')),
                ]),
              ),
            ]),
            DialogueLine(content: LineContent('bye!')),
          ]),
        );

        final lines0 = <DialogueEntry>[];
        final it0 = node.iterator;
        while (it0.moveNext()) {
          lines0.add(it0.current);
        }
        expect(lines0, node.lines);

        final lines1 = <DialogueEntry>[];
        final it1 = node.iterator;
        while (it1.moveNext()) {
          final nextLine = it1.current;
          lines1.add(nextLine);
          if (nextLine is DialogueChoice) {
            it1.diveInto(nextLine.options[0].block);
          }
        }
        expect(
          lines1,
          [
            DialogueLine(content: LineContent('one')),
            DialogueLine(content: LineContent('two')),
            node.lines[2] as DialogueChoice,
            DialogueLine(content: LineContent('so one it is')),
            DialogueLine(content: LineContent('good choice!')),
            DialogueLine(content: LineContent('bye!')),
          ],
        );
      });
    });
  });
}
