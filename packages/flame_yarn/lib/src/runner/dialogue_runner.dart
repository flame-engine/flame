import 'dart:async';

import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/runner/dialogue_view.dart';
import 'package:flame_yarn/src/structure/block.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_project.dart';

///
class DialogueRunner {
  DialogueRunner(this.project)
      : _dialogueViews = [],
        _currentNodes = [],
        _iterators = [];

  final YarnProject project;
  final List<DialogueView> _dialogueViews;
  final List<Node> _currentNodes;
  final List<NodeIterator> _iterators;

  Future<void> runNode(String nodeName) async {
    if (_currentNodes.isNotEmpty) {
      throw DialogueError(
        'Cannot run node "$nodeName" because another node is '
        'currently running: "${_currentNodes.last.title}"',
      );
    }
    final newNode = project.nodes[nodeName];
    if (newNode == null) {
      throw NameError('Node "$nodeName" could not be found');
    }
    _currentNodes.add(newNode);
    _iterators.add(newNode.iterator);

    while (_iterators.isNotEmpty) {
      final iterator = _iterators.last;
      if (iterator.moveNext()) {
        final nextLine = iterator.current;
        switch (nextLine.kind) {
          case StatementKind.line:
            await deliverLine(nextLine as DialogueLine);
            break;
          case StatementKind.choice:
            await deliverChoices(nextLine as DialogueChoice);
            break;
          case StatementKind.command:
            await deliverCommand(nextLine as Command);
            break;
        }
      } else {
        _iterators.removeLast();
        _currentNodes.removeLast();
      }
    }
  }

  Future<void> deliverLine(DialogueLine line) async {}

  Future<void> deliverChoices(DialogueChoice choice) async {
    final futures = [
      for (final view in _dialogueViews) view.onChoiceStart(choice)
    ];
    if (futures.every((future) => future == DialogueView.never)) {
      throw DialogueError(
        'No DialogueView capable of making a dialogue choice',
      );
    }
    final chosenIndex = await Future.any(futures);
    if (chosenIndex < 0 || chosenIndex >= choice.options.length) {
      throw DialogueError(
        'Invalid option index chosen in a dialogue: $chosenIndex',
      );
    }
    final chosenOption = choice.options[chosenIndex];
    if (!chosenOption.available) {
      throw DialogueError(
        'A dialogue view chosen an option that was not available: $chosenIndex',
      );
    }
    await combineFutures(
      [for (final view in _dialogueViews) view.onChoiceFinish(chosenOption)],
    );
  }

  FutureOr<void> deliverCommand(Command command) {
    return command.execute(this);
  }

  void enterBlock(Block block) {
    _iterators.last.diveInto(block);
  }

  Future<void> jumpToNode(String nodeName) async {
    _currentNodes.removeLast();
    _iterators.removeLast();
    return runNode(nodeName);
  }

  void stop() {
    _currentNodes.clear();
    _iterators.clear();
  }

  Future<void> combineFutures(List<FutureOr<void>> maybeFutures) {
    return Future.wait(<Future<void>>[
      for (final maybeFuture in maybeFutures)
        if (maybeFuture is Future) maybeFuture
    ]);
  }
}
