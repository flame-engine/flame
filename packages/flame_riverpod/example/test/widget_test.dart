import 'package:flame/game.dart';
import 'package:flame_riverpod_example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test equality of Flutter Text Widget and Flame Text Component',
      (widgetTester) async {
    await widgetTester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    await widgetTester.pump(const Duration(seconds: 5));

    // Expect FlutterCountingComponent to exist on the page
    final flutterCounterFinder = find.byType(FlutterCountingComponent);
    expect(flutterCounterFinder, findsOneWidget);
    final flutterCounterTextFinder = find.descendant(
      of: flutterCounterFinder,
      matching: find.byType(Text),
    );

    // Expect a title 'e.g. Flutter' and the current count of the stream as
    // seperate [Text] widget.
    expect(flutterCounterTextFinder, findsNWidgets(2));

    final flutterCounterTextWidgets =
        widgetTester.widgetList(flutterCounterTextFinder);

    // Expect RiverpodGameWidget to exist
    final riverpodGameWidgetFinder = find.byType(RiverpodGameWidget);
    expect(riverpodGameWidgetFinder, findsOneWidget);

    // Find the game widget
    final gameWidgetFinder = find.descendant(
      of: riverpodGameWidgetFinder,
      matching: find.byType(GameWidget<FlameGame>),
    );
    expect(gameWidgetFinder, findsOneWidget);

    final gameWidget =
        widgetTester.widget(gameWidgetFinder) as GameWidget<FlameGame>;

    // GameWidget contains a FutureBuilder, which calls setState when a Future
    // completes. We therefore need to pump / re-render the widget to ensure
    // that the game mounts properly. Alternatively, we could manually trigger
    // lifecycle events.
    await widgetTester.pump(const Duration(seconds: 1));

    expect(gameWidget.game is FlameGame, true);
    expect(gameWidget.game!.isLoaded, true);
    expect(gameWidget.game!.isMounted, true);
    expect(gameWidget.game!.isAttached, true);

    // Pump again to provide the gameRenderBox with a [BuildContext].
    await widgetTester.pump(const Duration(seconds: 1));

    // Check components are mounted as expected.
    expect(gameWidget.game?.children.isNotEmpty ?? false, true);

    final riverpodAwareTextComponent =
        gameWidget.game?.children.elementAt(1) as RiverpodAwareTextComponent?;
    expect(riverpodAwareTextComponent is RiverpodAwareTextComponent, true);

    // Current count of the stream from the [Text] widget. This is best
    // retrieved after all pumps.
    final flutterCounterTextWidgetOfInterest =
        flutterCounterTextWidgets.elementAt(1);

    final currentCount =
        int.parse((flutterCounterTextWidgetOfInterest as Text).data!);

    // Expect equality (in the presented string value)
    // of the Text Component and the Text Widget
    expect(
      riverpodAwareTextComponent?.textComponent.text == currentCount.toString(),
      true,
    );
  });
}
