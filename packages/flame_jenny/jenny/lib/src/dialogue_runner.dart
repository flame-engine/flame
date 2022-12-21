import 'dart:async';

import 'package:jenny/src/dialogue_view.dart';
import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:meta/meta.dart';

/// [DialogueRunner] is a an engine in flame_yarn that runs a single dialogue.
///
/// If you think of [YarnProject] as a dialogue "program", consisting of
/// multiple Nodes as "functions", then [DialogueRunner] is like a VM, capable
/// of executing a single "function" in that "program".
///
/// A single [DialogueRunner] may only execute one dialogue Node at a time. It
/// is an error to try to run another Node before the first one concludes.
/// However, it is possible to create multiple [DialogueRunner]s for the same
/// [YarnProject], and then they would be able to execute multiple dialogues at
/// once (for example, in a crowded room there could be multiple dialogues
/// occurring at once within different groups of people).
///
/// The job of a [DialogueRunner] is to fetch the dialogue lines in the correct
/// order, and at the appropriate pace, to execute the logic in dialogue
/// scripts, and to branch according to user input in [DialogueChoice]s. The
/// output of a [DialogueRunner], therefore, is a stream of dialogue statements
/// that need to be presented to the player. Such presentation, however, is
/// handled by the [DialogueView]s, not by the [DialogueRunner].
class DialogueRunner {
  DialogueRunner({
    required YarnProject yarnProject,
    required List<DialogueView> dialogueViews,
  })  : project = yarnProject,
        _dialogueViews = dialogueViews;

  final YarnProject project;
  final List<DialogueView> _dialogueViews;
  _LineDeliveryPipeline? _linePipeline;
  Node? _currentNode;
  NodeIterator? _currentIterator;
  String? _initialNodeName;
  String? _nextNode;

  /// Starts the dialogue with the node [nodeName], and returns a future that
  /// finishes once the dialogue stops running.
  Future<void> startDialogue(String nodeName) async {
    try {
      if (_initialNodeName != null) {
        throw DialogueError(
          'Cannot run node "$nodeName" because another node is '
          'currently running: "$_initialNodeName"',
        );
      }
      _initialNodeName = nodeName;
      _dialogueViews.forEach((view) {
        if (view.dialogueRunner != null) {
          throw DialogueError(
            'DialogueView is currently attached to another DialogueRunner',
          );
        }
        view.dialogueRunner = this;
      });
      await _event((view) => view.onDialogueStart());
      _nextNode = nodeName;
      while (_nextNode != null) {
        await _runNode(_nextNode!);
      }
      await _event((view) => view.onDialogueFinish());
    } finally {
      _dialogueViews.forEach((dv) => dv.dialogueRunner = null);
      _initialNodeName = null;
      _nextNode = null;
      _currentIterator = null;
      _currentNode = null;
    }
  }

  void sendSignal(dynamic signal) {
    assert(_linePipeline != null);
    final line = _linePipeline!.line;
    for (final view in _dialogueViews) {
      view.onLineSignal(line, signal);
    }
  }

  void stopLine() {
    _linePipeline?.stop();
  }

  Future<void> _runNode(String nodeName) async {
    final node = project.nodes[nodeName];
    if (node == null) {
      throw NameError('Node "$nodeName" could not be found');
    }

    _nextNode = null;
    _currentNode = node;
    _currentIterator = node.iterator;

    await _event((view) => view.onNodeStart(node));
    while (_currentIterator?.moveNext() ?? false) {
      final entry = _currentIterator!.current;
      await entry.processInDialogueRunner(this);
    }
    _incrementNodeVisitCount();
    await _event((view) => view.onNodeFinish(node));

    _currentNode = null;
    _currentIterator = null;
  }

  void _incrementNodeVisitCount() {
    final nodeVariable = '@${_currentNode!.title}';
    project.variables.setVariable(
      nodeVariable,
      project.variables.getNumericValue(nodeVariable) + 1,
    );
  }

  @internal
  Future<void> deliverLine(DialogueLine line) async {
    final pipeline = _LineDeliveryPipeline(line, _dialogueViews);
    _linePipeline = pipeline;
    pipeline.start();
    await pipeline.future;
    _linePipeline = null;
  }

  @internal
  Future<void> deliverChoices(DialogueChoice choice) async {
    final futures = [
      for (final view in _dialogueViews) view.onChoiceStart(choice)
    ];
    if (futures.every((future) => future == DialogueView.never)) {
      throw DialogueError(
        'No dialogue views capable of making a dialogue choice',
      );
    }
    final chosenIndex = await Future.any(futures);
    if (chosenIndex < 0 || chosenIndex >= choice.options.length) {
      throw DialogueError(
        'Invalid option index chosen in a dialogue: $chosenIndex',
      );
    }
    final chosenOption = choice.options[chosenIndex];
    if (!chosenOption.isAvailable) {
      throw DialogueError(
        'A dialogue view selected a disabled option: $chosenOption',
      );
    }
    await _event((view) => view.onChoiceFinish(chosenOption));
    enterBlock(chosenOption.block);
  }

  @internal
  Future<void> deliverCommand(Command command) async {
    await _combineFutures([
      command.execute(this),
      if (command is UserDefinedCommand)
        for (final view in _dialogueViews) view.onCommand(command)
    ]);
  }

  @internal
  void enterBlock(Block block) {
    _currentIterator!.diveInto(block);
  }

  /// Stops the current node, and then starts running [nodeName]. If [nodeName]
  /// is null, then stops the dialogue completely.
  ///
  /// This command is synchronous, i.e. it does not wait for the node to
  /// *actually* finish (which calls the `onNodeFinish` callback).
  @internal
  void jumpToNode(String? nodeName) {
    _currentIterator = null;
    _nextNode = nodeName;
  }

  /// Similar to `Future.wait()`, but accepts `FutureOr`s.
  FutureOr<void> _combineFutures(List<FutureOr<void>> maybeFutures) {
    final futures = maybeFutures.whereType<Future<void>>().toList();
    if (futures.isNotEmpty) {
      if (futures.length == 1) {
        return futures[0];
      } else {
        final Future<void> result = Future.wait(futures);
        return result;
      }
    }
  }

  FutureOr<void> _event(FutureOr<void> Function(DialogueView) callback) {
    return _combineFutures([for (final view in _dialogueViews) callback(view)]);
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
      if (maybeFuture is Future) {
        // ignore: cast_nullable_to_non_nullable
        final future = maybeFuture as Future<bool>;
        _futures[i] = future.then((_) => startCompleted(i));
        _numPendingFutures++;
      } else {
        continue;
      }
    }
    if (_numPendingFutures == 0) {
      finish();
    }
  }

  void stop() {
    _interrupted = true;
    for (var i = 0; i < views.length; i++) {
      if (_futures[i] != null) {
        final newFuture = views[i].onLineStop(line);
        _futures[i] = newFuture;
        if (newFuture == null) {
          _numPendingFutures -= 1;
        }
      }
    }
    if (_numPendingFutures == 0) {
      finish();
    }
  }

  void finish() {
    assert(_numPendingFutures == 0);
    for (var i = 0; i < views.length; i++) {
      final maybeFuture = views[i].onLineFinish(line);
      if (maybeFuture is Future) {
        // ignore: unnecessary_cast
        final future = maybeFuture as Future<void>;
        _futures[i] = future.then((_) => finishCompleted(i));
        _numPendingFutures++;
      } else {
        continue;
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
