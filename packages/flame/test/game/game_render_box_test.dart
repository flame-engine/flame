import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlameGame extends Mock implements FlameGame {}

class _MockBuildContext extends Mock implements BuildContext {}

class _MockPipelineOwner extends Mock implements PipelineOwner {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

final nodesNeedingCompositingBitsUpdate = <RenderObject>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(nodesNeedingCompositingBitsUpdate.clear);

  group('GameRenderBox', () {
    test('game/attach', () {
      final owner = _MockPipelineOwner();
      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      verify(() => game.attach(owner, renderBox)).called(1);
      expect(renderBox.gameLoop, isNotNull);
      verify(() => game.paused).called(1);

      final anotherGame = _MockFlameGame();
      when(() => anotherGame.paused).thenReturn(true);

      renderBox.game = anotherGame;
      verify(game.detach).called(1);
      verify(() => anotherGame.attach(owner, renderBox)).called(1);
      verify(() => anotherGame.paused).called(1);
      expect(renderBox.gameLoop, isNotNull);
    });
    test('buildContext', () {
      final owner = _MockPipelineOwner();
      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      expect(renderBox.buildContext, context);
    });
    test('isRepaintBoundary', () {
      final owner = PipelineOwner();

      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      expect(renderBox.isRepaintBoundary, false);

      renderBox.isRepaintBoundary = true;

      expect(renderBox.isRepaintBoundary, true);
    });
  });
}
