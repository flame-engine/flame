import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/expressions/literal.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/option.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:test/test.dart';

void main() {
  group('Node', () {
    test('simple node', () {
      const node = Node(
        title: 'Introduction',
        content: Block.empty(),
      );

      expect(node.title, 'Introduction');
      expect(node.lines, <Statement>[]);
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
        final statements = List<Statement>.from(node);
        expect(statements, isEmpty);
      });

      test('iterating node with one line', () {
        const line0 = DialogueLine(content: constEmptyString);
        const node = Node(title: 'X', content: Block([line0]));
        expect(node.toList(), [line0]);
      });

      test('iterating multi-line node', () {
        const line1 = DialogueLine(content: StringLiteral('one'));
        const line2 = DialogueLine(content: StringLiteral('two'));
        const line3 = DialogueLine(content: StringLiteral('three'));
        const line4 = DialogueLine(content: StringLiteral('four'));
        const node = Node(
          title: 'quadruple',
          content: Block([line1, line2, line3, line4]),
        );
        expect(List<Statement>.from(node), [line1, line2, line3, line4]);
      });

      test('iterating deep node', () {
        final node = Node(
          title: 'complicated',
          content: Block([
            const DialogueLine(content: StringLiteral('one')),
            const DialogueLine(content: StringLiteral('two')),
            DialogueChoice([
              Option(
                content: const StringLiteral('select 1'),
                block: const Block([
                  DialogueLine(content: StringLiteral('so one it is')),
                  DialogueLine(content: StringLiteral('good choice!')),
                ]),
              ),
              Option(
                content: const StringLiteral('select 2'),
                block: const Block([
                  DialogueLine(content: StringLiteral('oops!')),
                ]),
              ),
            ]),
            const DialogueLine(content: StringLiteral('bye!')),
          ]),
        );

        final lines0 = <Statement>[];
        final it0 = node.iterator;
        while (it0.moveNext()) {
          lines0.add(it0.current);
        }
        expect(lines0, node.lines);

        final lines1 = <Statement>[];
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
            const DialogueLine(content: StringLiteral('one')),
            const DialogueLine(content: StringLiteral('two')),
            node.lines[2] as DialogueChoice,
            const DialogueLine(content: StringLiteral('so one it is')),
            const DialogueLine(content: StringLiteral('good choice!')),
            const DialogueLine(content: StringLiteral('bye!')),
          ],
        );
      });
    });
  });
}
