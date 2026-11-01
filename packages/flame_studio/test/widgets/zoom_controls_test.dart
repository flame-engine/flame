import 'package:flame_studio/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ZoomControls, () {
    Future<void> pump(
      WidgetTester tester, {
      double zoom = 1,
      VoidCallback? onZoomIn,
      VoidCallback? onZoomOut,
      VoidCallback? onReset,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomControls(
              zoom: zoom,
              onZoomIn: onZoomIn,
              onZoomOut: onZoomOut,
              onReset: onReset,
            ),
          ),
        ),
      );
    }

    testWidgets('shows the zoom as a percentage', (tester) async {
      await pump(tester, zoom: 0.25);

      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('calls the callbacks', (tester) async {
      final calls = <String>[];
      await pump(
        tester,
        onZoomIn: () => calls.add('in'),
        onZoomOut: () => calls.add('out'),
        onReset: () => calls.add('reset'),
      );

      await tester.tap(find.byTooltip('Zoom in'));
      await tester.tap(find.byTooltip('Zoom out'));
      await tester.tap(find.text('100%'));

      expect(calls, equals(['in', 'out', 'reset']));
    });

    testWidgets('disables the buttons without callbacks', (tester) async {
      await pump(tester);

      for (final tooltip in ['Zoom in', 'Zoom out']) {
        final button = tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );
        expect(button.onPressed, isNull);
      }
    });
  });

  group('zoomShortcuts', () {
    testWidgets('binds Cmd and Ctrl with =, +, - and 0', (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(
        CallbackShortcuts(
          bindings: zoomShortcuts(
            onZoomIn: () => calls.add('in'),
            onZoomOut: () => calls.add('out'),
            onReset: () => calls.add('reset'),
          ),
          child: const Focus(autofocus: true, child: SizedBox()),
        ),
      );

      for (final modifier in [
        LogicalKeyboardKey.metaLeft,
        LogicalKeyboardKey.controlLeft,
      ]) {
        await tester.sendKeyDownEvent(modifier);
        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
        await tester.sendKeyUpEvent(modifier);
      }

      expect(
        calls,
        equals(['in', 'out', 'reset', 'in', 'in', 'out', 'reset', 'in']),
      );
    });
  });
}
