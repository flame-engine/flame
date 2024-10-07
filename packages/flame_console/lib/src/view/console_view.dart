import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_console/src/view/container_builder.dart';
import 'package:flame_console/src/view/cursor_builder.dart';
import 'package:flame_console/src/view/history_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef HistoryBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
  Widget child,
);

typedef ContainerBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

class ConsoleView extends StatefulWidget {
  const ConsoleView({
    required this.game,
    required this.onClose,
    ConsoleRepository? repository,
    this.containerBuilder,
    this.cursorBuilder,
    this.cursorColor,
    this.historyBuilder,
    this.textStyle,
    super.key,
  }) : repository = repository ?? const MemoryConsoleRepository();

  final FlameGame game;
  final VoidCallback onClose;
  final ConsoleRepository repository;

  final ContainerBuilder? containerBuilder;
  final WidgetBuilder? cursorBuilder;
  final HistoryBuilder? historyBuilder;

  final Color? cursorColor;
  final TextStyle? textStyle;

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleKeyboardHandler extends Component with KeyboardHandler {
  _ConsoleKeyboardHandler(this._onKeyEvent);

  final void Function(KeyEvent) _onKeyEvent;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _onKeyEvent(event);
    return false;
  }
}

class _ConsoleViewState extends State<ConsoleView> {
  bool _showHistory = false;
  int _commandHistoryIndex = 0;
  List<String> _commandHistory = [];
  List<String> _history = [];
  String _cmd = '';

  late final _scrollController = ScrollController();
  late final KeyboardHandler _keyboardHandler;

  @override
  void initState() {
    super.initState();

    //widget.game.addKeyListener(_handleKeyEvent);
    widget.game.add(
      _keyboardHandler = _ConsoleKeyboardHandler(
        _handleKeyEvent,
      ),
    );

    widget.repository.listCommandHistory().then((value) {
      _commandHistory = value;
    });
  }

  @override
  void dispose() {
    _keyboardHandler.removeFromParent();

    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }
    final char = event.character;

    if (event.logicalKey == LogicalKeyboardKey.escape && !_showHistory) {
      widget.onClose();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        !_showHistory) {
      setState(() {
        _showHistory = true;
        _commandHistoryIndex = _commandHistory.length - 1;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter && _showHistory) {
      setState(() {
        _cmd = _commandHistory[_commandHistoryIndex];
        _showHistory = false;
      });
    } else if ((event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.arrowDown) &&
        _showHistory) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _commandHistoryIndex =
              (_commandHistoryIndex - 1).clamp(0, _commandHistory.length - 1);
        } else {
          _commandHistoryIndex =
              (_commandHistoryIndex + 1).clamp(0, _commandHistory.length - 1);
        }
      });
    } else if (event.logicalKey == LogicalKeyboardKey.escape && _showHistory) {
      setState(() {
        _showHistory = false;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter && !_showHistory) {
      final split = _cmd.split(' ');

      if (split.isEmpty) {
        return;
      }

      if (split.first == 'clear') {
        setState(() {
          _history = [];
          _cmd = '';
        });
        return;
      }

      final originalCommand = _cmd;
      setState(() {
        _history = [..._history, _cmd];
        _cmd = '';
      });

      final command = ConsoleCommands.commands[split.first];

      if (command == null) {
        setState(() {
          _history = [..._history, 'Command not found'];
        });
      } else {
        widget.repository.addToCommandHistory(originalCommand);
        _commandHistory = [..._commandHistory, originalCommand];
        final result = command.run(widget.game, split.skip(1).toList());
        setState(() {
          _history = [..._history, ...result.$2.split('\n')];
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      setState(() {
        _cmd = _cmd.substring(0, _cmd.length - 1);
      });
    } else if (char != null) {
      setState(() {
        _cmd += event.character ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursorColor = widget.cursorColor ?? Colors.white;

    final textStyle = widget.textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            );

    final historyBuilder = widget.historyBuilder ?? defaultHistoryBuilder;
    final containerBuilder = widget.containerBuilder ?? defaultContainerBuilder;
    final cursorBuilder = widget.cursorBuilder ?? defaultCursorBuilder;

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 48,
            child: containerBuilder(
              context,
              historyBuilder(
                context,
                _scrollController,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in _history)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(line, style: textStyle),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_showHistory)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: containerBuilder(
                context,
                SizedBox(
                  height: 168,
                  child: Column(
                    verticalDirection: VerticalDirection.up,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_commandHistory.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('No history', style: textStyle),
                        ),
                      for (var i = _commandHistoryIndex;
                          i >= 0 && i >= _commandHistoryIndex - 5;
                          i--)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ColoredBox(
                            color: i == _commandHistoryIndex
                                ? cursorColor.withOpacity(.5)
                                : Colors.transparent,
                            child: Text(
                              _commandHistory[i],
                              style: textStyle?.copyWith(
                                color: i == _commandHistoryIndex
                                    ? cursorColor
                                    : textStyle.color,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: containerBuilder(
              context,
              Row(
                children: [
                  Text(_cmd, style: textStyle),
                  SizedBox(width: (textStyle?.fontSize ?? 12) / 4),
                  cursorBuilder(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
