import 'dart:async';

import 'package:jenny/src/errors.dart';
import 'package:jenny/src/runner/dialogue_view.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/structure/statement.dart';
import 'package:jenny/src/yarn_project.dart';

///
class DialogueRunner {
  DialogueRunner({
    required YarnProject yarnProject,
    List<DialogueView>? dialogueViews,
  })  : project = yarnProject,
        _dialogueViews = dialogueViews ?? [],
        _currentNodes = [],
        _iterators = [];

  final YarnProject project;
  final List<DialogueView> _dialogueViews;
  final List<Node> _currentNodes;
  final List<NodeIterator> _iterators;
  _LineDeliveryPipeline? _linePipeline;

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
    await combineFutures(
      [for (final view in _dialogueViews) view.onDialogueStart()],
    );
    await combineFutures(
      [for (final view in _dialogueViews) view.onNodeStart(newNode)],
    );

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
    await combineFutures(
      [for (final view in _dialogueViews) view.onDialogueFinish()],
    );
  }

  Future<void> deliverLine(DialogueLine line) async {
    final pipeline = _LineDeliveryPipeline(line, _dialogueViews);
    _linePipeline = pipeline;
    pipeline.start();
    await pipeline.future;
    _linePipeline = null;
  }

  void interruptLine() {
    _linePipeline?.interrupt();
  }

  Future<void> deliverChoices(DialogueChoice choice) async {
    // Compute which options are available and which aren't. This must be done
    // only once, because some options may have non-deterministic conditionals
    // which may produce different results on each invocation.
    for (final option in choice.options) {
      option.available = option.condition?.value ?? true;
    }
    final futures = [
      for (final view in _dialogueViews) view.onChoiceStart(choice)
    ];
    if (futures.every((future) => future == DialogueView.never)) {
      error('No dialogue views capable of making a dialogue choice');
    }
    final chosenIndex = await Future.any(futures);
    if (chosenIndex < 0 || chosenIndex >= choice.options.length) {
      error('Invalid option index chosen in a dialogue: $chosenIndex');
    }
    final chosenOption = choice.options[chosenIndex];
    if (!chosenOption.available) {
      error('A dialogue view selected a disabled option: $chosenOption');
    }
    await combineFutures(
      [for (final view in _dialogueViews) view.onChoiceFinish(chosenOption)],
    );
    enterBlock(chosenOption.block);
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

  Never error(String message) {
    stop();
    throw DialogueError(message);
  }
}

class _LineDeliveryPipeline {
  _LineDeliveryPipeline(this.line, this.views)
      : _completer = Completer(),
        _futures = List.generate(views.length, (i) => null, growable: false);

  final DialogueLine line;
  final List<DialogueView> views;
  final List<FutureOr<void>> _futures;
  final Completer<void> _completer;
  int _numPendingFutures = 0;
  bool _interrupted = false;

  Future<void> get future => _completer.future;

  void start() {
    assert(_numPendingFutures == 0);
    for (var i = 0; i < views.length; i++) {
      final maybeFuture = views[i].onLineStart(line);
      if (maybeFuture == null) {
        continue;
      } else {
        // ignore: cast_nullable_to_non_nullable
        final future = maybeFuture as Future<void>;
        _futures[i] = future.then((_) => startCompleted(i));
        _numPendingFutures++;
      }
    }
    if (_numPendingFutures == 0) {
      finish();
    }
  }

  void interrupt() {
    _interrupted = true;
    for (var i = 0; i < views.length; i++) {
      if (_futures[i] != null) {
        _futures[i] = views[i].onLineCancel(line);
      }
    }
  }

  void finish() {
    assert(_numPendingFutures == 0);
    for (var i = 0; i < views.length; i++) {
      final maybeFuture = views[i].onLineFinish(line);
      if (maybeFuture == null) {
        continue;
      } else {
        // ignore: cast_nullable_to_non_nullable
        final future = maybeFuture as Future<void>;
        _futures[i] = future.then((_) => finishCompleted(i));
        _numPendingFutures++;
      }
    }
    if (_numPendingFutures == 0) {
      _completer.complete();
    }
  }

  void startCompleted(int i) {
    if (!_interrupted) {
      assert(_futures[i] != null);
      assert(_numPendingFutures > 0);
      _futures[i] = null;
      _numPendingFutures -= 1;
      if (_numPendingFutures == 0) {
        finish();
      }
    }
  }

  void finishCompleted(int i) {
    assert(_futures[i] != null);
    assert(_numPendingFutures > 0);
    _futures[i] = null;
    _numPendingFutures -= 1;
    if (_numPendingFutures == 0) {
      _completer.complete();
    }
  }
}
