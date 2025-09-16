import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugTextFormatter', () {
    testGolden(
      'Render debug text',
      (game, tester) async {
        game.add(
          _TextElementsComponent([
            DebugTextRenderer().format('one two  three')..translate(5, 5),
            DebugTextRenderer().format(' x ')..translate(5, 25),
            DebugTextRenderer().format('  ')..translate(5, 45),
            DebugTextRenderer().format('')..translate(25, 45),
            DebugTextRenderer(
              color: const Color(0xFFFF88AA),
            ).format('Flame Engine')..translate(5, 65),
            DebugTextRenderer(fontWeight: FontWeight.bold).format('Blue Fire')
              ..translate(5, 85),
            DebugTextRenderer(fontWeight: FontWeight.w900).format('Blue Fire')
              ..translate(5, 105),
            DebugTextRenderer(fontStyle: FontStyle.italic).format('Blue Fire')
              ..translate(5, 125),
            DebugTextRenderer(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF0088FF),
            ).format('a b c d e f g h i')..translate(5, 145),
            DebugTextRenderer(fontSize: 10).format('www.flame-engine.org')
              ..translate(5, 165),
          ]),
        );
      },
      goldenFile: 'golden_debug_text.png',
      size: Vector2(300, 200),
    );
  });
}

class _TextElementsComponent extends PositionComponent {
  _TextElementsComponent(this.elements);

  final List<InlineTextElement> elements;

  @override
  void render(Canvas canvas) {
    for (final element in elements) {
      element.draw(canvas);
    }
  }
}
