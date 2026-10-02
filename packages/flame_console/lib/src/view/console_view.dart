import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
class const FlameConsoleView<G extends FlameGame>({
  required final G game,
  required final VoidCallback onClose,
  final List<FlameConsoleCommand<G>>? customCommands,
  final TerminuiRepository? repository,
  final ContainerBuilder? containerBuilder,
  final WidgetBuilder? cursorBuilder,
  final Color? cursorColor,
  final HistoryBuilder? historyBuilder,
  final TextStyle? textStyle,
  super.key,
}) extends StatefulWidget {
  @override
  State<FlameConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleKeyboardHandler(
  final KeyEventResult Function(KeyEvent, Set<LogicalKeyboardKey>) _onKeyEvent,
) extends Component with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _onKeyEvent(event, keysPressed);
    return false;
  }
}

class _ConsoleViewState() extends State<FlameConsoleView> {
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
