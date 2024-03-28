import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('ScrollTextBoxComponent', () {
    testWithFlameGame(
      'onComplete is called when no scrolling is required',
      (game) async {
        final onComplete = MockOnCompleteCallback();

        when(onComplete).thenReturn(null);

        final component = ScrollTextBoxComponent(
          size: Vector2(200, 100),
          text: 'Short text',
          onComplete: onComplete,
        );
        await game.ensureAdd(component);

        game.update(0.1);

        verify(onComplete).called(1);
      },
    );

    testWithFlameGame(
      'onComplete is called when scrolling is required',
      (game) async {
        final onComplete = MockOnCompleteCallback();

        when(onComplete).thenReturn(null);

        final component = ScrollTextBoxComponent(
          size: Vector2(200, 100),
          text: '''Long text that will definitely require scrolling to be 
fully visible in the given size of the ScrollTextBoxComponent.''',
          onComplete: onComplete,
        );
        await game.ensureAdd(component);

        game.update(0.1);

        verify(onComplete).called(1);
      },
    );

    testWithFlameGame(
      'Text position moves to <0 when scrolled',
      (game) async {
        final scrollComponent = ScrollTextBoxComponent(
          size: Vector2(50, 50),
          text: '''This is a test text that is long enough to require scrolling 
to see the entire content. It should test whether the scrolling 
functionality properly adjusts the text position.''',
          onComplete: () {},
        );

        expect(scrollComponent.children.length, greaterThan(0));
        expect(scrollComponent.children.first, isA<ClipComponent>());
        final clipCmp = scrollComponent.children.first as ClipComponent;

        expect(clipCmp.children.length, greaterThan(0));
        expect(clipCmp.children.first, isA<PositionComponent>());
        final innerScrollComponent =
            clipCmp.children.first as PositionComponent;

        expect(innerScrollComponent.position.y, equals(0));
        await game.ensureAdd(scrollComponent);

        expect(innerScrollComponent.position.y, lessThan(0));
      },
    );

    testWithFlameGame('Text notifies if a new line is added', (game) async {
      int newLineCount = 0;
      final scrollComponent = ScrollTextBoxComponent(
        size: Vector2(50, 50),
        text: '''This 
test
has
five
lines.''',
      );
      expect(scrollComponent.newLineNotifier.value, equals(0));

      scrollComponent.newLineNotifier.addListener(() {
        newLineCount++;
      });
      await game.ensureAdd(scrollComponent);
      expect(newLineCount, equals(5));
    });
  });
}

class MockOnCompleteCallback extends Mock {
  void call();
}
