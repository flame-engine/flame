import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Enemy extends PositionedComponent with Notifier {}

void main() {
  group('ComponentsNotifierBuilder', () {
    testWidgets('renders the initial value', (tester) async {
      final notifier = ComponentsNotifier<_Enemy>([_Enemy()]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentsNotifierBuilder(
              notifier: notifier,
              builder: (context, notifier) {
                return Text(
                  'Enemies: ${notifier.components.length}',
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Enemies: 1'), findsOneWidget);
    });

    testWidgets('rebuilds when an enemy is added', (tester) async {
      final notifier = ComponentsNotifier<_Enemy>([_Enemy()]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentsNotifierBuilder(
              notifier: notifier,
              builder: (context, notifier) {
                return Text(
                  'Enemies: ${notifier.components.length}',
                );
              },
            ),
          ),
        ),
      );

      notifier.add(_Enemy());
      await tester.pump();

      expect(find.text('Enemies: 2'), findsOneWidget);
    });

    testWidgets('rebuilds when an enemy is added', (tester) async {
      final enemy = _Enemy();
      final notifier = ComponentsNotifier<_Enemy>([enemy]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentsNotifierBuilder(
              notifier: notifier,
              builder: (context, notifier) {
                return Text(
                  'Enemies: ${notifier.components.length}',
                );
              },
            ),
          ),
        ),
      );

      notifier.remove(enemy);
      await tester.pump();

      expect(find.text('Enemies: 0'), findsOneWidget);
    });
  });
}
