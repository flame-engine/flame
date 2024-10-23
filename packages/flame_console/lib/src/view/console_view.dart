import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_console/src/controller.dart';
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

class ConsoleView<G extends FlameGame> extends StatefulWidget {
  const ConsoleView({
    required this.game,
    required this.onClose,
    this.customCommands,
    ConsoleRepository? repository,
    this.containerBuilder,
    this.cursorBuilder,
    this.cursorColor,
    this.historyBuilder,
    this.textStyle,
    @visibleForTesting this.controller,
    super.key,
  }) : repository = repository ?? const MemoryConsoleRepository();

  final G game;
  final List<ConsoleCommand<G>>? customCommands;
  final VoidCallback onClose;
  final ConsoleRepository repository;
  final ConsoleController? controller;

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
  late final List<ConsoleCommand> _commandList = [
    ...ConsoleCommands.commands,
    if (widget.customCommands != null) ...widget.customCommands!,
  ];

  late final Map<String, ConsoleCommand> _commandsMap = {
    for (final command in _commandList) command.name: command,
  };

  late final _controller = widget.controller ??
      ConsoleController(
        repository: widget.repository,
        game: widget.game,
        scrollController: _scrollController,
        onClose: widget.onClose,
        commands: _commandsMap,
      );

  late final _scrollController = ScrollController();
  late final KeyboardHandler _keyboardHandler;

  @override
  void initState() {
    super.initState();

    widget.game.add(
      _keyboardHandler = _ConsoleKeyboardHandler(
        _controller.handleKeyEvent,
      ),
    );

    _controller.init();
  }

  @override
  void dispose() {
    _keyboardHandler.removeFromParent();
    _scrollController.dispose();

    super.dispose();
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

    return ValueListenableBuilder(
      valueListenable: _controller.state,
      builder: (context, state, _) {
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
                        for (final line in state.history)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(line, style: textStyle),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.showHistory)
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
                          if (state.commandHistory.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('No history', style: textStyle),
                            ),
                          for (var i = state.commandHistoryIndex;
                              i >= 0 && i >= state.commandHistoryIndex - 5;
                              i--)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ColoredBox(
                                color: i == state.commandHistoryIndex
                                    ? cursorColor.withOpacity(.5)
                                    : Colors.transparent,
                                child: Text(
                                  state.commandHistory[i],
                                  style: textStyle?.copyWith(
                                    color: i == state.commandHistoryIndex
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
                      Text(state.cmd, style: textStyle),
                      SizedBox(width: (textStyle?.fontSize ?? 12) / 4),
                      cursorBuilder(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
