import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasDraggableComponents', () {
    testWidgets(
      'drags are delivered to DragCallbacks components',
      (tester) async {
        var nDragStartCalled = 0;
        var nDragUpdateCalled = 0;
        var nDragEndCalled = 0;
        final game = _GameWithHasDraggableComponents(
          children: [
            _DragCallbacksComponent(
              position: Vector2(20, 20),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
              onDragUpdate: (e) => nDragUpdateCalled++,
              onDragEnd: (e) => nDragEndCalled++,
            )
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));
        expect(game.children.length, 1);

        // regular drag
        await tester.timedDragFrom(
          const Offset(50, 50),
          const Offset(20, 0),
          const Duration(milliseconds: 100),
        );
        expect(nDragStartCalled, 1);
        expect(nDragUpdateCalled, 8);
        expect(nDragEndCalled, 1);

        // cancelled drag
        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(const Offset(10, 10));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nDragStartCalled, 2);
        expect(nDragEndCalled, 2);
      },
    );
  });
}

class _GameWithHasDraggableComponents extends FlameGame
    with HasDraggableComponents {
  _GameWithHasDraggableComponents({super.children});
}

class _DragCallbacksComponent extends PositionComponent with DragCallbacks {
  _DragCallbacksComponent({
    void Function(DragStartEvent)? onDragStart,
    void Function(DragUpdateEvent)? onDragUpdate,
    void Function(DragEndEvent)? onDragEnd,
    super.position,
    super.size,
  })  : _onDragStart = onDragStart,
        _onDragUpdate = onDragUpdate,
        _onDragEnd = onDragEnd;

  final void Function(DragStartEvent)? _onDragStart;
  final void Function(DragUpdateEvent)? _onDragUpdate;
  final void Function(DragEndEvent)? _onDragEnd;

  @override
  void onDragStart(DragStartEvent event) => _onDragStart?.call(event);

  @override
  void onDragUpdate(DragUpdateEvent event) => _onDragUpdate?.call(event);

  @override
  void onDragEnd(DragEndEvent event) => _onDragEnd?.call(event);
}
