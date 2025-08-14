import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terminui/terminui.dart';

/// A Console like view that can be used to interact with a game.
///
/// It should be registered as an overlay in the game widget
/// of the game you want to interact with.
///
/// Example:
///
/// ```dart
/// GameWidget(
///   game: _game,
///   overlayBuilderMap: {
///     'console': (BuildContext context, MyGame game) => ConsoleView(
///       game: game,
///       onClose: () {
///         _game.overlays.remove('console');
///       },
///     ),
///   },
/// )
class FlameConsoleView<G extends FlameGame> extends StatefulWidget {
  const FlameConsoleView({
    required this.game,
    required this.onClose,
    this.customCommands,
    this.repository,
    this.containerBuilder,
    this.cursorBuilder,
    this.cursorColor,
    this.historyBuilder,
    this.textStyle,
    super.key,
  });

  final G game;
  final List<FlameConsoleCommand<G>>? customCommands;
  final VoidCallback onClose;
  final TerminuiRepository? repository;

  final ContainerBuilder? containerBuilder;
  final WidgetBuilder? cursorBuilder;
  final HistoryBuilder? historyBuilder;

  final Color? cursorColor;
  final TextStyle? textStyle;

  @override
  State<FlameConsoleView> createState() => _ConsoleViewState();
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

class _ConsoleViewState extends State<FlameConsoleView> {
  late final List<FlameConsoleCommand> _commandList = [
    ...FlameConsoleCommands.commands,
    if (widget.customCommands != null) ...widget.customCommands!,
  ];

  late final repository = widget.repository ?? MemoryTerminuiRepository();

  late final _keyboardEventEmitter = KeyboardEventEmitter();

  late final KeyboardHandler _keyboardHandler;

  @override
  void initState() {
    super.initState();

    widget.game.add(
      _keyboardHandler = _ConsoleKeyboardHandler(
        _keyboardEventEmitter.emit,
      ),
    );
  }

  @override
  void dispose() {
    _keyboardHandler.removeFromParent();
    _keyboardEventEmitter.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TerminuiView(
      onClose: widget.onClose,
      commands: _commandList,
      subject: widget.game,
      keyboardEventEmitter: _keyboardEventEmitter,
      containerBuilder: widget.containerBuilder,
      cursorBuilder: widget.cursorBuilder,
      cursorColor: widget.cursorColor,
      historyBuilder: widget.historyBuilder,
      textStyle: widget.textStyle,
    );
  }
}
