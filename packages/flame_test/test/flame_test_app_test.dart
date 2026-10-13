import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameTestApp', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        const FlameTestApp(child: Text('hello')),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('provides the app-level inherited widgets', (tester) async {
      late BuildContext childContext;
      await tester.pumpWidget(
        FlameTestApp(
          child: Builder(
            builder: (context) {
              childContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(MediaQuery.maybeOf(childContext), isNotNull);
      expect(Directionality.maybeOf(childContext), isNotNull);
    });

    testWidgets('does not show the debug banner', (tester) async {
      await tester.pumpWidget(
        const FlameTestApp(child: SizedBox()),
      );

      expect(find.byType(CheckedModeBanner), findsNothing);
    });
  });
}
