import 'package:flame/game.dart';
import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flame_studio/src/widgets/scaffold.dart';
import 'package:flutter/widgets.dart';

class FlameStudio extends StatefulWidget {
  const FlameStudio(this.child, {super.key});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _FlameStudioState();
}

class _FlameStudioState extends State<FlameStudio> {
  GameWidget? _gameWidget;
  State? _gameWidgetState;
  Future<void>? _findGameWidgetFuture;
  void _scheduleGameWidgetSearch() {
    _findGameWidgetFuture ??= Future.microtask(
      () {
        GameWidget? foundGameWidget;
        State? gameWidgetState;
        void visitor(Element element) {
          if (element.widget is GameWidget) {
            foundGameWidget = element.widget as GameWidget;
            gameWidgetState = (element as StatefulElement).state;
          } else {
            element.visitChildElements(visitor);
          }
        }

        WidgetsBinding.instance.renderViewElement?.visitChildElements(visitor);
        if (foundGameWidget == null) {
          setState(() {
            _gameWidget = null;
            _gameWidgetState = null;
            _findGameWidgetFuture = null;
            _scheduleGameWidgetSearch();
          });
        } else if (foundGameWidget != _gameWidget) {
          setState(() {
            _gameWidget = foundGameWidget;
            _gameWidgetState = gameWidgetState;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    _scheduleGameWidgetSearch();

    return FlameStudioSettings(
      gameWidget: _gameWidget,
      gameWidgetState: _gameWidgetState,
      child: Scaffold(
        child: widget.child,
      ),
    );
  }

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _initialized = true;
  }
}
