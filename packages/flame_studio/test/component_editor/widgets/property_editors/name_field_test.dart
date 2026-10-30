import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(NameField, () {
    late List<String> changes;

    setUp(() => changes = []);

    String? validator(String name) =>
        name.isEmpty || name == 'size' ? 'Invalid' : null;

    Widget buildSubject(String value) => MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            NameField(
              value: value,
              validator: validator,
              onChanged: changes.add,
            ),
            const TextField(key: Key('other')),
          ],
        ),
      ),
    );

    testWidgets('commits every valid edit while typing', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      for (final input in ['h', 'he', '', 'size', 'hea']) {
        await tester.enterText(find.byType(NameField), input);
      }

      expect(changes, equals(['h', 'he', 'hea']));
    });

    testWidgets('shows the error of rejected names', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      await tester.enterText(find.byType(NameField), 'size');
      await tester.pump();
      expect(find.text('Invalid'), findsOneWidget);

      await tester.enterText(find.byType(NameField), 'eye');
      await tester.pump();
      expect(find.text('Invalid'), findsNothing);
    });

    testWidgets('accepts going back to the current name', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      await tester.enterText(find.byType(NameField), 'size');
      await tester.enterText(find.byType(NameField), 'head');
      await tester.pump();

      expect(find.text('Invalid'), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('shows names changed elsewhere', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      await tester.pumpWidget(buildSubject('eye'));

      expect(find.text('eye'), findsOneWidget);
    });

    testWidgets('reverts rejected input when losing focus', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      await tester.enterText(find.byType(NameField), 'size');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(find.text('head'), findsOneWidget);
      expect(find.text('Invalid'), findsNothing);
    });

    testWidgets('reverts rejected input when submitted', (tester) async {
      await tester.pumpWidget(buildSubject('head'));

      await tester.enterText(find.byType(NameField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('head'), findsOneWidget);
    });
  });
}
