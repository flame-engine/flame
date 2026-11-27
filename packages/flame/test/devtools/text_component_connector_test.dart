import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/devtools.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/text_component_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

TextComponentConnector get _connector {
  return DevToolsService.instance.connectors
      .whereType<TextComponentConnector>()
      .single;
}

/// Records the text that it had every time it was rendered.
class _RecordingTextComponent({super.text}) extends TextComponent {
  final rendered = <String>[];

  @override
  void render(Canvas canvas) {
    rendered.add(text);
    super.render(canvas);
  }
}

void main() {
  group('TextComponentConnector', () {
    testWithFlameGame('sets the text', (game) async {
      final component = TextComponent(text: 'Hello');
      await game.world.ensureAdd(component);
      final width = component.width;

      final response = await _connector.setText({
        'id': '${component.hashCode}',
        'text': 'Hello, world',
      });

      expect(response.errorCode, isNull);
      expect(json.decode(response.result!), {
        'id': component.hashCode,
        'text': 'Hello, world',
      });
      expect(component.text, 'Hello, world');
      expect(component.width, greaterThan(width));
    });

    testWithFlameGame('sets an empty text', (game) async {
      final component = TextComponent(text: 'Hello');
      await game.world.ensureAdd(component);

      final response = await _connector.setText({
        'id': '${component.hashCode}',
        'text': '',
      });

      expect(response.errorCode, isNull);
      expect(json.decode(response.result!), {
        'id': component.hashCode,
        'text': '',
      });
      expect(component.text, isEmpty);
      expect(component.width, 0);
    });

    testWithFlameGame('responds with an error without a text', (game) async {
      final component = TextComponent(text: 'Hello');
      await game.world.ensureAdd(component);

      final response = await _connector.setText({
        'id': '${component.hashCode}',
      });

      expect(response.errorCode, ServiceExtensionResponse.invalidParams);
      expect(response.errorDetail, 'The text parameter is required.');
      expect(component.text, 'Hello');
    });

    testWithFlameGame('responds with an error for a component without text', (
      game,
    ) async {
      final component = PositionComponent();
      await game.world.ensureAdd(component);

      final response = await _connector.setText({
        'id': '${component.hashCode}',
        'text': 'Hello',
      });

      expect(response.errorCode, ServiceExtensionResponse.invalidParams);
      expect(
        response.errorDetail,
        'No TextComponent found with id: ${component.hashCode}',
      );
    });

    testWithFlameGame('redraws a text box right away', (game) async {
      final component = TextBoxComponent(text: 'Hello');
      await game.world.ensureAdd(component);
      final cache = component.cache;

      await _connector.setText({
        'id': '${component.hashCode}',
        'text': 'Bye',
      });

      expect(component.cache, isNotNull);
      expect(component.cache, isNot(same(cache)));
    });

    testWidgets('renders the new text while the game is paused', (
      tester,
    ) async {
      final game = FlameGame();
      final component = _RecordingTextComponent(text: 'Hello');
      game.world.add(component);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      game.pauseEngine();
      await tester.pump();
      component.rendered.clear();

      await _connector.setText({
        'id': '${component.hashCode}',
        'text': 'Bye',
      });
      await tester.pump();

      expect(component.rendered, ['Bye']);
    });
  });
}
