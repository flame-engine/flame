import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flame_devtools/widgets/behavior_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({
  double tickInterval = 0,
  List<Map<String, String>> blackboard = const [],
}) {
  return {
    'hasBehaviorTree': true,
    'tickInterval': tickInterval,
    'status': 'running',
    'tree': {
      'type': 'Selector',
      'status': 'running',
      'isRunning': true,
      'children': [
        {
          'type': 'Condition',
          'name': 'is hungry?',
          'status': 'failure',
          'isRunning': false,
          'children': <Object?>[],
        },
        {
          'type': 'Task',
          'status': null,
          'isRunning': false,
          'children': <Object?>[],
        },
      ],
    },
    'blackboard': blackboard,
  };
}

void main() {
  group('BehaviorTreeSnapshot', () {
    test('is read from json', () {
      final snapshot = BehaviorTreeSnapshot.fromJson(
        _json(
          tickInterval: 0.5,
          blackboard: [
            {'key': 'health', 'value': '3'},
          ],
        ),
      );

      expect(snapshot.tickInterval, 0.5);
      expect(snapshot.status, 'running');
      expect(snapshot.root.type, 'Selector');
      expect(snapshot.root.isRunning, isTrue);
      expect(snapshot.root.children, hasLength(2));
      expect(snapshot.root.children.first.name, 'is hungry?');
      expect(snapshot.root.children.last.name, isNull);
      expect(snapshot.blackboard.single.key, 'health');
      expect(snapshot.blackboard.single.value, '3');
    });

    test('a node is running or has the status that it returned last', () {
      final snapshot = BehaviorTreeSnapshot.fromJson(_json());

      expect(snapshot.root.state, 'running');
      expect(snapshot.root.children.first.state, 'failure');
      expect(snapshot.root.children.last.state, isNull);
    });
  });

  group('BehaviorTreeView', () {
    Future<void> pumpView(
      WidgetTester tester,
      BehaviorTreeSnapshot snapshot, {
      Widget? controls,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BehaviorTreeView(snapshot: snapshot, controls: controls),
          ),
        ),
      );
    }

    testWidgets('shows the nodes, their names and states', (tester) async {
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));

      expect(find.textContaining('Selector', findRichText: true), findsOne);
      expect(find.textContaining('Condition', findRichText: true), findsOne);
      expect(find.textContaining('is hungry?', findRichText: true), findsOne);
      expect(find.textContaining('Task', findRichText: true), findsOne);
      expect(find.text('running'), findsOne);
      expect(find.text('failure'), findsOne);
      expect(find.text('idle'), findsOne);
    });

    testWidgets('makes only the nodes that are running bold', (tester) async {
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));

      FontWeight? weightOf(String type) {
        final text = tester.widget<Text>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.textSpan?.toPlainText().startsWith(type) ?? false),
          ),
        );
        final spans = (text.textSpan! as TextSpan).children!;
        return (spans.first as TextSpan).style!.fontWeight;
      }

      expect(weightOf('Selector'), FontWeight.bold);
      expect(weightOf('Condition'), FontWeight.normal);
      expect(weightOf('Task'), FontWeight.normal);
    });

    testWidgets('only says how often the tree is ticked if it is slower', (
      tester,
    ) async {
      // Ticking on every update is what is expected, so it is not mentioned.
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));
      expect(find.textContaining('Ticked'), findsNothing);

      await pumpView(
        tester,
        BehaviorTreeSnapshot.fromJson(_json(tickInterval: 0.5)),
      );
      expect(find.text('Ticked every 0.5s'), findsOne);
    });

    testWidgets('shows the values on the blackboard', (tester) async {
      await pumpView(
        tester,
        BehaviorTreeSnapshot.fromJson(
          _json(
            blackboard: [
              {'key': 'health', 'value': '3'},
              {'key': 'name', 'value': 'Dash'},
            ],
          ),
        ),
      );

      expect(find.text('Blackboard'), findsOne);
      expect(find.text('No values are set'), findsNothing);
      expect(find.textContaining('health: 3', findRichText: true), findsOne);
      expect(find.textContaining('name: Dash', findRichText: true), findsOne);
    });

    testWidgets('says that the blackboard is empty', (tester) async {
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));

      expect(find.text('Blackboard'), findsOne);
      expect(find.text('No values are set'), findsOne);
    });

    group('layout', () {
      Future<void> pumpWithWidth(WidgetTester tester, double width) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await pumpView(
          tester,
          BehaviorTreeSnapshot.fromJson(_json()),
          controls: const Text('the controls'),
        );
      }

      testWidgets('aligns the blackboard with the tree when wide', (
        tester,
      ) async {
        await pumpWithWidth(tester, 900);

        final tree = tester.getTopLeft(find.text('Behavior tree'));
        final blackboard = tester.getTopLeft(find.text('Blackboard'));
        expect(blackboard.dx, greaterThan(tree.dx + 200));
        // The headings are on the same line, although only the blackboard
        // has the controls next to it.
        expect(blackboard.dy, tree.dy);
      });

      testWidgets('puts the controls at the end of the blackboard heading', (
        tester,
      ) async {
        await pumpWithWidth(tester, 900);

        final blackboard = tester.getTopLeft(find.text('Blackboard'));
        final controls = tester.getTopLeft(find.text('the controls'));
        expect(controls.dx, greaterThan(blackboard.dx + 100));
        expect(controls.dy, closeTo(blackboard.dy, 10));
      });

      testWidgets('puts the blackboard below the tree when narrow', (
        tester,
      ) async {
        await pumpWithWidth(tester, 400);

        final tree = tester.getTopLeft(find.text('Behavior tree'));
        final blackboard = tester.getTopLeft(find.text('Blackboard'));
        expect(blackboard.dx, tree.dx);
        expect(blackboard.dy, greaterThan(tree.dy + 100));
      });

      testWidgets('puts the controls at the end of the tree heading when '
          'narrow', (tester) async {
        await pumpWithWidth(tester, 400);

        final tree = tester.getTopLeft(find.text('Behavior tree'));
        final controls = tester.getTopLeft(find.text('the controls'));
        expect(controls.dx, greaterThan(tree.dx + 100));
        expect(controls.dy, closeTo(tree.dy, 10));
      });
    });
  });
}
