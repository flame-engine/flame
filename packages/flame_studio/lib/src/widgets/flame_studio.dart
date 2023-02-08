import 'package:flame/game.dart';
import 'package:flame_studio/src/widgets/scaffold.dart';
import 'package:flame_studio/src/widgets/settings_provider.dart';
import 'package:flutter/widgets.dart';

class FlameStudio extends StatefulWidget {
  const FlameStudio(this.child, {super.key});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _FlameStudioState();
}

class _FlameStudioState extends State<FlameStudio> {
  Game? _game;
  Future<void>? _findGameWidgetFuture;
  void _scheduleGameWidgetSearch() {
    _findGameWidgetFuture ??= Future.microtask(
      () {
        Game? game;
        void visitor(Element element) {
          if (element.widget is GameWidget) {
            final dynamic state = (element as StatefulElement).state;
            // ignore: avoid_dynamic_calls
            game = state.currentGame as Game;
          } else {
            element.visitChildElements(visitor);
          }
        }

        WidgetsBinding.instance.renderViewElement?.visitChildElements(visitor);
        if (game == null) {
          setState(() {
            _findGameWidgetFuture = null;
            _game = null;
            _scheduleGameWidgetSearch();
          });
        } else if (game != _game) {
          setState(() {
            _game = game;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    _scheduleGameWidgetSearch();

    return SettingsProvider(
      game: _game,
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
