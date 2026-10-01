part of 'river_game.dart';

/// Which model plays which part.
enum Craft {
  player('assets/models/jet_player.glb', 2.3, floats: false),
  enemyJet('assets/models/jet_enemy.glb', 2.5, floats: false),
  helicopter('assets/models/helicopter.glb', 2.8, floats: false),
  tankerA('assets/models/tanker_a.glb', 3.7, floats: true),
  tankerB('assets/models/tanker_b.glb', 3.7, floats: true);

  const Craft(this.file, this.length, {required this.floats});

  final String file;

  /// Nose to tail once fitted, in metres: about the length of the hitbox
  /// it stands for, so what is drawn is what can be hit.
  final double length;

  /// Sits on the water rather than centred on its flying height.
  final bool floats;

  /// How it is worn: a ship stands on the water with its keel 15 cm under
  /// it, a flying craft is centred on its height.
  ModelLook get look => ModelLook(
    file,
    length: length,
    onGround: floats,
    offset: floats ? Vector3(0.0, -0.15, 0.0) : null,
  );

  static Map<Craft, ModelLook> get looks => <Craft, ModelLook>{
    for (final craft in values) craft: craft.look,
  };
}

/// The meshes and materials shared by everything of a kind, uploaded once.
///
/// **Every stand-in faces +Z, the way every model does.** The models this
/// game loads all happen to be built nose along +Z, so the primitives are
/// turned to match when they are made, and one rule turns either to face
/// where it is going: [TargetComponent.face], [JetComponent.bankTowards].
final class _Kit {
  _Kit(this.device)
    : playerJet = _upload(
        device,
        jetMesh(Vector4(0.9, 0.2, 0.15, 1.0), Vector4(0.95, 0.95, 0.9, 1.0)),
        math.pi,
      ),
      enemyJet = _upload(
        device,
        jetMesh(Vector4(0.25, 0.3, 0.55, 1.0), Vector4(0.6, 0.65, 0.75, 1.0)),
        math.pi,
      ),
      tanker = _upload(device, tankerMesh(), -math.pi / 2.0),
      helicopter = _upload(device, helicopterMesh(), -math.pi / 2.0),
      rotor = DeviceMesh.upload(device, rotorMesh()),
      depot = DeviceMesh.upload(device, depotMesh()),
      shot = DeviceMesh.upload(device, shotMesh()),
      bullet = DeviceMesh.upload(device, bulletMesh()),
      shard = DeviceMesh.upload(device, shardMesh()),
      puff = DeviceMesh.upload(device, puffMesh()),
      water = DeviceMesh.upload(device, waterMesh());

  final GraphicsDevice device;
  final DeviceMesh playerJet;
  final DeviceMesh enemyJet;
  final DeviceMesh tanker;
  final DeviceMesh helicopter;
  final DeviceMesh rotor;
  final DeviceMesh depot;
  final DeviceMesh shot;
  final DeviceMesh bullet;
  final DeviceMesh shard;
  final DeviceMesh puff;
  final DeviceMesh water;

  /// White, so the vertex colours are the colours.
  final engine.Material painted = engine.Material(
    name: 'painted',
    baseColor: Vector4(1.0, 1.0, 1.0, 1.0),
    roughness: 0.8,
  );

  final engine.Material waterMaterial = engine.Material(
    name: 'water',
    baseColor: Vector4(0.02, 0.09, 0.26, 1.0),
    roughness: 0.15,
  );

  /// A shot: lit from inside, so it reads against the water and the land.
  final engine.Material glow = engine.Material(
    name: 'glow',
    baseColor: Vector4(1.0, 0.85, 0.4, 1.0),
    emissive: Vector3(1.0, 0.75, 0.3),
    emissiveStrength: 4.0,
  );

  /// A helicopter's bullet: red, so it reads as the enemy's and not a
  /// shot of the jet's own.
  final engine.Material tracer = engine.Material(
    name: 'tracer',
    baseColor: Vector4(1.0, 0.2, 0.15, 1.0),
    emissive: Vector3(1.0, 0.15, 0.1),
    emissiveStrength: 6.0,
  );

  /// A bridge's shield, while the level's task is not done.
  final engine.Material shield = engine.Material(
    name: 'shield',
    baseColor: Vector4(0.3, 0.95, 1.0, 1.0),
    emissive: Vector3(0.2, 0.9, 1.0),
    emissiveStrength: 5.0,
  );

  static DeviceMesh _upload(GraphicsDevice device, MeshData mesh, double yaw) =>
      DeviceMesh.upload(device, mesh.transformed(Matrix4.rotationY(yaw)));
}

/// The models, put on the bodies the game already moves.
///
/// **What is drawn hangs from the component's `visual` node.** Until
/// [dressWithModels] has loaded the files, and always in the tests, which
/// never load them, that is the primitive from `models.dart`; the game's
/// `ModelWardrobe` puts each model on every visual node that plays its part
/// as it arrives, including those made while it was loading. The visual
/// node is also what turns a craft to face its way and banks the jet,
/// because the bridge leaves its rotation alone.
extension RiverGameCraft on RiverGame {
  /// Loads every model and dresses whatever is already in play. A target
  /// made later is dressed as it is made. A model that fails to load
  /// leaves its primitive, and the game plays on.
  ///
  /// [source] is the app bundle in the app; a test, which has no bundle an
  /// isolate can read, hands in the files on disk.
  Future<void> dressWithModels({
    AssetSource Function(String path) source = BundleAssetSource.new,
  }) => wardrobe.load(
    source: source,
    onError: (craft, error) =>
        debugPrint('river: ${craft.file} did not load ($error)'),
  );
}
