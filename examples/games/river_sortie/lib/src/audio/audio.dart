/// Sound for a Flame game bridged to flutter3d.
///
/// [AudioSceneComponent] is the game's sound: silent until the player's
/// first input opens the speakers, heard from the game's 3D camera, mixed
/// after everything has moved. [SoundEmitterComponent] is a loop that plays
/// while its component lives and asks to be heard.
///
/// **Kept in the game rather than depended on.** These two components are
/// published as `flame_flutter3d_audio`, whose releases are built against
/// Flame 1.x, so the example carries its own copy of them. It plays into
/// `flutter3d_audio_core`'s silent backend: the game decides what to say and
/// where, and nothing is heard, because a backend would bring SoLoud's native
/// build into Flame's examples.
library;

import 'package:river_sortie/src/audio/audio.dart'
    show AudioSceneComponent, SoundEmitterComponent;

export 'audio_scene_component.dart';
export 'sound_emitter_component.dart';
