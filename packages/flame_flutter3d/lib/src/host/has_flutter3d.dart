import 'package:flame/components.dart' show World;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show TransparentFlameGame;
import 'package:flame_flutter3d/src/debug/hitboxes3d.dart';
import 'package:flame_flutter3d/src/host/transparent_flame_game.dart'
    show TransparentFlameGame;
import 'package:flame_flutter3d/src/transform/projector.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter3d/flutter3d.dart' hide Material;

/// A [FlameGame] that owns its 3D world: the scene, the camera it is seen
/// through, the renderer that draws it and the projector between the two
/// layers, all reachable from inside the game.
///
/// **What a bridged game had to be told from outside.** Without this, the
/// device and the scene arrived in a `buildScene` callback written in the
/// app's `main.dart`, the renderer in a second callback, and everything the
/// game needed of them (a projector for a score over a target, a renderer to
/// let a mesh go through, a chase camera to shake) was handed back to it by
/// hand, in an order the app had to get right. River Sortie's `main.dart`
/// was mostly that wiring. With this mixin the game builds its own world in
/// [onOpen3d], and `Flutter3dFlameWidget(game: game)` needs nothing else.
///
/// **The background is transparent**, as [TransparentFlameGame]'s is: the
/// 3D layer is under Flame's, and an opaque background hides it.
///
/// ## When the world is there
///
/// [open3d] is what opens it: `Flutter3dFlameWidget` calls it once its
/// device is open, which is before Flame loads the game, so [scene] and
/// [device] are there from [onLoad] on. A test with no widget calls it
/// itself, with a software device, before or after loading the game; either
/// way [onOpen3d] runs once, when the game has loaded and the world exists
/// to be built on.
///
/// ## When it goes
///
/// **The world lives as long as the game, not its widget.** Flame keeps a
/// game's components when its `GameWidget` goes, so the same game can be
/// shown again, on a tab that comes back or behind an `if`. The 3D world
/// does the same: the device the widget opened for it is left open, and a
/// widget showing the game again draws the world it already has. Before,
/// the widget closed the device under a world still built on it, and the
/// game came back with meshes on a closed device and no particles.
/// [close3d] lets it go, and [dispose] calls it.
///
/// **Any world.** Generic over the game's world, so a `Forge2DGame`, whose
/// world is a `Forge2DWorld`, or any game with a world of its own type, can
/// have it; on `FlameGame` alone it could be mixed into a game of the plain
/// `World` and nothing else.
mixin HasFlutter3d<W extends World> on FlameGame<W> {
  /// The camera the 3D layer is drawn through. Made by [createCamera3d] the
  /// first time it is read.
  late final CameraNode camera3d = createCamera3d();

  /// Makes [camera3d]. Override to choose the lens.
  CameraNode createCamera3d() => CameraNode(name: 'camera 3d');

  /// Between [camera3d] and Flame's screen, over this game's own [size] and
  /// the part of it [viewport3d] gives the camera.
  late final BridgeProjector projector = BridgeProjector(
    camera: camera3d,
    viewSize: () => size,
    viewport: () => viewport3d,
  );

  /// The part of the canvas [camera3d] is drawn into: all of it unless a
  /// split screen gives it a half. Read every frame.
  ViewportRect viewport3d = const ViewportRect(0.0, 0.0, 1.0, 1.0);

  /// Views drawn after [camera3d]'s, into the same frame: the second
  /// player's half of a split screen, a rear-view mirror. Each has its own
  /// camera, added to [scene] by the game, and its own
  /// `RenderView.viewportFraction`; a `BridgeProjector` given that part is
  /// its projector.
  final List<RenderView> moreViews3d = <RenderView>[];

  /// Behind everything the 3D layer draws. The same vector every frame, so
  /// changing its components changes the sky on the next one.
  final Vector4 clearColor = Vector4(0.05, 0.05, 0.07, 1.0);

  /// The fog the 3D layer is drawn through: what an `AtmosphereComponent`
  /// in the game writes as its day turns. The rest of the air, the sky and
  /// the light, lives in the scene; the fog is a setting of the frame.
  FogSettings fog3d = const FogSettings();

  /// What each 3D frame is drawn with, read before every frame: [fog3d],
  /// unless overridden. An override that wants the day's fog passes
  /// `fog: fog3d`.
  RenderSettings renderSettings() => RenderSettings(fog: fog3d);

  GraphicsDevice? _device;
  Scene? _scene;
  Renderer? _renderer;
  bool _opened = false;
  bool _loaded = false;
  bool _rendererUsed = false;
  void Function()? _release;

  /// Whether [open3d] has run: whether there is a [scene] to build on.
  bool get has3d => _scene != null;

  /// The device the 3D layer is open on. Throws before [open3d].
  GraphicsDevice get device =>
      _device ?? (throw StateError('The 3D layer is not open yet.'));

  /// The scene the 3D layer draws, with [camera3d] in it. Throws before
  /// [open3d].
  Scene get scene =>
      _scene ?? (throw StateError('The 3D layer is not open yet.'));

  /// The renderer drawing the 3D layer, once there is one; null in a test
  /// that renders no frames.
  Renderer? get renderer => _renderer;

  /// Opens the 3D world on [device]: [scene], or a new one, with [camera3d]
  /// added to it. Then [onOpen3d], once the game is loaded as well.
  void open3d(GraphicsDevice device, {Scene? scene}) {
    if (_scene != null) {
      throw StateError('The 3D layer is already open.');
    }
    final opened = scene ?? Scene();
    if (!opened.cameras.contains(camera3d)) {
      opened.add(camera3d);
    }
    _device = device;
    _scene = opened;
    _openWhenReady();
  }

  /// Draws [next] from now on in place of [scene], on the same device and
  /// through the same renderer, with [camera3d] moved across to it.
  ///
  /// **A level is a scene.** The engine's level loader builds one per level
  /// — the brushes batched, the lights bound, the lightmap baked into it —
  /// and a game with levels moves from one to the next. [open3d] opens the
  /// layer once and refuses a second call, and [close3d] closes the device
  /// the widget handed over with it; neither is a change of level. This is.
  ///
  /// What was in the old scene stays there: the game lets go of it — the
  /// level's own `dispose` — once it is no longer drawn. [moreViews3d] are the
  /// game's to move, since their cameras are its own.
  void replaceScene3d(Scene next) {
    final was = _scene;
    if (was == null) {
      throw StateError('The 3D layer is not open yet.');
    }
    if (identical(was, next)) {
      return;
    }
    camera3d.removeFromParent();
    if (!next.cameras.contains(camera3d)) {
      next.add(camera3d);
    }
    _scene = next;
  }

  /// Hands over the renderer the 3D layer draws with. Called by
  /// `Flutter3dFlameWidget`, and by a test that renders frames; the game's
  /// own use of it goes in [onRenderer3d].
  void attachRenderer(Renderer renderer) {
    _renderer = renderer;
    if (_debugHitboxes3d) {
      _applyDebugHitboxes();
    }
    _openWhenReady();
  }

  /// Draws the 3D layer once more without an update. A running game is
  /// drawn every frame; a paused one is not, and a pause menu that changes
  /// [clearColor] or [renderSettings], or turns [camera3d] round a showroom,
  /// calls this to have it seen.
  void redraw3d() => redrawer3d?.call();

  /// What [redraw3d] calls: set by the widget showing the game.
  void Function()? redrawer3d;

  /// Makes [release] this game's to call when the 3D layer closes: how
  /// `Flutter3dFlameWidget` hands over a device it opened for the game, so
  /// the device outlives the widget and goes with the world built on it.
  // A method rather than a setter: it hands over ownership, which a setter
  // would hide.
  // ignore: use_setters_to_change_properties
  void closeWith(void Function() release) => _release = release;

  /// Closes the 3D layer: [onClose3d], then the renderer and the device if
  /// they were handed over with [closeWith]. A widget showing the game after
  /// this opens it afresh, and [onOpen3d] and [onRenderer3d] run again.
  void close3d() {
    if (_scene == null) {
      return;
    }
    onClose3d();
    final release = _release;
    camera3d.removeFromParent();
    _release = null;
    _device = null;
    _scene = null;
    _renderer = null;
    _opened = false;
    _rendererUsed = false;
    release?.call();
  }

  /// Lets go of what [onOpen3d] built, before the device it is on closes.
  /// A game that is shown again after [close3d] builds its world a second
  /// time, and one that added components there removes them here.
  void onClose3d() {}

  /// Closes the 3D layer before Flame's own clean-up: the components going
  /// then find no renderer to hand their meshes to, and let the device's
  /// closing take them.
  @override
  void dispose() {
    close3d();
    super.dispose();
  }

  /// Draws every bridged hitbox in the scene, where its craft is: see
  /// [addHitboxes3d]. For looking at why a hit missed; off by default.
  bool get debugHitboxes3d => _debugHitboxes3d;
  set debugHitboxes3d(bool on) {
    _debugHitboxes3d = on;
    _applyDebugHitboxes();
  }

  bool _debugHitboxes3d = false;

  void _applyDebugHitboxes() {
    final drawing = _renderer;
    if (drawing == null) {
      return;
    }
    drawing.debugLines = _debugHitboxes3d
        ? (DebugDraw lines) => addHitboxes3d(lines, this)
        : null;
  }

  /// Uses the renderer: adds a contributor, hands it to a particle pool.
  /// Runs once, after [onOpen3d], so what that built is there to be given
  /// it. The widget hands the renderer over before Flame has loaded the
  /// game, and a hook called at once met a game with nothing built yet.
  void onRenderer3d(Renderer renderer) {}

  /// Builds the 3D world: runs once, when [open3d] has run and the game has
  /// loaded, in whichever order those came. An override of [onLoad] that
  /// wants the world calls `super.onLoad()` first.
  void onOpen3d() {}

  /// Opens the world after the game's own loading, not on mount: Flame
  /// 1.38 mounts the root game without calling its `onMount`, in a
  /// `GameWidget` and in `flame_test` alike.
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _loaded = true;
    _openWhenReady();
  }

  void _openWhenReady() {
    if (_scene == null || !_loaded) {
      return;
    }
    if (!_opened) {
      _opened = true;
      onOpen3d();
    }
    final drawing = _renderer;
    if (drawing != null && !_rendererUsed) {
      _rendererUsed = true;
      onRenderer3d(drawing);
    }
  }

  @override
  Color backgroundColor() => const Color(0x00000000);
}
