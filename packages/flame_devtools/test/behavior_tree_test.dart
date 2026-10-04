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
    Future<void> pumpView(WidgetTester tester, BehaviorTreeSnapshot snapshot) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BehaviorTreeView(snapshot: snapshot)),
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

    testWidgets('says how often the tree is ticked', (tester) async {
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));
      expect(find.text('Ticked on every update'), findsOne);

      await pumpView(
        tester,
        BehaviorTreeSnapshot.fromJson(_json(tickInterval: 0.5)),
      );
      expect(find.text('Ticked every 0.5s'), findsOne);
    });

    testWidgets('shows the blackboard if it has values', (tester) async {
      await pumpView(tester, BehaviorTreeSnapshot.fromJson(_json()));
      expect(find.text('Blackboard'), findsNothing);

      await pumpView(
        tester,
        BehaviorTreeSnapshot.fromJson(
          _json(
            blackboard: [
              {'key': 'health', 'value': '3'},
            ],
          ),
        ),
      );
      expect(find.text('Blackboard'), findsOne);
      expect(find.text('health: 3'), findsOne);
    });
  });
}
