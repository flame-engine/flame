import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IgnoreEvents', () {
    testWithFlameGame(
      'correctly ignores events all the way down the subtree',
      (game) async {
        final grandChild = _IgnoreTapCallbacksComponent();
        final child = _IgnoreTapCallbacksComponent(children: [grandChild]);
        final component = _IgnoreTapCallbacksComponent(
          position: Vector2.all(10),
          children: [child],
        );

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));
        expect(child.tapDownEvent, equals(0));
        expect(child.tapUpEvent, equals(0));
        expect(child.tapCancelEvent, equals(0));
        expect(grandChild.tapDownEvent, equals(0));
        expect(grandChild.tapUpEvent, equals(0));
        expect(grandChild.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));
        expect(child.tapDownEvent, equals(0));
        expect(child.tapUpEvent, equals(0));
        expect(child.tapCancelEvent, equals(0));
        expect(grandChild.tapDownEvent, equals(0));
        expect(grandChild.tapUpEvent, equals(0));
        expect(grandChild.tapCancelEvent, equals(0));
      },
    );

    testWithFlameGame(
      'correctly accepts events all the way down the subtree when ignoreEvents '
      'is false',
      (game) async {
        final grandChild = _IgnoreTapCallbacksComponent()..ignoreEvents = false;
        final child = _IgnoreTapCallbacksComponent(children: [grandChild])
          ..ignoreEvents = false;
        final component = _IgnoreTapCallbacksComponent(
          position: Vector2.all(10),
          children: [child],
        )..ignoreEvents = false;

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));
        expect(child.tapDownEvent, equals(1));
        expect(child.tapUpEvent, equals(0));
        expect(child.tapCancelEvent, equals(0));
        expect(grandChild.tapDownEvent, equals(1));
        expect(grandChild.tapUpEvent, equals(0));
        expect(grandChild.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(1));
        expect(component.tapCancelEvent, equals(0));
        expect(child.tapDownEvent, equals(1));
        expect(child.tapUpEvent, equals(1));
        expect(child.tapCancelEvent, equals(0));
        expect(grandChild.tapDownEvent, equals(1));
        expect(grandChild.tapUpEvent, equals(1));
        expect(grandChild.tapCancelEvent, equals(0));
      },
    );
  });
}

mixin _TapCounter on TapCallbacks {
  int tapDownEvent = 0;
  int tapUpEvent = 0;
  int longTapDownEvent = 0;
  int tapCancelEvent = 0;

  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = true;
    tapDownEvent++;
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.continuePropagation = true;
    tapUpEvent++;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    event.continuePropagation = true;
    tapCancelEvent++;
  }
}

class _IgnoreTapCallbacksComponent extends PositionComponent
    with TapCallbacks, _TapCounter, IgnoreEvents {
  _IgnoreTapCallbacksComponent({super.position, super.children})
    : super(size: Vector2.all(10));
}
