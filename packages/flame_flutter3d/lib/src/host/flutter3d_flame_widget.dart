import 'package:flame/game.dart'
    show FlameGame, GameWidget, OverlayWidgetBuilder;
import 'package:flame_flutter3d/src/host/bridge_clock.dart';
import 'package:flame_flutter3d/src/host/has_flutter3d.dart';
import 'package:flame_flutter3d/src/host/transparent_flame_game.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_app/flutter3d_app.dart';
import 'package:vector_math/vector_math.dart' show Vector4;

/// A 3D flutter3d layer and a 2D Flame layer, composited in one `Stack`, one
/// frame each.
///
/// **Both engines render their own layer.** [SceneSurface] draws the 3D
/// scene [buildScene] returns; Flame's own [GameWidget] draws [game]. Neither
/// engine's renderer is reimplemented, and neither drives the other's
/// drawing — they sit in one `Stack`, [game]'s [GameWidget] on top, the same
/// arrangement `apps/flutter3d_demo_platformer` already uses for its own HUD
/// and input layer over a bare `SceneSurface`: on the web the 3D surface is a
/// platform view that swallows pointer events, so whatever needs raw input —
/// here, Flame itself — has to sit above it in the tree.
///
/// **[game] must not paint an opaque background.** `GameWidget` paints
/// `game.backgroundColor()` as a `DecoratedBox` behind its own canvas, and
/// `Game.backgroundColor()` defaults to opaque black — which, sitting on top
/// of [SceneSurface] the way this widget arranges the two, draws a solid
/// black rectangle over the whole 3D layer every frame. Extend
/// [TransparentFlameGame] instead of [FlameGame], or override
/// `backgroundColor()` the same way it does.
///
/// **A game that owns its world needs nothing else.** Give [game] the
/// [HasFlutter3d] mixin and pass it alone: its [HasFlutter3d.camera3d] is
/// the camera, [HasFlutter3d.open3d] opens its scene on this widget's
/// device, its renderer is handed to [HasFlutter3d.attachRenderer], and its
/// [HasFlutter3d.renderSettings] and [HasFlutter3d.clearColor] draw the
/// frame. [camera], [buildScene], [settings], [clearColor] and
/// [onRendererReady] are for a game without it, and override it where given.
///
/// **One clock.** A [BridgeClock] is added to [game] once it loads, and every
/// Flame frame — after every other component in [game] has updated — calls
/// [onTick] with that frame's own `dt`, then triggers a Flutter rebuild so
/// [SceneSurface] renders the 3D frame in step. Nothing here starts a second
/// ticker; see [BridgeClock] for why that matters.
///
/// **A new game is a new host.** A rebuild that hands in a different [game]
/// gets a fresh device, scene and clock for it, as if the widget had just
/// appeared; the old game keeps its world, or lets its device go, as it
/// would had the widget gone. Before, the new game was drawn over the old
/// one's scene and never had its own opened.
class Flutter3dFlameWidget extends StatelessWidget {
  const Flutter3dFlameWidget({
    required this.game,
    super.key,
    this.camera,
    this.buildScene,
    this.existing,
    this.onRendererReady,
    this.onTick,
    this.clearColor,
    this.settings,
    this.width = 1280,
    this.height = 720,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
  }) : assert(
         game is HasFlutter3d || (camera != null && buildScene != null),
         'A game without HasFlutter3d needs a camera and a buildScene.',
       );

  /// The Flame game whose [GameWidget] draws the 2D layer. Constructed by
  /// the caller — this widget only adds one [BridgeClock] to it, once.
  final FlameGame game;

  /// The camera the 3D layer renders through. Added to the built [Scene]
  /// automatically if [buildScene] did not already add it. Null for a
  /// [HasFlutter3d] game, whose [HasFlutter3d.camera3d] it is.
  final CameraNode? camera;

  /// Builds the 3D scene once a [GraphicsDevice] is open. Called exactly
  /// once, the same contract `flutter3d_app`'s own examples use. Null for a
  /// [HasFlutter3d] game, which builds its own in [HasFlutter3d.onOpen3d].
  final Scene Function(GraphicsDevice device)? buildScene;

  /// A device and renderer opened by the caller, reused instead of this
  /// widget opening its own. A host that already has one — a page inside a
  /// larger application, say, where `DemoContext` hands one out per page —
  /// opening a second `GraphicsDevice` just to show a bridged demo would be
  /// two GPU contexts open for one picture. `openDevice` runs only when this
  /// is null.
  final ({GraphicsDevice device, Renderer renderer})? existing;

  /// Called once with the [Renderer] the 3D layer draws with, as soon as
  /// there is one: after [buildScene], whether this widget opened the device
  /// or was handed [existing].
  ///
  /// **For what a game has to ask the renderer itself**: letting go of a
  /// mesh it streamed in (`Renderer.releaseMeshAfterFrame`), adding a
  /// contributor that draws particles. Without it a bridged game saw the
  /// device in [buildScene] and never the renderer, which this widget made
  /// and kept.
  final void Function(Renderer renderer)? onRendererReady;

  /// Called every time Flame updates [game], after its own components have,
  /// with that update's `dt`: the seam a physics step, an actor system step,
  /// or a camera sync controller advances from.
  ///
  /// **Once a frame, and occasionally with a `dt` of zero.** `GameWidget`
  /// calls `update(0)` from its own layout whenever it is rebuilt: on its
  /// first frame, and when its size changes. This widget no longer rebuilds
  /// it every frame, but a step that divides by `dt` should still ignore a
  /// zero.
  final void Function(double dt)? onTick;

  /// The 3D layer's clear color, behind whatever [buildScene] draws.
  final Vector4? clearColor;

  /// What the 3D layer's frame is drawn with. Re-read every frame, after
  /// [onTick] — the same contract `SceneSurface.settings` already has.
  final RenderSettings Function()? settings;

  /// Flame's overlays: Flutter widgets over the game, shown and hidden by
  /// name through `game.overlays`. Handed to the `GameWidget` as they are.
  ///
  /// **What a bridged game had to build a second `Stack` for.** A pause
  /// menu or a name entry over the 3D layer is what `GameWidget` already
  /// does with these; the host did not pass them on.
  final Map<String, OverlayWidgetBuilder<FlameGame>>? overlayBuilderMap;

  /// The overlays shown from the start.
  final List<String>? initialActiveOverlays;

  /// The focus the game's keyboard listens through, for a host that moves
  /// focus between the game and its own widgets.
  final FocusNode? focusNode;

  /// Whether the game takes the keyboard focus when it appears.
  final bool autofocus;

  /// The [GraphicsDevice]'s own backing size — not this widget's size on
  /// screen, which `SceneSurface` already resizes the render target to
  /// independently of this.
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) =>
      _Flutter3dFlameHost(key: ObjectKey(game), config: this);
}

class _Flutter3dFlameHost extends StatefulWidget {
  const _Flutter3dFlameHost({required this.config, super.key});

  final Flutter3dFlameWidget config;

  @override
  State<_Flutter3dFlameHost> createState() => _Flutter3dFlameHostState();
}

class _Flutter3dFlameHostState extends State<_Flutter3dFlameHost> {
  Flutter3dFlameWidget get _config => widget.config;

  /// The game, when it owns its world.
  HasFlutter3d? get _owner => switch (_config.game) {
    final HasFlutter3d owner => owner,
    _ => null,
  };

  CameraNode get _camera => _config.camera ?? _owner!.camera3d;

  late RenderView _view = _viewFor();

  RenderView _viewFor() => RenderView(
    camera: _camera,
    clearColor:
        _config.clearColor ??
        _owner?.clearColor ??
        Vector4(0.05, 0.05, 0.07, 1.0),
  );

  /// The camera this state put in the scene, to take out again when a
  /// rebuild hands in another; a scene kept every camera it was ever given.
  CameraNode? _addedCamera;

  /// **A new camera or a new clear colour is used.** Both went into the view
  /// once, when this state was made, and a rebuild that handed in a
  /// different camera, or a sky for the next level, changed nothing on
  /// screen. New overlays or a new focus make a new `GameWidget`.
  @override
  void didUpdateWidget(_Flutter3dFlameHost old) {
    super.didUpdateWidget(old);
    final was = old.config;
    if (!identical(was.camera, _config.camera) ||
        was.clearColor != _config.clearColor) {
      final scene = _ready?.scene;
      final camera = _camera;
      final added = _addedCamera;
      if (added != null && !identical(added, camera)) {
        added.removeFromParent();
        _addedCamera = null;
      }
      if (scene != null && !scene.cameras.contains(camera)) {
        scene.add(camera);
        _addedCamera = camera;
      }
      _view = _viewFor();
    }
    // **Same names, new builders: the overlays rebuild, `GameWidget` stays.**
    // A map written inline in a parent's `build` is a new map of new closures
    // every time the parent rebuilds, and replacing `GameWidget` for it made
    // Flame update the game again from its layout on each of those rebuilds.
    // The overlays read the builders through [_overlays], so fresh closures
    // reach the screen without a new `GameWidget`.
    if (!identical(was.overlayBuilderMap, _config.overlayBuilderMap)) {
      _overlayBuilders.value++;
    }
    if (!setEquals(
          was.overlayBuilderMap?.keys.toSet(),
          _config.overlayBuilderMap?.keys.toSet(),
        ) ||
        !identical(was.initialActiveOverlays, _config.initialActiveOverlays) ||
        !identical(was.focusNode, _config.focusNode) ||
        was.autofocus != _config.autofocus) {
      _gameWidget = null;
    }
  }

  /// The scene on [device]: built by [Flutter3dFlameWidget.buildScene] when
  /// given, opened by the game when it owns its world.
  Scene _sceneOn(GraphicsDevice device) {
    final build = _config.buildScene;
    if (build != null) {
      final scene = build(device);
      if (scene.cameras.isEmpty) {
        scene.add(_camera);
        _addedCamera = _camera;
      }
      final owner = _owner;
      if (owner != null && !owner.has3d) {
        owner.open3d(device, scene: scene);
      }
      return scene;
    }
    final owner = _owner!;
    if (!owner.has3d) {
      owner.open3d(device);
    }
    return owner.scene;
  }

  void _rendererReady(Renderer renderer) {
    _owner?.attachRenderer(renderer);
    _config.onRendererReady?.call(renderer);
  }

  RenderSettings Function() get _settings =>
      _config.settings ??
      _owner?.renderSettings ??
      () => const RenderSettings();

  ({Renderer renderer, Scene scene})? _ready;
  Object? _error;

  /// The clock added to [Flutter3dFlameWidget.game], once.
  BridgeClock? _clock;

  /// Closes the device and renderer this state opened, when they are its to
  /// close: not when they came in through [Flutter3dFlameWidget.existing],
  /// which are the caller's, nor when the game took them with
  /// [HasFlutter3d.closeWith] to keep its world on.
  void Function()? _release;

  /// Bumped once a Flame update to redraw the 3D layer, and nothing else.
  ///
  /// **Only the 3D layer is rebuilt each frame.** A `setState` here used to
  /// rebuild the whole `Stack`, `GameWidget` with it, and `GameWidget` calls
  /// `game.update(0)` from its own layout whenever it is rebuilt, so every
  /// frame the game was updated twice, [BridgeClock] fired twice and
  /// `onTick` saw a second call with a `dt` of zero.
  final ValueNotifier<int> _frames = ValueNotifier<int>(0);

  /// The `GameWidget`, made once per game and handed back unchanged, so a
  /// rebuild of this widget from above (a HUD beside it calling `setState`,
  /// say) does not rebuild Flame's own widget either.
  GameWidget<FlameGame>? _gameWidget;

  /// Bumped when the parent hands in new overlay builders under the same
  /// names; every overlay [_overlays] builds listens to it.
  final ValueNotifier<int> _overlayBuilders = ValueNotifier<int>(0);

  /// The map `GameWidget` is given: one entry per name in
  /// [Flutter3dFlameWidget.overlayBuilderMap], each building through
  /// whatever builder the config holds *now*.
  Map<String, Widget Function(BuildContext, FlameGame)>? get _overlays =>
      switch (_config.overlayBuilderMap) {
        null => null,
        final map => <String, Widget Function(BuildContext, FlameGame)>{
          for (final name in map.keys)
            name: (BuildContext context, FlameGame game) =>
                ValueListenableBuilder<int>(
                  valueListenable: _overlayBuilders,
                  builder: (BuildContext context, int _, Widget? _) =>
                      _config.overlayBuilderMap![name]!(context, game),
                ),
        },
      };

  /// [_redraw], torn off once: two tear-offs of one method are equal but
  /// never identical, and [dispose] asks whether the game still holds this
  /// one.
  late final void Function() _redrawer = _redraw;

  @override
  void initState() {
    super.initState();
    assert(() {
      // Not an assert that throws: a game that means to cover the 3D layer
      // is allowed to, and one that does not is told why the screen is one
      // colour.
      if (_config.game.backgroundColor().a > 0.0) {
        debugPrint(
          'Flutter3dFlameWidget: ${_config.game.runtimeType} paints an opaque '
          'background over the 3D layer, which will not be seen. Mix in '
          'HasFlutter3d, extend TransparentFlameGame, or return a clear '
          'colour from backgroundColor().',
        );
      }
      return true;
    }());
    final owner = _owner;
    final kept = owner != null && owner.has3d ? owner.renderer : null;
    final existing = _config.existing;
    if (owner != null && kept != null) {
      // Shown again: the world it kept is drawn as it is, on the device it
      // was built on.
      assert(
        existing == null || identical(existing.device, owner.device),
        "This game's world is open on another device; close3d() it first.",
      );
      _ready = (renderer: kept, scene: owner.scene);
      _config.onRendererReady?.call(kept);
    } else if (existing != null) {
      // Already open: build the scene synchronously rather than through the
      // async `openDevice` path nothing here needs a second time.
      try {
        final scene = _sceneOn(existing.device);
        _ready = (renderer: existing.renderer, scene: scene);
        _rendererReady(existing.renderer);
      } on Object catch (error) {
        _error = error;
      }
    } else {
      _open();
    }
  }

  /// **A failure lets go of the device.** A scene or a renderer that threw
  /// left the device it had opened open, with nothing holding it.
  Future<void> _open() async {
    GraphicsDevice? device;
    Renderer? renderer;
    try {
      final opened = device = await openDevice(
        width: _config.width,
        height: _config.height,
      );
      if (!mounted) {
        return opened.dispose();
      }
      final scene = _sceneOn(opened);
      final made = renderer = Renderer.create(device: opened);
      void release() {
        made.dispose();
        opened.dispose();
      }

      final owner = _owner;
      if (owner != null) {
        owner.closeWith(release);
      } else {
        _release = release;
      }
      setState(() => _ready = (renderer: made, scene: scene));
      _rendererReady(made);
    } on Object catch (error) {
      if (_ready == null) {
        final owner = _owner;
        if (owner != null && owner.has3d && identical(owner.device, device)) {
          owner.close3d();
        }
        renderer?.dispose();
        device?.dispose();
      }
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  /// **Deferred to a post-frame callback, and still in step.** A rebuild
  /// asked for while a build or a layout is under way throws "called during
  /// build", so it is asked for once this frame is done, and only of the 3D
  /// layer ([_frames]). That does
  /// not put the 3D layer a frame behind, though this comment used to say it
  /// did. The callback only marks this state dirty; the next frame runs its
  /// transient callbacks first, and Flame's game loop is a `Ticker` among
  /// them, so [BridgeClock.update] has already moved the game to that frame
  /// when the build reaches [SceneSurface], which renders from its own
  /// `LayoutBuilder`. Both layers paint the same update while the ticker
  /// runs. A game stepped by hand while paused (`stepEngine`) updates
  /// outside a frame, and there the 3D layer does follow a frame later.
  void _onFlameTick(double dt) {
    if (!mounted) {
      return;
    }
    _config.onTick?.call(dt);
    _redraw();
  }

  /// Asks for the 3D layer to be drawn once this frame is done: from a tick,
  /// or from [HasFlutter3d.redraw3d] while the game is paused and nothing
  /// else asks for a frame.
  void _redraw() {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance
      ..addPostFrameCallback((Duration _) {
        if (mounted) {
          _frames.value++;
        }
      })
      ..scheduleFrame();
  }

  /// **Releases what it opened.** A device this state opened is closed with
  /// it, renderer first, unless the game took it to keep its world on; one
  /// passed in through [Flutter3dFlameWidget.existing] is left to its owner.
  /// The clock is taken off the game too, which may outlive this widget: a
  /// game kept across a route change, say, would otherwise go on calling
  /// back into a disposed state.
  @override
  void dispose() {
    _clock?.removeFromParent();
    final owner = _owner;
    if (owner != null && identical(owner.redrawer3d, _redrawer)) {
      owner.redrawer3d = null;
    }
    _frames.dispose();
    _overlayBuilders.dispose();
    _release?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Added once, not once per build: `GameWidget` may rebuild this state
    // without the game changing.
    //
    // **And only once there is a game on screen to tick for.** Added from
    // the first build, a host still opening its device, or one that failed
    // to, put a second clock into a game another host was already showing —
    // during a route transition, say — and every `update` then called
    // [Flutter3dFlameWidget.onTick] twice, stepping a simulation there twice
    // a frame. Flame lets one `GameWidget` attach a game at a time, so a host
    // that is ready is the only one showing it.
    if (_clock == null && _error == null && _ready != null) {
      final clock = _clock = BridgeClock(onTick: _onFlameTick);
      _config.game.add(clock);
      _owner?.redrawer3d = _redrawer;
    }

    return switch ((_error, _ready)) {
      (final Object error, _) => DidNotStart(
        error,
        background: const Color(0xFF14161A),
        foreground: const Color(0xFFFF8A80),
      ),
      (_, null) => const ColoredBox(
        color: Color(0xFF14161A),
        child: Center(child: CircularProgressIndicator()),
      ),
      (_, (:final renderer, :final scene)?) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ValueListenableBuilder<int>(
            valueListenable: _frames,
            builder: (BuildContext context, int frame, Widget? child) =>
                SceneSurface(
                  renderer: renderer,
                  // The game's scene as it is now, not the one it opened
                  // with: a game that moved to its next level with
                  // `replaceScene3d` is drawn there.
                  scene: _owner?.has3d ?? false ? _owner!.scene : scene,
                  view: _view,
                  moreViews: _owner?.moreViews3d ?? const <RenderView>[],
                  settings: _settings,
                  // The game's part of the canvas, read each frame: a split
                  // screen opened or closed mid-game.
                  onBeforeFrame: () {
                    final owner = _owner;
                    if (owner != null) {
                      _view.viewportFraction = owner.viewport3d;
                    }
                  },
                  presentFrame: presentFrame,
                ),
          ),
          _gameWidget ??= GameWidget<FlameGame>(
            game: _config.game,
            overlayBuilderMap: _overlays,
            initialActiveOverlays: _config.initialActiveOverlays,
            focusNode: _config.focusNode,
            autofocus: _config.autofocus,
            // A world that threw while it was built says so where the game
            // would be, as a device that would not open does.
            errorBuilder: (BuildContext context, Object error) => DidNotStart(
              error,
              background: const Color(0xFF14161A),
              foreground: const Color(0xFFFF8A80),
            ),
          ),
        ],
      ),
    };
  }
}
