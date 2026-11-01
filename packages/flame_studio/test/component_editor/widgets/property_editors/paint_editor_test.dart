import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PaintEditor, () {
    late List<ComponentPaint> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaintEditor(
            value: const ComponentPaint(color: 0xFF112233),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    testWidgets('shows the color hex code', (tester) async {
      await pumpSubject(tester);

      expect(find.text('#FF112233'), findsOneWidget);
    });

    testWidgets('edits the style', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.text('Stroke'));

      expect(
        changes,
        equals([
          const ComponentPaint(color: 0xFF112233, style: PaintStyle.stroke),
        ]),
      );
    });

    testWidgets('opens a color picker for the color', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byType(ColorField));
      await tester.pumpAndSettle();

      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('keeps the color when the picker is cancelled', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byType(ColorField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });

    group('palette', () {
      const palette = Palette(
        colors: [
          PaletteColor(name: 'primary', color: 0xFFFF0000),
          PaletteColor(name: 'accent', color: 0xFF00FF00),
        ],
      );

      Future<void> pumpWithPalette(
        WidgetTester tester, {
        ComponentPaint value = const ComponentPaint(color: 0xFF112233),
      }) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintEditor(
              value: value,
              palette: palette,
              onChanged: changes.add,
            ),
          ),
        ),
      );

      testWidgets('has no palette button without colors', (tester) async {
        await pumpSubject(tester);

        expect(find.byTooltip('Pick from palette'), findsNothing);
      });

      testWidgets('picks a palette color', (tester) async {
        await pumpWithPalette(tester);

        await tester.tap(find.byTooltip('Pick from palette'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('accent'));
        await tester.pumpAndSettle();

        expect(
          changes,
          equals([
            const ComponentPaint(color: 0xFF00FF00, paletteColor: 'accent'),
          ]),
        );
      });

      testWidgets('shows the palette color by name, with its value', (
        tester,
      ) async {
        await pumpWithPalette(
          tester,
          value: const ComponentPaint(
            color: 0xFF112233,
            paletteColor: 'primary',
          ),
        );

        expect(find.text('primary · #FFFF0000'), findsOneWidget);

        await tester.tap(find.byTooltip('Pick from palette'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('shows the last value of a missing palette color', (
        tester,
      ) async {
        await pumpWithPalette(
          tester,
          value: const ComponentPaint(color: 0xFF112233, paletteColor: 'gone'),
        );

        expect(find.text('#FF112233'), findsOneWidget);
      });

      testWidgets('keeps the palette color when the picker is cancelled', (
        tester,
      ) async {
        await pumpWithPalette(
          tester,
          value: const ComponentPaint(
            color: 0xFF112233,
            paletteColor: 'primary',
          ),
        );

        await tester.tap(find.byType(ColorField));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(changes, isEmpty);
      });
    });
  });
}
