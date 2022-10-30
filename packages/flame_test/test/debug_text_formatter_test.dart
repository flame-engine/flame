import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugTextFormatter', () {
    testGolden(
      'Render debug text',
      (game) async {
        game.add(
          TextElementsComponent([
            DebugTextFormatter().format('one two  three')..translate(5, 5),
            DebugTextFormatter().format(' x ')..translate(5, 25),
            DebugTextFormatter().format('  ')..translate(5, 45),
            DebugTextFormatter().format('')..translate(25, 45),
            DebugTextFormatter(color: const Color(0xFFFF88AA))
                .format('Flame Engine')
              ..translate(5, 65),
            DebugTextFormatter(fontWeight: FontWeight.bold).format('Blue Fire')
              ..translate(5, 85),
            DebugTextFormatter(fontWeight: FontWeight.w900).format('Blue Fire')
              ..translate(5, 105),
            DebugTextFormatter(fontStyle: FontStyle.italic).format('Blue Fire')
              ..translate(5, 125),
            DebugTextFormatter(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF0088FF),
            ).format('a b c d e f g h i')
              ..translate(5, 145),
            DebugTextFormatter(fontSize: 10).format('www.flame-engine.org')
              ..translate(5, 165),
          ]),
        );
      },
      goldenFile: 'golden_debug_text.png',
      size: Vector2(300, 200),
    );
  });
}

class TextElementsComponent extends PositionComponent {
  TextElementsComponent(this.elements);

  final List<TextElement> elements;

  @override
  void render(Canvas canvas) {
    for (final element in elements) {
      element.render(canvas);
    }
  }
}
