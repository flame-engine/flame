import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConsoleState {
  const ConsoleState({
    this.showHistory = false,
    this.commandHistoryIndex = 0,
    this.commandHistory = const [],
    this.history = const [],
    this.cmd = '',
  });

  final bool showHistory;
  final int commandHistoryIndex;
  final List<String> commandHistory;
  final List<String> history;
  final String cmd;

  ConsoleState copyWith({
    bool? showHistory,
    int? commandHistoryIndex,
    List<String>? commandHistory,
    List<String>? history,
    String? cmd,
  }) {
    return ConsoleState(
      showHistory: showHistory ?? this.showHistory,
      commandHistoryIndex: commandHistoryIndex ?? this.commandHistoryIndex,
      commandHistory: commandHistory ?? this.commandHistory,
      history: history ?? this.history,
      cmd: cmd ?? this.cmd,
    );
  }
}

class ConsoleController<G extends FlameGame> {
  ConsoleController({
    required this.repository,
    required this.game,
    required this.scrollController,
    required this.onClose,
    ConsoleState state = const ConsoleState(),
  }) : state = ValueNotifier(state);

  final ValueNotifier<ConsoleState> state;
  final ConsoleRepository repository;
  final G game;
  final VoidCallback onClose;
  final ScrollController scrollController;

  Future<void> init() async {
    final history = await repository.listCommandHistory();
    state.value = state.value.copyWith(history: history);
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }
    final char = event.character;

    if (event.logicalKey == LogicalKeyboardKey.escape &&
        !state.value.showHistory) {
      onClose();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        !state.value.showHistory) {
      final newState = state.value.copyWith(
        showHistory: true,
        commandHistoryIndex: state.value.commandHistory.length - 1,
      );
      state.value = newState;
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        state.value.showHistory) {
      final newState = state.value.copyWith(
        cmd: state.value.commandHistory[state.value.commandHistoryIndex],
        showHistory: false,
      );
      state.value = newState;
    } else if ((event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.arrowDown) &&
        state.value.showHistory) {
      final newState = state.value.copyWith(
        commandHistoryIndex: event.logicalKey == LogicalKeyboardKey.arrowUp
            ? (state.value.commandHistoryIndex - 1)
                .clamp(0, state.value.commandHistory.length - 1)
            : (state.value.commandHistoryIndex + 1)
                .clamp(0, state.value.commandHistory.length - 1),
      );
      state.value = newState;
    } else if (event.logicalKey == LogicalKeyboardKey.escape &&
        state.value.showHistory) {
      state.value = state.value.copyWith(
        showHistory: false,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        !state.value.showHistory) {
      final split = state.value.cmd.split(' ');

      if (split.isEmpty) {
        return;
      }

      if (split.first == 'clear') {
        state.value = state.value.copyWith(
          history: [],
          cmd: '',
        );
        return;
      }

      final originalCommand = state.value.cmd;
      state.value = state.value.copyWith(
        history: [...state.value.history, state.value.cmd],
        cmd: '',
      );

      final command = ConsoleCommands.commands[split.first];

      if (command == null) {
        state.value = state.value.copyWith(
          history: [...state.value.history, 'Command not found'],
        );
      } else {
        repository.addToCommandHistory(originalCommand);
        state.value = state.value.copyWith(
          commandHistory: [...state.value.commandHistory, originalCommand],
        );
        final result = command.run(game, split.skip(1).toList());
        state.value = state.value.copyWith(
          history: [...state.value.history, ...result.$2.split('\n')],
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      state.value = state.value.copyWith(
        cmd: state.value.cmd.substring(0, state.value.cmd.length - 1),
      );
    } else if (char != null) {
      state.value = state.value.copyWith(
        cmd: state.value.cmd + char,
      );
    }
  }
}
