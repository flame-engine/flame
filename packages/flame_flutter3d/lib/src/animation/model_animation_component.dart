import 'package:flame/components.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;

/// A model's animations played on Flame's clock: a runner running, a frog
/// crouching to hop, a door swinging.
///
/// **Paused with the game.** An `AnimationPlayer` ticked from anywhere
/// else went on running while Flame was paused, and a paused game with its
/// characters still walking is not paused. Added under the bridged
/// component whose node wears the model, this advances the player in its
/// own `update`, which Flame does not call while paused.
///
/// [play] changes the clip by name, crossfading over [crossFade] seconds
/// unless told otherwise; asking for the clip already playing does nothing,
/// so a game can ask every frame for the clip its state wants.
class ModelAnimationComponent extends Component {
  ModelAnimationComponent(this.player, {this.crossFade = 0.15, String? start})
    : _current = start {
    if (start != null) {
      player.playNamed(start);
    }
  }

  /// The player a loaded model instance came with: `ModelInstance.player`.
  final AnimationPlayer player;

  /// How long a change of clip blends, in seconds.
  final double crossFade;

  String? _current;

  /// The clip playing, by name, or null before the first [play].
  String? get current => _current;

  /// Whether the model has a clip called [name].
  bool has(String name) => player.clipNames.contains(name);

  /// Plays the clip called [name], blending from the one playing over
  /// [fade] seconds, or [crossFade]. False when there is no such clip.
  ///
  /// [restart] plays it from its start even when it is the clip playing: a
  /// second jump, a second hit. Asking for the clip playing did nothing, so
  /// a clip that plays once could be played once a game.
  bool play(String name, {double? fade, bool restart = false}) {
    if (name == _current) {
      if (restart) {
        // The player rewinds only on a change of clip: seek it back.
        player
          ..seek(0.0)
          ..play();
      }
      return true;
    }
    final found = _current == null
        ? player.playNamed(name)
        : player.crossFadeToNamed(name, duration: fade ?? crossFade);
    if (found) {
      _current = name;
    }
    return found;
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.update(dt);
  }
}

/// A mesh node that shows [frames] in turn, [framesPerSecond] of them a
/// second: an invader's two poses, a flag in four.
///
/// For animation that is a handful of shapes rather than a skeleton, which
/// is how most of the cartridge era moved. The meshes are shared; only the
/// one [node] draws changes, and only when the frame does.
class MeshFlipbookComponent extends Component {
  MeshFlipbookComponent({
    required this.node,
    required this.frames,
    this.framesPerSecond = 2.0,
  }) : assert(frames.isNotEmpty, 'a flipbook of nothing shows nothing');

  /// The node whose mesh is swapped.
  final MeshNode node;

  /// What it shows, in order, looping.
  final List<MeshGeometry> frames;

  /// How many frames a second.
  double framesPerSecond;

  double _time = 0.0;
  int _shown = -1;

  /// The index of the frame showing.
  int get frame => _shown;

  @override
  void onMount() {
    super.onMount();
    _show(0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _show((_time * framesPerSecond).floor() % frames.length);
  }

  void _show(int index) {
    if (index == _shown) {
      return;
    }
    _shown = index;
    node.mesh = frames[index];
  }
}
