/// The `FlameGame` River Sortie is played through.
///
/// **Flame owns the game; flutter3d draws it.** Every moving thing is a Flame
/// component on a flat map of the river, and the game's rules run the way
/// any Flame game's do: components update, hitboxes overlap,
/// `onCollisionStart` says what hit what. Each of those components is an
/// `Object3dComponent`, so its Flame position is written into a scene node
/// every frame, and the scene is what the player sees. Flame itself draws
/// only the instrument panel on top.
///
/// The one thing not done with hitboxes is the banks. The river's edge is a
/// curve the course can answer for any point, so the jet asks
/// [Course.rowAt] whether it is over water rather than colliding with a
/// hitbox a bank would need hundreds of.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Canvas, Color, Paint, PaintingStyle, Path, Rect;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame/input.dart' show HudButtonComponent;
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/painting.dart'
    show EdgeInsets, FontWeight, Shadow, TextStyle;
import 'package:flutter/services.dart' show KeyEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_audio_core/flutter3d_audio_core.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_particles/flutter3d_particles.dart'
    show
        ConeEmitter,
        MeshParticleContributor,
        ParticleAffector,
        ParticleColorOverLife,
        ParticleDrag,
        ParticleEffect,
        ParticleFade,
        ParticleGravity,
        ParticleSizeOverLife,
        ParticleSystem,
        Range,
        SphereEmitter;
import 'package:flutter3d_sim/flutter3d_sim.dart'
    show GameAction, GameRandom, InputState;
import 'package:river_sortie/src/audio/audio.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/levels.dart';
import 'package:river_sortie/src/models.dart';
import 'package:river_sortie/src/rules.dart';
import 'package:river_sortie/src/sprites.dart';

part 'craft.dart';
part 'hud.dart';
part 'pieces.dart';
part 'sounds.dart';
part 'staging.dart';

/// Where a run is.
enum Phase {
  /// On the water at the start of a stretch, waiting for the player.
  ready,
  flying,

  /// Down, and the pause before the next jet.
  crashed,

  /// No jets left.
  over,
}

/// What brought the last jet down.
enum Crash { bank, collision, fuel }

final class RiverGame extends FlameGame
    with HasFlutter3d, HasFixedStep, KeyboardEvents, HasCollisionDetection {
  /// [models] loads the craft models over the primitives once the river is
  /// open; the tests leave it off, having no app bundle to load them from.
  /// [billboards] draws the reeds on the banks and the flash of a blast,
  /// Flame sprites standing in the scene, once they have been drawn.
  RiverGame({
    int seed = defaultSeed,
    this.models = false,
    this.billboards = false,
    this.speakers,
  }) : course = Course(seed: seed) {
    clearColor.setValues(_haze.x, _haze.y, _haze.z, 1.0);
  }

  final bool models;
  final bool billboards;

  /// The reeds and the flash, once drawn; null until then, and in a game
  /// without [billboards].
  RiverSprites? sprites;

  /// The one texture and material each picture is drawn with, and the
  /// cards of its frames, shared by every billboard.
  late final BillboardAtlas atlas = BillboardAtlas(device);

  /// Draws the pictures, then dresses the banks of every stretch already
  /// standing, as the models dress the craft already flying. Once, however
  /// often it is asked: a second dressing would stand every reed twice.
  Future<void> drawSprites() => _drawingSprites;

  late final Future<void> _drawingSprites = _drawSprites();

  Future<void> _drawSprites() async {
    final drawn = await RiverSprites.draw();
    if (!has3d) {
      return;
    }
    sprites = drawn;
    for (final stretch in _stretches.chunks) {
      stretch.reeds.addAll(_reedsAlong(stretch.index));
      stretch.targets
          .where((target) => target.plan.kind == TargetKind.depot)
          .forEach(signDepot);
    }
  }

  @override
  void onClose3d() {
    atlas.dispose(drawing: renderer);
    super.onClose3d();
  }

  /// The sky, and the haze the far end of the river fades into: one colour,
  /// so the valley has no edge where the land stops being drawn.
  static Vector3 get _haze => Vector3(0.27, 0.48, 0.78);

  @override
  CameraNode createCamera3d() => CameraNode(
    name: 'eye',
    projection: const PerspectiveProjection(
      fovYRadians: 0.85,
      near: 0.5,
      far: 400.0,
    ),
  );

  @override
  RenderSettings renderSettings() =>
      RenderSettings(fog: FogSettings(color: _haze, density: 0.004));

  /// Opens the river, and dresses its craft when there are models to load.
  @override
  void onOpen3d() {
    build(device, scene);
    if (models) {
      unawaited(dressWithModels());
    }
    if (billboards) {
      unawaited(drawSprites());
    }
  }

  /// The trigger. `flutter3d_sim` names movement and a few common verbs; a
  /// game adds its own the same way.
  static const GameAction fire = GameAction('fire');

  /// Metres per second up the river: cruising, pushed forward, held back.
  static const double cruiseSpeed = 16.0;
  static const double fastSpeed = 26.0;
  static const double slowSpeed = 9.0;

  /// Metres per second across it at full stick.
  static const double sideSpeed = 10.0;

  /// A shot's own speed, on top of the jet's.
  static const double shotSpeed = 60.0;
  static const double shotInterval = 0.2;

  /// How close the jet has to come before a tanker or a helicopter starts
  /// to move. Until then it keeps its place, so a stretch looks the same
  /// every time it is flown into.
  static const double wakeRange = 48.0;

  /// Seconds between a crash and the next jet.
  static const double crashPause = 2.2;

  /// Half the jet's wingspan and the length ahead of its centre the bank
  /// test uses: a little under the drawing, so a wingtip over the sand is a
  /// near miss rather than a crash.
  static const double wingReach = 0.75;
  static const double noseReach = 0.9;

  /// The water, which everything is placed on: what floats at its own level,
  /// what flies at an `elevation` of [flightHeight] above it.
  static final BridgePlane river = BridgePlane.ground();

  final Course course;
  RunState run = RunState();
  Phase phase = Phase.ready;

  final InputState input = InputState();
  late final FlameInputBridge inputBridge = FlameInputBridge(
    bindings: Bindings(<InputSource, GameAction>{
      for (final key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.keyW,
      ])
        InputSource.key(key.keyId): GameAction.moveForward,
      for (final key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.keyS,
      ])
        InputSource.key(key.keyId): GameAction.moveBack,
      for (final key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.keyA,
      ])
        InputSource.key(key.keyId): GameAction.moveLeft,
      for (final key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.keyD,
      ])
        InputSource.key(key.keyId): GameAction.moveRight,
      for (final key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.enter,
      ])
        InputSource.key(key.keyId): fire,
    }),
    inputState: input,
  );

  late final JetComponent jet;
  late final GraphicsDevice _device;
  late final Scene _scene;
  late final _Kit _kit;

  /// Every shot of the jet's in the air, drawn in one call.
  late final InstancedMeshNode _shots;

  /// Whether [build] has run. Flame loads the game before the 3D device is
  /// open, and until then there is no jet to fly.
  bool built = false;

  /// Metres per second up the river, right now.
  double speed = 0.0;

  /// How far up the river the jet is.
  double get distance => -jet.position.y;

  /// The stretches of river built around the jet, by section index.
  late final ChunkStreamer<_Stretch> _stretches = ChunkStreamer<_Stretch>(
    build: _buildStretch,
    drop: _dropStretch,
  );

  /// Every target in play, for the tests and the models that load late.
  Iterable<TargetComponent> get targets =>
      _stretches.chunks.expand((stretch) => stretch.targets);

  Iterable<BridgeComponent> get bridges =>
      _stretches.chunks.map((stretch) => stretch.bridge).nonNulls;

  /// The craft models, and every visual node waiting for or wearing one.
  late final ModelWardrobe<Craft> wardrobe;

  double _crashTimer = 0.0;
  double _shotCooldown = 0.0;

  /// The on-screen stick and trigger, on a device with no keys.
  JoystickComponent? joystick;
  bool get touch => joystick != null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport.add(RiverHud());
    addAll(<Component>[
      sound,
      _engineLoop,
      _refuelLoop,
      _alarmLoop,
      // Closes the input step once everything this frame has read it.
      inputBridge.stepEnd(),
    ]);
  }

  /// The renderer the 3D layer is drawn with: what a stretch's meshes go
  /// back through, so no frame still in flight is drawing them when they
  /// do, and what the blasts are drawn with.
  @override
  void onRenderer3d(Renderer drawing) {
    blasts.drawWith(drawing, _kit.shard);
    soot.drawWith(drawing, _kit.puff, blend: MeshParticleContributor.darkening);
  }

  /// Fire, sparks and spray: everything on screen that glows or shines,
  /// one pool and one draw.
  late final Particles3dComponent blasts;

  /// Smoke: everything that darkens what is behind it, another pool and
  /// another draw.
  late final Particles3dComponent soot;

  static final TextPaint _popPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF4D35E),
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      shadows: <Shadow>[Shadow(blurRadius: 4.0, color: Color(0xAA000000))],
    ),
  );

  /// The points [points] just scored, over [at] in the scene: drawn by
  /// Flame in its viewport, rising and gone in under a second.
  void _popScore(int points, Vector3 at) {
    final screen = projector.toScreen(at);
    if (screen == null) {
      return;
    }
    camera.viewport.add(
      TextComponent(
        text: '+$points',
        textRenderer: _popPaint,
        position: screen,
        anchor: Anchor.center,
      )..addAll(<Component>[
        MoveByEffect(Vector2(0.0, -48.0), EffectController(duration: 0.8)),
        RemoveEffect(delay: 0.8),
      ]),
    );
  }

  /// Lets go of [mesh]: after the frames in flight when there is a renderer,
  /// at once when there is none and so nothing in flight.
  void _release(DeviceMesh mesh) {
    final drawing = renderer;
    if (drawing != null) {
      drawing.releaseMeshAfterFrame(mesh);
    } else {
      _device
        ..releaseGeometry(mesh.vertices)
        ..releaseGeometry(mesh.indices);
    }
  }

  /// Behind the jet and above it, looking up the river; made with the
  /// river, in `build`. Shaken when the jet goes down or a depot goes up.
  ///
  /// **Follows the jet up the river, and only part way across.** A camera
  /// locked to the jet's `x` turned the whole valley with every dodge; one
  /// that did not follow at all lost the jet off a narrow screen. A third
  /// of the way is enough to keep both banks in view and still feel the
  /// jet slide across.
  ///
  /// **Aimed so the jet sits in the lower third, above the panel.** Looking
  /// further up the river put the jet four fifths of the way down the
  /// frame, behind Flame's instrument panel, where nobody could see it bank.
  late final ChaseCamera chase;

  /// What brought the last jet down, for the tests and for anyone asking.
  Crash? lastCrash;

  /// The jet is down: over the land, into something, or dry.
  void crash(Crash cause) {
    if (phase != Phase.flying) {
      return;
    }
    lastCrash = cause;
    phase = Phase.crashed;
    _crashTimer = crashPause;
    _say(Sounds.crash);
    chase.rig.shake(0.5);
    jet.hide();
    final at = jet.scenePosition;
    fireball(at, size: 1.3);
    if (cause == Crash.bank) {
      smoke(at);
    }
  }

  /// How far a depot going up reaches: whatever is this close goes with
  /// it, the jet included.
  static const double depotBlast = 5.5;

  /// A shot, or a depot going up, reached [target]: it scores, it counts
  /// towards the level's task, and it goes down the way its kind does.
  void hitTarget(TargetComponent target) {
    if (!target.hit()) {
      return;
    }
    final kind = target.plan.kind;
    final stage = stageOf(course.sectionIndexAt(target.plan.distance));
    final wasDone = run.taskDone(stage.level);
    run
      ..award(kind.points)
      ..count(kind);
    if (!wasDone && run.taskDone(stage.level)) {
      say('TASK DONE  ·  THE LAST BRIDGE IS OPEN');
    }

    final at = target.scenePosition;
    _sayAt(kind == TargetKind.depot ? Sounds.bigBoom : Sounds.boom, at);
    _popScore(kind.points, at);
    switch (kind) {
      case TargetKind.tanker:
        fireball(at..y = 0.9, size: 0.7);
        splash(at..y = 0.1);
      case TargetKind.helicopter:
        fireball(at, size: 0.6);
      case TargetKind.jet:
        fireball(at, size: 1.1);
      case TargetKind.depot:
        fireball(at..y = 1.2, size: 1.6);
        chase.rig.shake(0.25);
        _detonate(target);
    }
  }

  /// A depot going up takes its neighbours with it, and a jet refuelling
  /// over it.
  void _detonate(TargetComponent depot) {
    for (final other in targets.toList()) {
      if (!other.down &&
          other.position.distanceTo(depot.position) < depotBlast) {
        hitTarget(other);
      }
    }
    if (jet.position.distanceTo(depot.position) < depotBlast * 0.5) {
      crash(Crash.collision);
    }
  }

  /// Whether [bridge] is the last of its level and the level's task is not
  /// done yet.
  bool shielded(BridgeComponent bridge) {
    final stage = stageOf(bridge.section);
    return bridge.section == stage.last && !run.taskDone(stage.level);
  }

  /// What the task still wants, as the panel and the shield say it.
  String stillWanted(Level level) => <String>[
    for (final kind in level.task.keys)
      if (run.stillWanted(level, kind) > 0)
        '${run.stillWanted(level, kind)} ${_plural(kind)}',
  ].join(', ');

  static String _plural(TargetKind kind) => switch (kind) {
    TargetKind.tanker => 'TANKERS',
    TargetKind.helicopter => 'HELICOPTERS',
    TargetKind.depot => 'DEPOTS',
    TargetKind.jet => 'JETS',
  };

  /// A shot reached [bridge] at [at]. A shielded one throws sparks and
  /// stands; any other breaks and falls, and the next jet starts past it.
  /// The last of a level finishes the level.
  void hitBridge(BridgeComponent bridge, {required Vector2 at}) {
    if (shielded(bridge)) {
      final struck = river.to3d(at, at: flightHeight);
      sparks(struck);
      _sayAt(Sounds.spark, struck);
      say('SHIELDED  ·  ${stillWanted(stageOf(bridge.section).level)} TO GO');
      return;
    }
    if (!bridge.collapse()) {
      return;
    }
    _sayAt(Sounds.bigBoom, bridge.scenePosition);
    run
      ..award(500)
      ..bridgeDown(bridge.section);
    _popScore(500, bridge.scenePosition..y = deckHeight);
    for (final along in <double>[-0.3, 0.0, 0.3]) {
      final burst = bridge.scenePosition
        ..x += bridge.span * along
        ..y = deckHeight;
      fireball(burst, size: 0.8);
    }
    splash(bridge.scenePosition..y = 0.1, size: 1.4);

    final stage = stageOf(bridge.section);
    if (bridge.section == stage.last) {
      run.finishLevel(stage.level);
      _say(Sounds.level);
      say('LEVEL COMPLETE  ·  +${stage.level.bonus}', seconds: 3.5);
    }
  }

  /// A helicopter at [from] fires at where the jet is now: a red flash at
  /// its nose, and a streak laid along the way it flies.
  void enemyFire({required Vector2 from}) {
    final aim = (jet.position - from)..normalize();
    final muzzle = from + aim * 1.4;
    _sayAt(Sounds.tracer, river.to3d(from, at: flightHeight));
    _muzzleFlash(river.to3d(muzzle, at: flightHeight));
    add(
      EnemyShotComponent(
        // The rod turned inside a node of its own: the component writes
        // the outer node's place, and the streak keeps its heading.
        node: SceneNode(name: 'tracer')
          ..add(
            MeshNode(_kit.bullet, _kit.tracer)
              ..setRotation(_facing(aim.x, aim.y)),
          ),
        scene: _scene,
        position: muzzle,
        velocity: aim * EnemyShotComponent.speed,
      ),
    );
  }

  void _muzzleFlash(Vector3 at) => blasts.system.burst(
    ParticleEffect(
      count: 10,
      emitter: const SphereEmitter(speed: Range(1.5, 3.5)),
      lifetime: const Range(0.2, 0.3),
      size: const Range(0.5, 0.8),
      color: _muzzle,
      affectors: const <ParticleAffector>[ParticleSizeOverLife()],
    ),
    at,
  );

  /// Fire: glowing shards thrown up and out, falling, shrinking, dimming
  /// from orange to a dull red, round the flash of the blast itself.
  void fireball(Vector3 at, {double size = 1.0}) {
    _flash(at, size);
    _shards(at, size);
  }

  /// The blast's own flash, a Flame sprite animation played once where it
  /// happened, facing the camera, gone when it has played.
  void _flash(Vector3 at, double size) {
    final drawn = sprites;
    if (drawn == null) {
      return;
    }
    final tall = 3.2 * size;
    add(
      SpriteBillboardComponent(
        animation: drawn.flash(),
        atlas: atlas,
        device: _device,
        scene: _scene,
        plane: river,
        cardHeight: tall,
        upright: false,
        removeOnFinish: true,
        position: river.to2d(at),
        elevation: at.y - tall / 2.0,
      ),
    );
  }

  void _shards(Vector3 at, double size) => blasts.system.burst(
    ParticleEffect(
      count: (14 * size).round(),
      emitter: ConeEmitter(
        speed: Range(2.5 * size, 6.5 * size),
        halfAngleDegrees: 80.0,
      ),
      lifetime: const Range(0.6, 0.9),
      size: Range(0.8 * size, 1.1 * size),
      color: _flame,
      affectors: <ParticleAffector>[
        const ParticleGravity(-14.0),
        ParticleColorOverLife(_flame, _ember),
        const ParticleSizeOverLife(),
      ],
    ),
    at,
  );

  static Vector4 get _flame => Vector4(4.0, 2.2, 0.6, 1.0);
  static Vector4 get _ember => Vector4(1.2, 0.2, 0.05, 1.0);
  static Vector4 get _spark => Vector4(4.0, 3.4, 1.6, 1.0);
  static Vector4 get _muzzle => Vector4(4.0, 0.9, 0.4, 1.0);
  static Vector4 get _spray => Vector4(0.7, 0.8, 0.9, 1.0);

  /// How much of what is behind it a puff of smoke takes away, fresh and
  /// as it thins out.
  static Vector4 get _sootThick => Vector4(0.3, 0.32, 0.38, 1.0);
  static Vector4 get _sootThin => Vector4(0.08, 0.08, 0.1, 1.0);

  /// A puff of smoke, rising slowly, swelling and thinning out: drawn by
  /// [soot], which takes its colour out of what is behind it.
  ///
  /// **Faint on its own.** A burning craft puts out a puff every fraction of
  /// a second and the puffs overlap, and darkening multiplies: a puff that
  /// took three quarters of the light made a column of black. One that
  /// takes a third at its thickest builds to a dark grey where the column
  /// is dense and stays thin at its edges. It takes a little more blue than
  /// red, so the smoke over the water reads grey-brown, not navy.
  void smoke(Vector3 at) => soot.system.burst(
    ParticleEffect(
      count: 2,
      emitter: const ConeEmitter(
        speed: Range(0.5, 1.3),
        halfAngleDegrees: 30.0,
      ),
      lifetime: const Range(1.6, 2.2),
      size: const Range(0.9, 1.2),
      color: _sootThick,
      affectors: <ParticleAffector>[
        const ParticleGravity(0.6),
        const ParticleDrag(1.5),
        ParticleColorOverLife(_sootThick, _sootThin),
        const ParticleSizeOverLife(from: 0.5, to: 2.4),
        const ParticleFade(startsAt: 0.5),
      ],
    ),
    at,
  );

  /// White water thrown up where something meets the river.
  void splash(Vector3 at, {double size = 1.0}) => blasts.system.burst(
    ParticleEffect(
      count: (12 * size).round(),
      emitter: ConeEmitter(
        speed: Range(3.0 * size, 9.0 * size),
        halfAngleDegrees: 35.0,
      ),
      lifetime: const Range(0.6, 0.8),
      size: const Range.exact(0.6),
      color: _spray,
      affectors: const <ParticleAffector>[
        ParticleGravity(-18.0),
        ParticleSizeOverLife(),
      ],
    ),
    at,
  );

  /// A shot glancing off something it cannot break.
  void sparks(Vector3 at) => blasts.system.burst(
    ParticleEffect(
      count: 6,
      emitter: const SphereEmitter(speed: Range(2.0, 4.0)),
      lifetime: const Range(0.25, 0.35),
      size: const Range.exact(0.35),
      color: _spark,
      affectors: const <ParticleAffector>[
        ParticleGravity(-14.0),
        ParticleSizeOverLife(),
      ],
    ),
    at,
  );

  /// What the panel says across the middle, and for how long more.
  String? banner;
  double _bannerFor = 0.0;

  void say(String text, {double seconds = 2.5}) {
    banner = text;
    _bannerFor = seconds;
  }

  /// The level the jet is on.
  Stage get stage => stageOf(course.sectionIndexAt(distance));

  /// The level last announced, so the next is announced as the jet flies
  /// into it.
  int _announced = -1;

  /// Whether a depot is filling the tank this step.
  bool refuelling = false;

  /// The game's sound: silent until [AudioSceneComponent.open], which the
  /// first take-off asks for through [onFirstFlight].
  late final AudioSceneComponent sound = AudioSceneComponent(
    bank: Sounds.all,
    opener: speakers,
  );

  /// How the speakers open, as the tests give a silent pair they can listen
  /// to. Without one the game is silent; see [AudioSceneComponent.opener].
  final Future<OpenedSpeakers?> Function()? speakers;

  final SoundEmitterComponent _engineLoop = SoundEmitterComponent(
    Sounds.engine,
    playing: false,
  );
  final SoundEmitterComponent _refuelLoop = SoundEmitterComponent(
    Sounds.refuel,
    playing: false,
  );
  final SoundEmitterComponent _alarmLoop = SoundEmitterComponent(
    Sounds.lowFuel,
    playing: false,
  );
  int _reserveHeard = RunState.startingReserve;

  /// Called once, the first time the jet takes off.
  ///
  /// **The moment to open the speakers.** Taking off is the player's first
  /// key, touch or button, and a browser lets a page make a sound only after
  /// one; a game that opened its audio at launch has its first sound refused.
  void Function()? onFirstFlight;
  bool _flown = false;

  void _fire() {
    _say(Sounds.shot);
    add(
      ShotComponent(
        batch: _shots,
        speed: shotSpeed + speed,
        position: jet.position + Vector2(0.0, -1.3),
      ),
    );
  }

  /// One step of flight: the stick, the throttle, the fuel, the trigger,
  /// and the banks.
  void _fly(double dt) {
    final axis = input.moveAxis;
    final wanted = axis.y > 0.2
        ? fastSpeed
        : axis.y < -0.2
        ? slowSpeed
        : cruiseSpeed;
    speed += (wanted - speed) * math.min(1.0, dt * 3.0);
    jet
      ..position.x += axis.x * sideSpeed * dt
      ..position.y -= speed * dt
      ..bankTowards(axis.x, dt);

    run.burn(dt);
    refuelling = jet.depotBelow != null;
    if (refuelling) {
      run.refuel(dt);
    }

    final current = stage;
    if (current.index != _announced) {
      _announced = current.index;
      say(
        'LEVEL ${current.index + 1}  ·  ${current.level.name.toUpperCase()}',
        seconds: 3.0,
      );
    }

    _shotCooldown -= dt;
    if (input.held(fire) && _shotCooldown <= 0.0) {
      _fire();
      _shotCooldown = shotInterval;
    }

    final x = jet.position.x;
    final overWater =
        course.rowAt(distance).isWater(x, halfWidth: wingReach) &&
        course.rowAt(distance + noseReach).isWater(x, halfWidth: 0.15);
    if (!overWater) {
      crash(Crash.bank);
    }
    if (run.outOfFuel) {
      crash(Crash.fuel);
    }
    _ensureStretches();
  }

  @override
  void update(double dt) {
    if (!built) {
      super.update(dt);
      return;
    }
    if (banner != null) {
      _bannerFor -= dt;
      if (_bannerFor <= 0.0) {
        banner = null;
      }
    }
    super.update(dt);
  }

  /// The run, in fixed steps: the same flight at any frame rate. See
  /// [HasFixedStep].
  @override
  void fixedUpdate(double dt) {
    if (!built) {
      return;
    }
    _step(dt);
    // After the step and before the children update: the game's sound is
    // one of them and mixes when it does, and a loop turned on after the
    // mix is heard a frame late.
    _listen();
  }

  void _step(double dt) {
    switch (phase) {
      case Phase.ready:
        if (input.pressed(fire) || input.moveAxis.length2 > 0.04) {
          phase = Phase.flying;
          _shotCooldown = shotInterval;
          if (!_flown) {
            _flown = true;
            onFirstFlight?.call();
          }
        }
      case Phase.flying:
        _fly(dt);
      case Phase.crashed:
        _crashTimer -= dt;
        if (_crashTimer <= 0.0) {
          if (run.nextJet()) {
            _restart();
          } else {
            phase = Phase.over;
          }
        }
      case Phase.over:
        if (input.pressed(fire)) {
          run = RunState();
          _restart();
        }
    }
  }

  /// The stick bottom left and the trigger bottom right, above the panel.
  ///
  /// **Flame's own components, feeding the same [InputState] the keys do,**
  /// through the input bridge: `followJoystick` writes the stick's
  /// deflection where a gamepad's stick would go, and `bindButton` holds
  /// [fire] while the trigger is down. The jet never learns which it was.
  void addTouchControls() {
    final stick = JoystickComponent(
      knob: CircleComponent(
        radius: 26.0,
        paint: Paint()..color = const Color(0xCCFFFFFF),
      ),
      background: CircleComponent(
        radius: 66.0,
        paint: Paint()..color = const Color(0x44FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 40.0, bottom: 110.0),
    );
    final trigger = HudButtonComponent(
      button: CircleComponent(
        radius: 42.0,
        paint: Paint()..color = const Color(0x88FF5A3C),
      ),
      margin: const EdgeInsets.only(right: 48.0, bottom: 120.0),
    );
    inputBridge.bindButton(trigger, fire);
    joystick = stick;
    camera.viewport.addAll(<Component>[stick, trigger]);
    add(inputBridge.followJoystick(stick));
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) => inputBridge.onGameKeyEvent(event, keysPressed);
}

/// One stretch of river as it stands in the game: its two scene nodes, the
/// buffers to release with it, and the components living on it.
final class _Stretch {
  _Stretch({
    required this.index,
    required this.valley,
    required this.water,
    required this.geometry,
    required this.bridge,
    required this.targets,
    required this.reeds,
  });

  final int index;
  final MeshNode valley;
  final MeshNode water;
  final List<DeviceMesh> geometry;
  final BridgeComponent? bridge;
  final List<TargetComponent> targets;

  /// The reeds and bushes on its banks, when there are sprites to draw.
  final List<SpriteBillboardComponent> reeds;
}
