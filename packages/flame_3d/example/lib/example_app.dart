import 'package:flame/game.dart';
import 'package:flame_3d_example/commands/commands.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/showcase/pure_camera_lab_game.dart';
import 'package:flame_3d_example/showcase/showcase_game.dart';
import 'package:flame_3d_example/showcase/showcase_view.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flutter/widgets.dart';

/// Shows the 3D example game, or the game of a standalone scenario (see
/// [ExampleGame3D.standaloneGame]) with a button back to the 3D game.
class const ExampleApp({super.key}) extends StatefulWidget {
  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState() extends State<ExampleApp> {
  final ExampleGame3D _game = ExampleGame3D();

  @override
  void initState() {
    super.initState();
    _game.standaloneGame.addListener(_onStandaloneGameChanged);
  }

  @override
  void dispose() {
    _game.standaloneGame.dispose();
    super.dispose();
  }

  void _onStandaloneGameChanged() {
    // The 3D game stays loaded, paused, while another game is shown.
    if (_game.standaloneGame.value == null) {
      _game.resumeEngine();
    } else {
      _game.pauseEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder(
        valueListenable: _game.standaloneGame,
        builder: (context, createGame, _) {
          return IndexedStack(
            index: createGame == null ? 0 : 1,
            sizing: StackFit.expand,
            children: [
              GameWidget(
                game: _game,
                overlayBuilderMap: {
                  'console': (BuildContext context, ExampleGame3D game) {
                    return FlameConsoleView(
                      game: game,
                      customCommands: customCommandProviders
                          .map((it) => it())
                          .toList(),
                      onClose: () {
                        game.overlays.remove('console');
                      },
                    );
                  },
                },
              ),
              if (createGame != null)
                _StandaloneGame(
                  key: ObjectKey(createGame),
                  createGame: createGame,
                  onBack: () => _game.standaloneGame.value = null,
                ),
            ],
          );
        },
      ),
    );
  }
}

class const _StandaloneGame({
  required final Game Function() createGame,
  required final VoidCallback onBack,
  super.key,
}) extends StatefulWidget {
  @override
  State<_StandaloneGame> createState() => _StandaloneGameState();
}

class _StandaloneGameState() extends State<_StandaloneGame> {
  late final Game _game = widget.createGame();

  @override
  void dispose() {
    if (_game case final ShowcaseGame showcase) {
      showcase.controller.dispose();
    } else if (_game case final PureCameraLabGame camLab) {
      camLab.hudTick.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_game case final ShowcaseGame showcase)
          ShowcaseView(game: showcase)
        else if (_game case final PureCameraLabGame camLab)
          PureCameraLabView(game: camLab)
        else
          GameWidget(game: _game),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: widget.onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Back to the 3D game',
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
