import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener, WidgetsBinding;
import 'package:flutter3d_audio_core/flutter3d_audio_core.dart';
import 'package:river_sortie/src/audio/sound_emitter_component.dart'
    show SoundEmitterComponent;

/// What opening the speakers gives: the scene to play into, and how to
/// close the device under it. Null when there is no sound to be had.
typedef OpenedSpeakers = ({AudioScene scene, Future<void> Function() close});

/// A Flame game's sound: one [AudioScene], heard from the game's 3D camera,
/// silent until [open] is called and then through the speakers.
///
/// **What every bridged game with sound wrote for itself.** River Sortie kept
/// a scene, swapped it for a real one on the first take-off, stopped and
/// restarted its loops across the swap, moved its ears every frame and
/// updated the mix after everything else. This is that, once.
///
/// **Silent until [open], and [open] belongs to the player's first input.**
/// A browser lets a page make a sound only after the user has touched it, and
/// a game that opened its audio at launch has its first sound refused. Until
/// then everything plays into a [SilentBackend]: the calls a game makes are
/// the same, and nothing is heard. [SoundEmitterComponent]s move themselves
/// onto the real scene when it arrives, so a loop that was already meant to
/// be playing starts playing.
///
/// **Updated last.** Its priority is high, so the mix is worked out after
/// every emitter and every craft has moved this frame.
class AudioSceneComponent extends Component with UpdatesAtRoot {
  AudioSceneComponent({
    required this.bank,
    this.maxVoices = 16,
    this.opener,
    int priority = BridgePriority.audio,
  }) : super(priority: priority);

  /// Every sound the game can make, loaded when the speakers open.
  final SoundBank bank;

  /// How many voices may sound at once.
  final int maxVoices;

  /// How [open] opens the speakers, as a test gives a silent pair it can
  /// listen to. Without one there are no speakers to open and the game stays
  /// silent: this copy of River Sortie carries no audio backend, so that
  /// Flame's examples do not take on SoLoud's native build. A game that wants
  /// sound passes `flutter3d_audio`'s `openSpeakers` here.
  final Future<OpenedSpeakers?> Function()? opener;

  /// Where the game hears from: [HasFlutter3d.camera3d], when the game has
  /// one, facing the way it looks. Otherwise wherever the game puts it.
  final AudioListener listener = AudioListener();

  /// What is played into: silent until [open], then the speakers.
  AudioScene get scene => _scene;
  AudioScene _scene = AudioScene(backend: SilentBackend());

  Future<void> Function()? _close;
  Future<void>? _opening;

  /// Bumped by [close], so an [open] still waiting on the device when the
  /// game closed its sound knows it has been overtaken.
  int _generation = 0;

  /// Whether the speakers are open.
  bool get isOpen => _close != null;

  /// Opens the speakers and plays through them from the next frame. Call it
  /// from the player's first key, touch or button. Twice is once; a device
  /// that will not open leaves the game silent, which is a way to play.
  ///
  /// **A refusal can be asked again.** A browser refuses a page sound before
  /// the player has touched it, and an [open] refused once stayed refused
  /// for the rest of the game: the next key asks again. A [close] made
  /// while the device was still opening wins: the device is closed as soon
  /// as it arrives.
  Future<void> open() => _opening ??= _open();

  Future<void> _open() async {
    final asked = _generation;
    final opened = await (opener ?? _openSpeakers)();
    if (opened == null) {
      if (asked == _generation) {
        _opening = null;
      }
      return;
    }
    if (isRemoved || isRemoving || asked != _generation) {
      // Gone, or closed, while the device was opening: nothing will close it
      // after this.
      await opened.close();
      return;
    }
    _scene.stopAll();
    _scene = opened.scene;
    _close = opened.close;
    if (_paused) {
      _hush(_scene);
    }
  }

  bool _paused = false;
  double _volume = 1.0;

  /// Whether [pause] has silenced the game.
  bool get isPaused => _paused;

  /// Silences every sound where it is, loops included, until [resume].
  ///
  /// **For a paused game.** Flame stops updating a paused game, this with
  /// it, and whatever was sounding went on sounding at its last loudness:
  /// an engine droning under the pause menu. A game that pauses its engine
  /// calls this; a game sent to the background is paused here by itself.
  void pause() {
    if (_paused) {
      return;
    }
    _paused = true;
    _volume = _scene.mixer.volumeOf(AudioBus.master);
    _hush(_scene);
  }

  /// Brings back what [pause] silenced, at the volume it had.
  void resume() {
    if (!_paused) {
      return;
    }
    _paused = false;
    _scene.mixer.setVolume(AudioBus.master, _volume);
    _scene.update(listener);
  }

  /// Turns [scene] down to nothing and applies it at once: no update runs
  /// while the game is paused to apply it later.
  void _hush(AudioScene scene) {
    scene.mixer.setVolume(AudioBus.master, 0.0);
    scene.update(listener);
  }

  AppLifecycleListener? _lifecycle;
  bool _pausedByLifecycle = false;

  @override
  void onMount() {
    super.onMount();
    _lifecycle = _listen();
  }

  /// Null where there is no app to leave: a game stepped in a plain Dart
  /// test, with no widgets binding.
  AppLifecycleListener? _listen() {
    final WidgetsBinding binding;
    try {
      binding = WidgetsBinding.instance;
    } on Object {
      return null;
    }
    return AppLifecycleListener(
      binding: binding,
      onHide: () {
        if (_paused) {
          return;
        }
        _pausedByLifecycle = true;
        pause();
      },
      onShow: () {
        if (!_pausedByLifecycle) {
          return;
        }
        _pausedByLifecycle = false;
        resume();
      },
    );
  }

  Future<OpenedSpeakers?> _openSpeakers() async => null;

  /// Plays [sound] once, at [at] in the scene or at the listener.
  SoundEmitter play(SoundDef sound, {Vector3? at}) =>
      _scene.play(sound, at ?? listener.position);

  /// Closes the speakers, if they are open. The game goes on, silent.
  Future<void> close() async {
    final closing = _close;
    _generation++;
    _close = null;
    _opening = null;
    _scene.stopAll();
    _scene = AudioScene(backend: SilentBackend());
    await closing?.call();
  }

  /// The listener onto the camera and the mix worked out, from the game's
  /// root wherever this was added: inside the world it ran before Flame's
  /// camera, and was heard from where the camera had been a frame before.
  @override
  void rootUpdate(double dt) {
    final game = findGame();
    if (game is HasFlutter3d && game.has3d) {
      final camera = game.camera3d;
      // The camera's turn in the world, not against its parent: a camera
      // riding a craft looked the craft's way plus its own, and was heard
      // looking only its own.
      final world = camera.worldMatrix;
      listener.position.setFrom(world.getTranslation());
      final forward = world.transformed3(Vector3(0.0, 0.0, -1.0))
        ..sub(listener.position);
      listener.aimAlong(listener.position, forward);
    }
    _scene.update(listener);
  }

  @override
  void onRemove() {
    _lifecycle?.dispose();
    _lifecycle = null;
    close();
    super.onRemove();
  }
}
