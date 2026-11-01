import 'package:flame/components.dart';
import 'package:flame_devtools/widgets/anchor_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _names = Anchor.values.map((anchor) => anchor.name).toList();

// An anchor that has no cell in the grid.
final _customAnchor = const Anchor(0.2, 0.3).toString();

void main() {
  group('AnchorPicker', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      required String anchor,
      ValueChanged<String>? onSelected,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnchorPicker(
              anchor: anchor,
              onSelected: onSelected ?? (_) {},
            ),
          ),
        ),
      );
    }

    Finder cell(String name) => find.byKey(Key('anchor_cell_$name'));

    bool isSelected(WidgetTester tester, String name) {
      return tester.widget<IconButton>(cell(name)).isSelected ?? false;
    }

    testWidgets('has a cell for each of the nine anchors', (tester) async {
      await pumpPicker(tester, anchor: Anchor.center.name);

      for (final name in _names) {
        expect(cell(name), findsOneWidget, reason: name);
        expect(tester.widget<IconButton>(cell(name)).tooltip, name);
      }
      expect(find.byType(IconButton), findsNWidgets(9));
    });

    testWidgets('lays the cells out in a 3x3 grid', (tester) async {
      await pumpPicker(tester, anchor: Anchor.center.name);

      final topLeft = tester.getCenter(cell('topLeft'));
      final topRight = tester.getCenter(cell('topRight'));
      final bottomLeft = tester.getCenter(cell('bottomLeft'));
      final center = tester.getCenter(cell('center'));

      expect(topLeft.dx, lessThan(topRight.dx));
      expect(topLeft.dy, equals(topRight.dy));
      expect(topLeft.dy, lessThan(bottomLeft.dy));
      expect(topLeft.dx, equals(bottomLeft.dx));
      expect(center.dx, greaterThan(topLeft.dx));
      expect(center.dx, lessThan(topRight.dx));
      expect(center.dy, greaterThan(topLeft.dy));
      expect(center.dy, lessThan(bottomLeft.dy));
    });

    testWidgets('selects only the cell of a predefined anchor', (tester) async {
      await pumpPicker(tester, anchor: Anchor.center.name);

      for (final name in _names) {
        expect(
          isSelected(tester, name),
          name == Anchor.center.name,
          reason: name,
        );
      }
      expect(
        tester.widget<Text>(find.byKey(const Key('anchor_name'))).data,
        Anchor.center.name,
      );
    });

    testWidgets('selects no cell for a custom anchor', (tester) async {
      await pumpPicker(tester, anchor: _customAnchor);

      for (final name in _names) {
        expect(isSelected(tester, name), isFalse, reason: name);
      }
      expect(
        tester.widget<Text>(find.byKey(const Key('anchor_name'))).data,
        _customAnchor,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('orders the cells like Anchor.values', (tester) async {
      await pumpPicker(tester, anchor: Anchor.center.name);

      final cells =
          [
            for (final name in _names) (name, tester.getCenter(cell(name))),
          ]..sort((a, b) {
            final byRow = a.$2.dy.compareTo(b.$2.dy);
            return byRow != 0 ? byRow : a.$2.dx.compareTo(b.$2.dx);
          });

      expect([for (final (name, _) in cells) name], _names);
    });

    testWidgets('fits a long custom anchor into a narrow width', (
      tester,
    ) async {
      final anchor = const Anchor(1 / 3, 2 / 3).toString();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250,
              child: AnchorPicker(anchor: anchor, onSelected: (_) {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<Text>(find.byKey(const Key('anchor_name'))).data,
        anchor,
      );
    });

    testWidgets('reports the tapped cell for a predefined anchor', (
      tester,
    ) async {
      final selected = <String>[];
      await pumpPicker(
        tester,
        anchor: Anchor.center.name,
        onSelected: selected.add,
      );

      await tester.tap(cell('bottomRight'));
      await tester.pump();

      expect(selected, ['bottomRight']);
    });

    testWidgets('reports the tapped cell for a custom anchor', (tester) async {
      final selected = <String>[];
      await pumpPicker(
        tester,
        anchor: _customAnchor,
        onSelected: selected.add,
      );

      await tester.tap(cell('topCenter'));
      await tester.pump();

      expect(selected, ['topCenter']);
    });
  });
}
