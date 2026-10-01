import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d_audio_core/flutter3d_audio_core.dart';

import 'package:river_sortie/src/audio/audio_scene_component.dart';

/// A looping sound that plays while this component is in the game and
/// [playing] is true: an engine, a siren, a refuelling tone.
///
/// **Held open by state, not started and stopped by events.** A loop a game
/// starts on one event and stops on another is a loop left running when the
/// second event never comes: the craft was removed, the level restarted, the
/// speakers opened in between. This one asks, every frame, whether it should
/// be sounding, and makes it so: it starts when [playing] turns on, stops
/// when it turns off or the component is removed, and moves onto the real
/// scene when the game's [AudioSceneComponent] opens the speakers.
///
/// **Where its parent is.** Under a bridged component it sounds from that
/// component's scene position; anywhere else, from the listener. [gain] and
/// [rate] are read every frame, so an engine can climb with the throttle.
class SoundEmitterComponent extends Component {
  SoundEmitterComponent(
    this.sound, {
    this.playing = true,
    this.gain = 1.0,
    this.rate = 1.0,
    super.priority,
  });

  /// What it plays. A loop, normally; a one-shot plays once each time
  /// [playing] turns on.
  final SoundDef sound;

  /// Whether it should be sounding.
  bool playing;

  /// Scales the sound's own gain.
  double gain;

  /// Scales the sound's own speed, pitch with it.
  double rate;

  AudioSceneComponent? _audio;
  SoundEmitter? _emitter;
  AudioScene? _playingOn;

  /// Whether a one-shot has played for this turn of [playing]: moved onto
  /// the speakers when they open, it would otherwise play a second time.
  bool _shot = false;

  /// Seconds until the game is searched again for its sound.
  double _lookAgainIn = 0.0;

  /// The voice this is holding, while it holds one.
  SoundEmitter? get emitter => _emitter;

  /// **Found again when it goes.** A level restarted with a new
  /// [AudioSceneComponent] left every emitter playing into the old one,
  /// closed and no longer updated, and the new level was silent. And a game
  /// with no sound is searched a few times a second, not every frame by
  /// every emitter.
  AudioSceneComponent? _find(double dt) {
    final had = _audio;
    if (had != null && had.isMounted) {
      return had;
    }
    if (had != null) {
      _stop();
      _audio = null;
    }
    _lookAgainIn -= dt;
    if (_lookAgainIn > 0.0) {
      return null;
    }
    _lookAgainIn = 0.25;
    // Looked for until found rather than once on mount: added in the same
    // batch as the game's AudioSceneComponent, this can mount first and
    // find nothing there yet.
    return _audio = findGame()
        ?.descendants()
        .whereType<AudioSceneComponent>()
        .firstOrNull;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final audio = _find(dt);
    if (audio == null) {
      return;
    }
    if (!playing) {
      _stop();
      _shot = false;
      return;
    }
    final scene = audio.scene;
    final at = switch (parent) {
      final Object3dComponent owner => owner.scenePosition,
      _ => audio.listener.position,
    };
    if (_emitter == null || !identical(_playingOn, scene)) {
      _stop();
      if (!sound.loop && _shot) {
        return;
      }
      _emitter = scene.play(sound, at);
      _playingOn = scene;
      _shot = true;
    }
    _emitter!
      ..position.setFrom(at)
      ..gain = gain
      ..rate = rate;
  }

  void _stop() {
    _emitter?.stop();
    _emitter = null;
    _playingOn = null;
  }

  @override
  void onRemove() {
    _stop();
    super.onRemove();
  }
}
