/// River Sortie: a jet up a river that never ends, a Flame game drawn in 3D.
///
///     flutter run -d chrome
///     flutter run -d chrome --dart-define=FLUTTER3D_WEBGPU=true
///
/// A homage to River Raid, which Carol Shaw wrote for the Atari 2600 in 1982:
/// the river narrows and splits round islands, tankers and helicopters
/// cross it, jets cut over it, the tank runs dry unless the jet flies low
/// over a depot, and a bridge ends every stretch and has to be shot down
/// to pass. Lose a jet and the next starts past the last bridge brought
/// down. The river is the same every run, as it was on the cartridge,
/// because it is laid out by a seeded generator rather than drawn by hand.
///
/// **Flame runs the game, flutter3d draws it.** `lib/src/river_game.dart` is
/// an ordinary Flame game: components, hitboxes, `onCollisionStart`, a
/// keyboard handler, Flame's own joystick and button on a phone, and a HUD
/// Flame paints. It owns its 3D world through `HasFlutter3d`: the river, the
/// lens, the haze and the camera chasing the jet. Every component that moves
/// is an `Object3dComponent` from `flame_flutter3d`, which writes its Flame
/// position into a scene node each frame; `Flutter3dFlameWidget` puts the 3D
/// layer under Flame's and runs both from Flame's clock. This file hands it
/// the game.
library;

import 'dart:async';

import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart' hide Material;

import 'package:river_sortie/src/river_game.dart';

export 'src/river_game.dart' show RiverGame;

/// Whether [platform] gets Flame's stick and fire button: a phone or a tablet,
/// which has no keys to fly with. A desktop and a browser keep the keys.
bool hasTouchControls(TargetPlatform platform) =>
    platform == TargetPlatform.android || platform == TargetPlatform.iOS;

/// The game as an app of its own, which `main.dart` runs.
class RiverApp extends StatelessWidget {
  const RiverApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    title: 'River Sortie',
    debugShowCheckedModeBanner: false,
    home: RiverScreen(),
  );
}

/// The game on a screen of its own, for an app that has other screens.
class RiverScreen extends StatefulWidget {
  const RiverScreen({super.key});

  @override
  State<RiverScreen> createState() => _RiverScreenState();
}

class _RiverScreenState extends State<RiverScreen> {
  /// Starts on the level `--dart-define=RIVER_LEVEL=n` names, counting from
  /// one, so a later level can be looked at without flying up to it.
  final RiverGame _game = RiverGame(models: true, billboards: true)
    ..startOnLevel(
      // ignore: do_not_use_environment
      const int.fromEnvironment('RIVER_LEVEL', defaultValue: 1) - 1,
    );

  /// A phone or a tablet has no keys, so it gets Flame's stick and trigger.
  @override
  void initState() {
    super.initState();
    if (hasTouchControls(defaultTargetPlatform)) {
      _game.addTouchControls();
    }
    // Taking off is the player's first key, touch or button, and a browser
    // lets a page make a sound only after one.
    _game.onFirstFlight = () => unawaited(_game.sound.open());
    // `--dart-define=RIVER_HITBOXES=true` draws every hitbox in the scene,
    // round the craft it belongs to.
    // ignore: do_not_use_environment
    _game.debugHitboxes3d = const bool.fromEnvironment('RIVER_HITBOXES');
  }

  @override
  void dispose() {
    unawaited(_game.sound.close());
    // The world lives with the game, not the widget: it goes here.
    _game.close3d();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF14161A),
    body: Flutter3dFlameWidget(game: _game),
  );
}
