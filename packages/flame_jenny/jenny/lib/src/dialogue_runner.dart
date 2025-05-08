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

/// The **DialogueRunner** is the engine that executes Jenny's dialogue at
/// runtime.
///
/// If you imagine [YarnProject] as a "program", consisting of multiple [Node]s
/// as "functions", then `DialogueRunner` is a virtual machine, capable of
/// executing a single "function" in that "program".
///
/// A single `DialogueRunner` may only execute one dialogue node at a time. It
/// is an error to try to run another node before the first one concludes.
/// However, it is possible to create multiple `DialogueRunner`s for the same
/// [YarnProject], and then they would be able to execute multiple dialogues
/// simultaneously (for example, in a crowded room there could be multiple
/// dialogues occurring at once within different groups of people).
///
/// The job of a `DialogueRunner` is to fetch the dialogue lines in the correct
/// order and at the appropriate pace, to execute the logic in dialogue
/// scripts, and to branch according to user input in [DialogueChoice]s. The
/// output of a `DialogueRunner`, therefore, is a stream of dialogue statements
/// that need to be presented to the player. Such presentation, is handled by
/// [DialogueView]s.
class DialogueRunner {
  /// Creates a `DialogueRunner` for executing the [yarnProject]. The dialogue
  /// will be delivered to all the provided [dialogueViews]. Each of these
  /// dialogue views may only be assigned to a single `DialogueRunner` at a
  /// time.
  DialogueRunner({
    required YarnProject yarnProject,
    required List<DialogueView> dialogueViews,
  })  : project = yarnProject,
        _dialogueViews = dialogueViews;

  final List<DialogueView> _dialogueViews;
  _LineDeliveryPipeline? _linePipeline;
  Node? _currentNode;
  NodeIterator? _currentIterator;
  String? _initialNodeName;
  String? _nextNode;

  /// The `YarnProject` that this dialogue runner is executing.
  final YarnProject project;

  /// Starts the dialogue with the node [nodeName], and returns a future that
  /// completes once the dialogue finishes running. While this future is
  /// pending, the `DialogueRunner` cannot start any other dialogue.
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
      await _runNode(nodeName);
      await _event((view) => view.onDialogueFinish());
    } finally {
      _dialogueViews.forEach((dv) => dv.dialogueRunner = null);
      _initialNodeName = null;
      _nextNode = null;
      _currentIterator = null;
      _currentNode = null;
    }
  }

  /// Delivers the given [signal] to all dialogue views, in the form of a
  /// [DialogueView] method `onLineSignal(line, signal)`. This can be used, for
  /// example, as a means of communication between the dialogue views.
  ///
  /// The [signal] object here is completely arbitrary, and it is up to the
  /// implementations to decide which signals to send and to receive.
  /// Implementations should ignore any signals they do not understand.
  void sendSignal(dynamic signal) {
    assert(_linePipeline != null);
    final line = _linePipeline!.line;
    for (final view in _dialogueViews) {
      view.onLineSignal(line, signal);
    }
  }

  /// Requests (via `onLineStop()`) that the presentation of the current line
  /// be finished as quickly as possible. The dialogue will then proceed
  /// normally to the next line.
  void stopLine() {
    _linePipeline?.stop();
  }

  Future<void> _runNode(String nodeName) async {
    _nextNode = nodeName;
    while (_nextNode != null) {
      final node = project.nodes[_nextNode!];
      if (node == null) {
        throw NameError('Node "$_nextNode" could not be found');
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
    final futures = <Future<int?>>[];
    final choices = <int>[];
    for (final view in _dialogueViews) {
      final futureOrResult = view.onChoiceStart(choice);
      if (futureOrResult != null) {
        if (futureOrResult is int) {
          choices.add(futureOrResult);
        } else {
          // ignore: cast_nullable_to_non_nullable
          futures.add(futureOrResult as Future<int?>);
        }
      }
    }
    for (final future in futures) {
      final choice = await future;
      if (choice != null) {
        choices.add(choice);
      }
    }

    if (choices.isEmpty) {
      throw DialogueError('No option selected in a DialogueChoice');
    }
    final chosenIndex = choices.first;
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
      // Start execution of commands
      command.execute(this),
      // Call [onCommand] for all the views registered with this runner
      // so they can be notified that execution of the command has started.
      if (command is UserDefinedCommand)
        for (final view in _dialogueViews) view.onCommand(command),
    ]);
    // The thing we actually want to wait for is the result of
    // [command.execute(this)]. It also makes sense to wait until all
    // [onCommand] invocations are complete because conceptually,
    // [onCommand] should always precede [onCommandFinish].
    if (command is UserDefinedCommand) {
      await _combineFutures([
        for (final view in _dialogueViews) view.onCommandFinish(command),
      ]);
    }
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

  @internal
  Future<void> visitNode(String nodeName) async {
    final node = _currentNode;
    final iterator = _currentIterator;
    await _runNode(nodeName);
    _currentNode = node;
    _currentIterator = iterator;
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
