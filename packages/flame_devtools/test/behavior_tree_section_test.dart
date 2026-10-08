import 'dart:async';

import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flame_devtools/widgets/behavior_tree_section.dart';
import 'package:flame_devtools/widgets/behavior_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BehaviorTreeSnapshot _snapshot(String rootType) {
  return BehaviorTreeSnapshot.fromJson({
    'tickInterval': 0.0,
    'status': null,
    'tree': {
      'type': rootType,
      'status': null,
      'isRunning': false,
      'children': <Object?>[],
    },
    'blackboard': <Object?>[],
  });
}

/// Fakes the requests for behavior trees, which are completed by the test.
class _FakeFetch() {
  final calls = <(int, Completer<BehaviorTreeSnapshot?>)>[];

  Future<BehaviorTreeSnapshot?> call(int id) {
    final completer = Completer<BehaviorTreeSnapshot?>();
    calls.add((id, completer));
    return completer.future;
  }

  List<int> get ids => [for (final (id, _) in calls) id];

  void complete(int call, BehaviorTreeSnapshot? snapshot) {
    calls[call].$2.complete(snapshot);
  }
}

void main() {
  group('BehaviorTreeSection', () {
    Future<void> pumpSection(
      WidgetTester tester,
      _FakeFetch fetch, {
      required int id,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BehaviorTreeSection(id: id, fetch: fetch.call),
          ),
        ),
      );
    }

    // Lets what was waiting for a request continue. That takes more than one
    // frame, because the section awaits the request in an async function.
    Future<void> flush(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
    }

    // Removes the section, which stops the timer that refreshes it.
    Future<void> removeSection(WidgetTester tester) {
      return tester.pumpWidget(const SizedBox());
    }

    testWidgets('shows the tree that was fetched', (tester) async {
      final fetch = _FakeFetch();
      await pumpSection(tester, fetch, id: 1);
      expect(find.byType(BehaviorTreeView), findsNothing);

      fetch.complete(0, _snapshot('Selector'));
      await flush(tester);

      expect(find.textContaining('Selector', findRichText: true), findsOne);
      await removeSection(tester);
    });

    testWidgets('shows nothing for a component without a tree', (
      tester,
    ) async {
      final fetch = _FakeFetch();
      await pumpSection(tester, fetch, id: 1);

      fetch.complete(0, null);
      await flush(tester);

      expect(find.byType(BehaviorTreeView), findsNothing);
      await removeSection(tester);
    });

    testWidgets('refreshes while it is live', (tester) async {
      final fetch = _FakeFetch();
      await pumpSection(tester, fetch, id: 1);
      fetch.complete(0, _snapshot('Selector'));
      await flush(tester);

      await tester.pump(const Duration(milliseconds: 500));
      expect(fetch.ids, [1, 1]);

      fetch.complete(1, _snapshot('Sequence'));
      await flush(tester);
      expect(find.textContaining('Sequence', findRichText: true), findsOne);
      await removeSection(tester);
    });

    testWidgets('does not show the tree of the previous component', (
      tester,
    ) async {
      final fetch = _FakeFetch();
      await pumpSection(tester, fetch, id: 1);
      fetch.complete(0, _snapshot('Selector'));
      await flush(tester);
      expect(find.textContaining('Selector', findRichText: true), findsOne);

      await pumpSection(tester, fetch, id: 2);

      expect(find.byType(BehaviorTreeView), findsNothing);
      await removeSection(tester);
    });

    testWidgets(
      'loads the tree of the new component when the selection changes while '
      'a refresh is in flight, also if it is not live',
      (tester) async {
        final fetch = _FakeFetch();
        await pumpSection(tester, fetch, id: 1);
        fetch.complete(0, _snapshot('Selector'));
        await flush(tester);

        // Stop the live updates, so that nothing else asks for a refresh.
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // A refresh of the first component is in flight.
        await tester.tap(find.byTooltip('Refresh'));
        await tester.pump();
        expect(fetch.ids, [1, 1]);

        // Select another component while that is the case. Its refresh can not
        // start, because there is one running already.
        await pumpSection(tester, fetch, id: 2);
        expect(fetch.ids, [1, 1]);

        // What the running refresh fetched is for the first component, and is
        // not shown. The tree of the new component has to be fetched then.
        fetch.complete(1, _snapshot('Selector'));
        await flush(tester);
        expect(find.byType(BehaviorTreeView), findsNothing);
        expect(fetch.ids, [1, 1, 2]);

        fetch.complete(2, _snapshot('Sequence'));
        await flush(tester);
        expect(find.textContaining('Sequence', findRichText: true), findsOne);
        expect(
          find.textContaining('Selector', findRichText: true),
          findsNothing,
        );
        await removeSection(tester);
      },
    );
  });
}
