/// Every mesh the river is drawn with that is not a model file: the valley,
/// the water, a bridge, a fuel depot, a shot, a shard of an explosion, and
/// the primitive stand-ins the craft are drawn as until their models load.
///
/// **Colour lives in the vertices.** Each mesh here is several shapes merged
/// into one, each shape painted its own colour, and drawn with one white
/// [Material]: a tree is a trunk and a crown in one draw, and a whole stretch
/// of valley, trees and houses included, is one more.
library;

import 'dart:math' as math;

import 'package:flutter3d/flutter3d.dart';
import 'package:river_sortie/src/course.dart';
import 'package:vector_math/vector_math.dart';

/// How high everything that flies flies, the jet included.
const double flightHeight = 1.7;

// Every colour here is picked on screen and goes into vertices, which are
// linear: through `linearFromSrgb`, or a grass green comes out pastel.
final Vector4 _grassA = linearFromSrgb(0.29, 0.52, 0.19);
final Vector4 _grassB = linearFromSrgb(0.26, 0.47, 0.17);
final Vector4 _sand = linearFromSrgb(0.72, 0.63, 0.42);
final Vector4 _bed = linearFromSrgb(0.22, 0.27, 0.22);
final Vector4 _road = linearFromSrgb(0.2, 0.2, 0.22);

Matrix4 _at(double x, double y, double z, {Quaternion? turn, Vector3? scale}) =>
    Matrix4.compose(
      Vector3(x, y, z),
      turn ?? Quaternion.identity(),
      scale ?? Vector3.all(1.0),
    );

MeshData _part(Shape shape, Vector4 colour, Matrix4 at) =>
    shape.build().transformed(at).withColor(colour);

Quaternion _about(double x, double y, double z, double angle) =>
    Quaternion.axisAngle(Vector3(x, y, z), angle);

/// A shape's +Y turned to -Z: a cylinder's top becomes a nose.
final Quaternion _yToNose = _about(1.0, 0.0, 0.0, -math.pi / 2.0);

/// A shape's +Y turned to +X.
final Quaternion _yToRight = _about(0.0, 0.0, 1.0, -math.pi / 2.0);

/// A shape's +Y turned to -X.
final Quaternion _yToLeft = _about(0.0, 0.0, 1.0, math.pi / 2.0);

// ---------------------------------------------------------------- the valley

/// One stretch of valley: both banks, the islands, the bed under the
/// water, the road to the bridge and everything [Section.scenery] plants,
/// in one mesh, in world coordinates.
///
/// **Faceted on purpose.** Each quad gets its own four vertices and its own
/// normal, so the banks read as the low, hard-edged shapes of an old
/// cartridge game drawn in 3D rather than as a smooth blur.
MeshData valleyMesh(Section section) {
  const step = 2.0;
  final rows = (sectionLength / step).round() + 1;
  final builder = MeshBuilder(
    VertexLayout.standard,
    reserveVertices: rows * 36,
    reserveIndices: rows * 54,
  );

  List<Vector3> profile(double distance) {
    final row = section.rowAt(distance);
    // A bank's slope crosses the water line within a few centimetres of
    // the row's edge, which is where the game tests the jet against it.
    final z = -distance;
    Vector3 p(double x, double y) => Vector3(x, y, z);
    // An island narrower than its own slopes rises from the bed with its
    // width, all four of its points meeting on the bed where it has none.
    // At full height at every width, a river with no island in it grew a
    // sand ridge down the middle: the island's two tops crossed over.
    // [RiverRow.dryIsland] works out the same shape's water line.
    final grown = row.islandGrown;
    final crest = bedDepth + (landHeight - bedDepth) * grown;
    return <Vector3>[
      p(-landReach, landHeight),
      p(row.left - bankTop, landHeight),
      p(row.left + bankUnder, bedDepth),
      p(row.islandLeft - bankUnder * grown, bedDepth),
      p(row.islandLeft + bankTop * grown, crest),
      p(row.islandRight - bankTop * grown, crest),
      p(row.islandRight + bankUnder * grown, bedDepth),
      p(row.right - bankUnder, bedDepth),
      p(row.right + bankTop, landHeight),
      p(landReach, landHeight),
    ];
  }

  // What each band between two profile points is: grass, slope, bed.
  Vector4 bandColour(int band, int rowIndex) => switch (band) {
    0 || 4 || 8 => rowIndex.isEven ? _grassA : _grassB,
    1 || 3 || 5 || 7 => _sand,
    _ => _bed,
  };

  var previous = profile(section.start);
  for (var r = 1; r < rows; r++) {
    final current = profile(section.start + r * step);
    for (var band = 0; band < previous.length - 1; band++) {
      _quad(
        builder,
        previous[band],
        previous[band + 1],
        current[band + 1],
        current[band],
        bandColour(band, r),
      );
    }
    previous = current;
  }

  final parts = <MeshData>[builder.build()];
  if (section.hasBridge) {
    final row = section.rowAt(section.bridgeAt);
    final z = -section.bridgeAt;
    final leftLength = row.left - 0.3 + landReach;
    final rightLength = landReach - row.right - 0.3;
    parts
      ..add(
        _part(
          CuboidShape(size: Vector3(leftLength, 0.06, 1.8)),
          _road,
          _at(-landReach + leftLength / 2.0, landHeight + 0.03, z),
        ),
      )
      ..add(
        _part(
          CuboidShape(size: Vector3(rightLength, 0.06, 1.8)),
          _road,
          _at(landReach - rightLength / 2.0, landHeight + 0.03, z),
        ),
      );
  }
  for (final plant in section.scenery) {
    final place = _at(
      plant.x,
      landHeight,
      -plant.distance,
      turn: _about(0.0, 1.0, 0.0, plant.turn),
      scale: Vector3.all(plant.scale),
    );
    parts.add(
      switch (plant.kind) {
        SceneryKind.tree => _tree,
        SceneryKind.pine => _pine,
        SceneryKind.house => _house,
      }.transformed(place),
    );
  }
  return MeshData.merge(parts);
}

/// A flat-shaded quad, wound so its front faces up; nothing for one that
/// has collapsed to a line, which a missing island's bands do.
void _quad(
  MeshBuilder builder,
  Vector3 a,
  Vector3 b,
  Vector3 c,
  Vector3 d,
  Vector4 colour,
) {
  final normal = (b - a).cross(d - a);
  if (normal.length2 < 1e-10) {
    final other = (c - b).cross(a - b);
    if (other.length2 < 1e-10) {
      return;
    }
    normal.setFrom(other);
  }
  normal.normalize();
  if (normal.y < 0.0) {
    normal.negate();
  }
  final base = builder.addVertex(position: a, normal: normal, color: colour);
  builder
    ..addVertex(position: b, normal: normal, color: colour)
    ..addVertex(position: c, normal: normal, color: colour)
    ..addVertex(position: d, normal: normal, color: colour)
    ..addQuad(base, base + 1, base + 2, base + 3);
}

final MeshData _tree = MeshData.merge(<MeshData>[
  _part(
    const CylinderShape(radiusTop: 0.1, radiusBottom: 0.14, height: 0.7),
    linearFromSrgb(0.36, 0.25, 0.15),
    _at(0.0, 0.35, 0.0),
  ),
  _part(
    const SphereShape(radius: 0.75, segments: 7, rings: 5),
    linearFromSrgb(0.18, 0.42, 0.14),
    _at(0.0, 1.2, 0.0),
  ),
]);

final MeshData _pine = MeshData.merge(<MeshData>[
  _part(
    const CylinderShape(radiusTop: 0.08, radiusBottom: 0.12, height: 0.5),
    linearFromSrgb(0.33, 0.23, 0.14),
    _at(0.0, 0.25, 0.0),
  ),
  _part(
    const ConeShape(radius: 0.65, height: 1.8, segments: 6),
    linearFromSrgb(0.1, 0.32, 0.16),
    _at(0.0, 1.35, 0.0),
  ),
]);

final MeshData _house = MeshData.merge(<MeshData>[
  _part(
    CuboidShape(size: Vector3(1.6, 1.0, 1.2)),
    linearFromSrgb(0.88, 0.84, 0.74),
    _at(0.0, 0.5, 0.0),
  ),
  _part(
    const ConeShape(radius: 1.25, height: 0.7, segments: 4),
    linearFromSrgb(0.7, 0.2, 0.15),
    _at(0.0, 1.35, 0.0, turn: _about(0.0, 1.0, 0.0, math.pi / 4.0)),
  ),
]);

/// The water over one stretch, a plane at level zero centred on it.
MeshData waterMesh() =>
    const PlaneShape(width: valleyReach * 2.0, depth: sectionLength).build();

// ------------------------------------------------------------------- props

/// How high a bridge's deck stands over the water.
const double deckHeight = landHeight + 0.45;

/// Half a road bridge, [length] metres from its bank end at the origin out
/// along +X to the middle of the river, its deck at the origin's height.
///
/// **Two halves, not one span**, so a bridge that is shot breaks in the
/// middle and each half falls turning about its own bank end, the way a
/// bridge whose centre is gone comes down.
MeshData bridgeHalfMesh(double length) {
  final middle = length / 2.0;
  return MeshData.merge(<MeshData>[
    _part(
      CuboidShape(size: Vector3(length, 0.4, 2.4)),
      linearFromSrgb(0.55, 0.55, 0.52),
      _at(middle, 0.0, 0.0),
    ),
    _part(
      CuboidShape(size: Vector3(length, 0.06, 1.8)),
      _road,
      _at(middle, 0.22, 0.0),
    ),
    _part(
      CuboidShape(size: Vector3(length, 0.07, 0.12)),
      linearFromSrgb(0.95, 0.8, 0.2),
      _at(middle, 0.24, 0.0),
    ),
    for (final side in <double>[-1.0, 1.0])
      _part(
        CuboidShape(size: Vector3(length, 0.3, 0.1)),
        linearFromSrgb(0.75, 0.75, 0.72),
        _at(middle, 0.35, side * 1.15),
      ),
    for (final along in <double>[0.35, 0.9])
      _part(
        const CylinderShape(radiusTop: 0.28, radiusBottom: 0.35, height: 1.6),
        linearFromSrgb(0.5, 0.5, 0.48),
        _at(length * along, -0.9, 0.0),
      ),
  ]);
}

/// The shield over a bridge [span] metres long: two glowing rails along its
/// sides and a post at each end, centred on the origin at deck height.
MeshData shieldMesh(double span) => MeshData.merge(<MeshData>[
  for (final side in <double>[-1.0, 1.0]) ...<MeshData>[
    CuboidShape(
      size: Vector3(span, 0.12, 0.12),
    ).build().transformed(_at(0.0, 0.62, side * 1.25)),
    for (final end in <double>[-1.0, 1.0])
      CuboidShape(
        size: Vector3(0.14, 1.1, 0.14),
      ).build().transformed(_at(end * span / 2.0, 0.3, side * 1.25)),
  ],
]);

/// A floating fuel depot: a pontoon under a tank striped red and white, the
/// way it has always looked.
MeshData depotMesh() => MeshData.merge(<MeshData>[
  _part(
    CuboidShape(size: Vector3(1.9, 0.3, 2.3)),
    linearFromSrgb(0.4, 0.42, 0.45),
    _at(0.0, 0.1, 0.0),
  ),
  for (var i = 0; i < 5; i++)
    _part(
      CuboidShape(size: Vector3(1.5, 0.26, 1.9)),
      i.isEven
          ? linearFromSrgb(0.85, 0.12, 0.1)
          : linearFromSrgb(0.95, 0.95, 0.92),
      _at(0.0, 0.38 + i * 0.26, 0.0),
    ),
]);

/// A shot: a short bright rod, nose along -Z.
MeshData shotMesh() => CuboidShape(
  size: Vector3(0.14, 0.14, 0.9),
).build().withColor(linearFromSrgb(1.0, 0.9, 0.4));

/// A helicopter's bullet: a long rod along Z, white, for its material to
/// colour. Long so it reads as a streak coming at the jet from eleven
/// metres up; a cube the size of a shard was lost against the water.
MeshData bulletMesh() => CuboidShape(size: Vector3(0.3, 0.3, 1.6)).build();

/// One shard of an explosion, white: its material gives it its colour.
MeshData shardMesh() => CuboidShape(size: Vector3.all(0.32)).build();

/// A puff of smoke: a coarse ball, so a darkening particle is darkest in
/// the middle, where it faces the eye, and soft at its rim.
MeshData puffMesh() =>
    const SphereShape(radius: 0.3, segments: 10, rings: 6).build();

// ------------------------------------------------- stand-ins for the models

/// A jet, nose along -Z, about two metres long. The player's until its
/// model loads, and an enemy jet's in other colours.
MeshData jetMesh(Vector4 body, Vector4 trim) => MeshData.merge(<MeshData>[
  _part(
    const CylinderShape(
      radiusTop: 0.17,
      radiusBottom: 0.22,
      height: 1.5,
      segments: 10,
    ),
    body,
    _at(0.0, 0.0, 0.05, turn: _yToNose),
  ),
  _part(
    const ConeShape(radius: 0.17, height: 0.55, segments: 10),
    body,
    _at(0.0, 0.0, -0.975, turn: _yToNose),
  ),
  _part(
    const SphereShape(segments: 12, rings: 8),
    linearFromSrgb(0.12, 0.18, 0.3),
    _at(0.0, 0.14, -0.35, scale: Vector3(0.3, 0.26, 0.7)),
  ),
  for (final side in <double>[-1.0, 1.0]) ...<MeshData>[
    _part(
      CuboidShape(size: Vector3(1.15, 0.05, 0.5)),
      trim,
      _at(side * 0.6, -0.02, 0.2, turn: _about(0.0, 1.0, 0.0, side * -0.35)),
    ),
    _part(
      CuboidShape(size: Vector3(0.5, 0.04, 0.28)),
      trim,
      _at(side * 0.3, 0.0, 0.72, turn: _about(0.0, 1.0, 0.0, side * -0.3)),
    ),
  ],
  _part(
    CuboidShape(size: Vector3(0.05, 0.45, 0.35)),
    trim,
    _at(0.0, 0.25, 0.72),
  ),
]);

/// A river tanker, bow along +X, about three and a half metres long.
MeshData tankerMesh() => MeshData.merge(<MeshData>[
  _part(
    CuboidShape(size: Vector3(3.0, 0.45, 0.95)),
    linearFromSrgb(0.55, 0.12, 0.1),
    _at(0.0, 0.12, 0.0),
  ),
  _part(
    const ConeShape(radius: 0.48, height: 0.55, segments: 4),
    linearFromSrgb(0.55, 0.12, 0.1),
    _at(1.77, 0.12, 0.0, turn: _yToRight, scale: Vector3(1.0, 1.0, 0.5)),
  ),
  _part(
    CuboidShape(size: Vector3(2.9, 0.08, 0.85)),
    linearFromSrgb(0.35, 0.4, 0.35),
    _at(0.0, 0.38, 0.0),
  ),
  for (final along in <double>[0.0, 0.85])
    _part(
      const SphereShape(segments: 10, rings: 6),
      linearFromSrgb(0.82, 0.82, 0.78),
      _at(along, 0.45, 0.0, scale: Vector3(0.8, 0.5, 0.7)),
    ),
  _part(
    CuboidShape(size: Vector3(0.6, 0.55, 0.8)),
    linearFromSrgb(0.92, 0.92, 0.88),
    _at(-1.0, 0.68, 0.0),
  ),
  _part(
    const CylinderShape(radiusTop: 0.12, radiusBottom: 0.14, height: 0.45),
    linearFromSrgb(0.15, 0.15, 0.15),
    _at(-1.2, 1.1, 0.0),
  ),
]);

/// A helicopter without its rotor, nose along +X.
MeshData helicopterMesh() => MeshData.merge(<MeshData>[
  _part(
    const SphereShape(segments: 12, rings: 8),
    linearFromSrgb(0.25, 0.38, 0.2),
    _at(0.2, 0.0, 0.0, scale: Vector3(1.0, 0.75, 0.7)),
  ),
  _part(
    const SphereShape(radius: 0.35, segments: 10, rings: 6),
    linearFromSrgb(0.12, 0.18, 0.3),
    _at(0.45, 0.08, 0.0),
  ),
  _part(
    const CylinderShape(radiusTop: 0.06, radiusBottom: 0.12, height: 1.2),
    linearFromSrgb(0.25, 0.38, 0.2),
    _at(-0.8, 0.05, 0.0, turn: _yToLeft),
  ),
  _part(
    CuboidShape(size: Vector3(0.25, 0.35, 0.04)),
    linearFromSrgb(0.25, 0.38, 0.2),
    _at(-1.35, 0.2, 0.0),
  ),
  for (final side in <double>[-1.0, 1.0])
    _part(
      CuboidShape(size: Vector3(1.1, 0.04, 0.05)),
      linearFromSrgb(0.2, 0.2, 0.2),
      _at(0.1, -0.42, side * 0.3),
    ),
]);

/// Two crossed blades, spun about their own vertical.
MeshData rotorMesh() => MeshData.merge(<MeshData>[
  _part(
    CuboidShape(size: Vector3(2.6, 0.03, 0.12)),
    linearFromSrgb(0.2, 0.2, 0.2),
    _at(0.0, 0.0, 0.0),
  ),
  _part(
    CuboidShape(size: Vector3(0.12, 0.03, 2.6)),
    linearFromSrgb(0.2, 0.2, 0.2),
    _at(0.0, 0.0, 0.0),
  ),
]);
