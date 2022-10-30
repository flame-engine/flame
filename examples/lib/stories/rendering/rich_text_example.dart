import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class RichTextExample extends FlameGame {
  static String description = '';

  @override
  Color backgroundColor() => const Color(0xFF888888);

  @override
  Future<void> onLoad() async {
    add(MyTextComponent()..position = Vector2(100, 50));
  }
}

class MyTextComponent extends PositionComponent {
  late final Element element;

  @override
  Future<void> onLoad() async {
    final style = DocumentStyle(
      width: 400,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      background: BackgroundStyle(
        color: const Color(0xFFFFFFEE),
        borderColor: const Color(0xFF000000),
        borderWidth: 2.0,
      ),
      paragraph: BlockStyle(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        background: BackgroundStyle(
          color: const Color(0xFFFFF0CB),
          borderColor: const Color(0xFFAAAAAA),
        ),
      ),
    );
    final document = DocumentNode([
      HeaderNode.simple('1984', level: 1),
      ParagraphNode.simple(
        'Anything could be true. The so-called laws of nature were nonsense.',
      ),
      ParagraphNode.simple(
        'The law of gravity was nonsense. "If I wished," O\'Brien had said, '
        '"I could float off this floor like a soap bubble." Winston worked it '
        'out. "If he thinks he floats off the floor, and I simultaneously '
        'think I can see him do it, then the thing happens."',
      ),
      ParagraphNode.group([
        PlainTextNode(
            'Suddenly, like a lump of submerged wreckage breaking the surface '
            'of water, the thought burst into his mind: '),
        ItalicTextNode.group([
          PlainTextNode('"It doesn\'t really happen. We imagine it. It is '),
          BoldTextNode.simple('hallucination'),
          PlainTextNode('."'),
        ]),
      ]),
      ParagraphNode.simple(
        'He pushed the thought under instantly. The fallacy was obvious. It '
        'presupposed that somewhere or other, outside oneself, there was a '
        '"real" world where "real" things happened. But how could there be '
        'such a world? What knowledge have we of anything, save through our '
        'own minds? All happenings are in the mind. Whatever happens in all '
        'minds, truly happens.',
      ),
    ]);
    element = document.format(style);
  }

  @override
  void render(Canvas canvas) {
    element.render(canvas);
  }
}
