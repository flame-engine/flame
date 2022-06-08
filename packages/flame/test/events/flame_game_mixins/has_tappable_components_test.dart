import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasTappableComponents', () {
    testWidgets(
      'taps are delivered to a TapCallbacks component',
      (tester) async {
        var nTapDown = 0;
        var nLongTapDown = 0;
        var nTapCancel = 0;
        var nTapUp = 0;
        final game = _GameWithHasTappableComponents(
          children: [
            _TapCallbacksComponent(
              size: Vector2(200, 100),
              position: Vector2(50, 50),
              onTapDown: (e) => nTapDown++,
              onLongTapDown: (e) => nLongTapDown++,
              onTapCancel: (e) => nTapCancel++,
              onTapUp: (e) => nTapUp++,
            )
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));
        expect(game.children.length, 1);

        // regular tap
        await tester.tapAt(const Offset(100, 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(nTapDown, 1);
        expect(nTapUp, 1);
        expect(nLongTapDown, 0);
        expect(nTapCancel, 0);

        // long tap
        await tester.longPressAt(const Offset(100, 100));
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDown, 2);
        expect(nTapUp, 2);
        expect(nLongTapDown, 1);
        expect(nTapCancel, 0);

        // cancelled tap
        var gesture = await tester.startGesture(const Offset(100, 100));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDown, 3);
        expect(nTapUp, 2);
        expect(nTapCancel, 1);

        // tap cancelled via movement
        gesture = await tester.startGesture(const Offset(100, 100));
        await gesture.moveBy(const Offset(20, 20));
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDown, 4);
        expect(nTapUp, 2);
        expect(nTapCancel, 2);
      },
    );

    testWidgets(
      'TapCallbacks component nested in another TapCallbacks component',
      (tester) async {
        var nTapDownChild = 0;
        var nTapDownParent = 0;
        var nTapCancelChild = 0;
        var nTapCancelParent = 0;
        var nTapUpChild = 0;
        var nTapUpParent = 0;
        final game = _GameWithHasTappableComponents(
          children: [
            _TapCallbacksComponent(
              size: Vector2.all(100),
              position: Vector2.zero(),
              onTapDown: (e) => nTapDownParent++,
              onTapUp: (e) => nTapUpParent++,
              onTapCancel: (e) => nTapCancelParent++,
              children: [
                _TapCallbacksComponent(
                  size: Vector2.all(50),
                  position: Vector2.all(25),
                  onTapDown: (e) {
                    nTapDownChild++;
                    e.continuePropagation = true;
                  },
                  onTapCancel: (e) => nTapCancelChild++,
                  onTapUp: (e) => nTapUpChild++,
                )
              ],
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 1);
        expect(game.children.first.children.length, 1);

        await tester.longPressAt(const Offset(50, 50));
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDownChild, 1);
        expect(nTapDownParent, 1);
        expect(nTapUpChild, 1);
        expect(nTapUpParent, 1);
        expect(nTapCancelChild, 0);
        expect(nTapCancelParent, 0);

        // cancelled tap
        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDownChild, 2);
        expect(nTapDownParent, 2);
        expect(nTapUpChild, 1);
        expect(nTapUpParent, 1);
        expect(nTapCancelChild, 1);
        expect(nTapCancelParent, 1);
      },
    );

    testWidgets(
      'tap events do not propagate down by default',
      (tester) async {
        var nTapDownParent = 0;
        var nTapCancelParent = 0;
        var nTapUpParent = 0;
        final game = _GameWithHasTappableComponents(
          children: [
            _TapCallbacksComponent(
              size: Vector2.all(100),
              position: Vector2.zero(),
              onTapDown: (e) => nTapDownParent++,
              onTapUp: (e) => nTapUpParent++,
              onTapCancel: (e) => nTapCancelParent++,
              children: [
                _SimpleTapCallbacksComponent(size: Vector2.all(100)),
              ],
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 1);
        expect(game.children.first.children.length, 1);

        await tester.longPressAt(const Offset(50, 50));
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDownParent, 0);
        expect(nTapUpParent, 0);
        expect(nTapCancelParent, 0);

        // cancelled tap
        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nTapDownParent, 0);
        expect(nTapUpParent, 0);
        expect(nTapCancelParent, 0);
      },
    );

    testWidgets(
      'local coordinates during tap events',
      (tester) async {
        TapDownEvent? tapDownEvent;
        final game = _GameWithHasTappableComponents(
          children: [
            PositionComponent(
              size: Vector2.all(400),
              position: Vector2.all(10),
              children: [
                PositionComponent(
                  size: Vector2(300, 200),
                  scale: Vector2(1.5, 2),
                  position: Vector2.all(40),
                  children: [
                    _TapCallbacksComponent(
                      size: Vector2(100, 50),
                      position: Vector2(50, 50),
                      onTapDown: (e) => tapDownEvent = e,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 1);
        expect(game.children.first.children.length, 1);

        await tester.tapAt(const Offset(200, 200));
        await tester.pump(const Duration(seconds: 1));
        expect(tapDownEvent, isNotNull);
        expect(tapDownEvent!.devicePosition, Vector2(200, 200));
        expect(tapDownEvent!.canvasPosition, Vector2(200, 200));
        expect(tapDownEvent!.localPosition, Vector2(50, 25));
        final trace = tapDownEvent!.renderingTrace.reversed.toList();
        expect(trace[0], Vector2(50, 25));
        expect(trace[1], Vector2(100, 75));
        expect(trace[2], Vector2(190, 190));
        expect(trace[3], Vector2(200, 200));
      },
    );
  });

  group('HasTappablesBridge', () {
    testWidgets(
      'taps are delivered to tappables of both kings',
      (tester) async {
        var nTappableDown = 0;
        var nTappableCancelled = 0;
        var nTapCallbacksDown = 0;
        var nTapCallbacksCancelled = 0;
        final game = _GameWithDualTappableComponents(
          children: [
            _TapCallbacksComponent(
              size: Vector2(100, 100),
              position: Vector2(20, 20),
              onTapDown: (e) => nTapCallbacksDown++,
              onTapCancel: (e) => nTapCallbacksCancelled++,
            ),
            _TappableComponent(
              size: Vector2(100, 100),
              position: Vector2(40, 40),
              onTapDown: (e) {
                nTappableDown++;
                return true;
              },
              onTapCancel: () {
                nTappableCancelled++;
                return true;
              },
            )
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));
        expect(game.children.length, 2);

        await tester.longPressAt(const Offset(50, 50));
        await tester.pump(const Duration(seconds: 1));
        expect(nTappableDown, 1);
        expect(nTapCallbacksDown, 1);

        // cancelled tap
        final gesture = await tester.startGesture(const Offset(100, 100));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nTapCallbacksDown, 2);
        expect(nTapCallbacksCancelled, 1);
        expect(nTappableDown, 2);
        expect(nTappableCancelled, 1);
      },
    );
  });
}

class _GameWithHasTappableComponents extends FlameGame
    with HasTappableComponents {
  _GameWithHasTappableComponents({super.children});
}

class _GameWithDualTappableComponents extends FlameGame
    with HasTappableComponents, HasTappablesBridge {
  _GameWithDualTappableComponents({super.children});
}

class _TapCallbacksComponent extends PositionComponent with TapCallbacks {
  _TapCallbacksComponent({
    super.children,
    required Vector2 super.position,
    required Vector2 super.size,
    void Function(TapDownEvent)? onTapDown,
    void Function(TapDownEvent)? onLongTapDown,
    void Function(TapUpEvent)? onTapUp,
    void Function(TapCancelEvent)? onTapCancel,
  })  : _onTapDown = onTapDown,
        _onLongTapDown = onLongTapDown,
        _onTapUp = onTapUp,
        _onTapCancel = onTapCancel;

  final void Function(TapDownEvent)? _onTapDown;
  final void Function(TapDownEvent)? _onLongTapDown;
  final void Function(TapUpEvent)? _onTapUp;
  final void Function(TapCancelEvent)? _onTapCancel;

  @override
  void onTapDown(TapDownEvent event) => _onTapDown?.call(event);

  @override
  void onLongTapDown(TapDownEvent event) => _onLongTapDown?.call(event);

  @override
  void onTapUp(TapUpEvent event) => _onTapUp?.call(event);

  @override
  void onTapCancel(TapCancelEvent event) => _onTapCancel?.call(event);
}

class _SimpleTapCallbacksComponent extends PositionComponent with TapCallbacks {
  _SimpleTapCallbacksComponent({super.size});
}

class _TappableComponent extends PositionComponent with Tappable {
  _TappableComponent({
    required Vector2 size,
    required Vector2 position,
    bool Function(TapDownInfo)? onTapDown,
    bool Function()? onTapCancel,
  })  : _onTapDown = onTapDown,
        _onTapCancel = onTapCancel,
        super(size: size, position: position);

  final bool Function(TapDownInfo)? _onTapDown;
  final bool Function()? _onTapCancel;

  @override
  bool onTapDown(TapDownInfo info) {
    return _onTapDown?.call(info) ?? true;
  }

  @override
  bool onTapCancel() {
    return _onTapCancel?.call() ?? true;
  }
}
