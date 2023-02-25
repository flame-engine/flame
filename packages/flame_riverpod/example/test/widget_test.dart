import 'package:example/main.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test equality of Flutter Text Widget and Flame Text Component',
      (widgetTester) async {
    await widgetTester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );
    await widgetTester.pump(const Duration(seconds: 3));

    // Expect counter to exist
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

    // Current count of the stream as a [Text] widget
    final flutterCounterTextWidgetOfInterest =
        flutterCounterTextWidgets.elementAt(1);

    // Expect RiverpodGameWidget to exist
    final riverpodGameWidgetFinder = find.byType(RiverpodGameWidget);

    expect(riverpodGameWidgetFinder, findsOneWidget);

    // Find the game widget
    final gameWidgetFinder = find.descendant(
      of: riverpodGameWidgetFinder,
      matching: find.byType(GameWidget<FlameGame>),
    );
    expect(gameWidgetFinder, findsOneWidget);

    final gameWidget = widgetTester.widget(gameWidgetFinder);

    // Initialise the game lifecycle
    (gameWidget as GameWidget<FlameGame>).game?.lifecycle.processQueues();
    expect(gameWidget.game?.lifecycle.hasPendingEvents, false);
    expect(gameWidget.game?.children.isNotEmpty ?? false, true);

    final riverpodAwareTextComponent =
        gameWidget.game?.children.elementAt(1) as RiverpodAwareTextComponent?;
    expect(riverpodAwareTextComponent is RiverpodAwareTextComponent, true);

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
