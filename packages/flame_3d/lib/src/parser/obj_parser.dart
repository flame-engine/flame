import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/model/model.dart';
import 'package:flame_3d/src/parser/model_parser.dart';
import 'package:flame_3d/src/parser/obj/surface_tool.dart';

// These are keywords used in the OBJ syntax.
// cSpell:ignore usemtl newmtl mtllib

class ObjParser extends ModelParser {
  @override
  Future<Model> parseModel(String filePath) async {
    final mesh = await parseMesh(filePath);
    return Model.simple(mesh: mesh);
  }

  Future<Mesh> parseMesh(String filePath, {Mesh? applyTo}) async {
    final vertices = <Vector3>[];
    final normals = <Vector3>[];
    final texCoords = <Vector2>[];
    final faces = <String, List<Face>>{};

    final lines = (await Flame.assets.readFile(filePath)).split('\n');

    // if not material is specified, this will be used, and the default
    // material will be applied.
    var matName = '__default__';

    final materials = <String, SpatialMaterial>{};
    for (final line in lines) {
      final [type, ...parts] = line.split(' ');

      switch (type) {
        // Comment
        case '#':
          continue;
        // Vertex
        case 'v':
          vertices.add(Vector3.array(parts.map(double.parse).toList()));
        // Normal
        case 'vn':
          normals.add(Vector3.array(parts.map(double.parse).toList()));
        // UV
        case 'vt':
          texCoords.add(Vector2.array(parts.map(double.parse).toList()));
        // Face
        case 'f':
          if (parts.length == 3) {
            // Single triangle

            final face = Face.empty();
            for (final value in parts) {
              // format is <vertex/texture/normal>, with vertex and normal being optional
              final indices = value.split('/');
              face.vertex.add(int.parse(indices[0]) - 1);
              if (indices.length > 1) {
                if (indices[1].isNotEmpty) {
                  face.texCoord.add(int.parse(indices[1]) - 1);
                }
                if (indices.length > 2) {
                  face.normal.add(int.parse(indices[2]) - 1);
                }
              }
            }
            (faces[matName] ??= []).add(face);
          } else if (parts.length > 4) {
            // TODO(luan): implement triangulation
            throw UnimplementedError(
              'Triangulation not implemented for ObjParser',
            );
          }
        // Material library
        case 'mtllib':
          final relative = (filePath.split('/')..removeLast()).join('/');
          materials.addAll(
            await _parseMaterial('$relative/${parts[0]}'.trim()),
          );
        // Material
        case 'usemtl':
          matName = parts[0].trim();

          if (!faces.containsKey(matName)) {
            if (!materials.containsKey(matName)) {
              throw AssertionError('Material not found: $matName');
            }
            faces[matName] = [];
          }
      }
    }

    var mesh = applyTo ?? Mesh();
    for (final materialGroup in faces.keys) {
      final material = materials[materialGroup] ?? Material.defaultMaterial;
      final surface = SurfaceTool()..setMaterial(material);

      for (final face in faces[materialGroup]!) {
        if (face.vertex.length == 3) {
          // Vertices
          final fanVertices = [
            vertices[face.vertex[0]],
            vertices[face.vertex[1]],
            vertices[face.vertex[2]],
          ];

          // Tex coords
          final fanTexCoords = <Vector2>[];
          if (face.texCoord.isNotEmpty) {
            for (final k in [0, 2, 1]) {
              final f = face.texCoord[k];
              if (f > -1) {
                final uv = texCoords[f];
                fanTexCoords.add(uv);
              }
            }
          }

          // Normals
          final fanNormals = [
            if (face.normal.isNotEmpty) ...[
              normals[face.normal[0]],
              normals[face.normal[1]],
              normals[face.normal[2]],
            ],
          ];

          surface.addTriangleFan(fanVertices, fanTexCoords, fanNormals);
        }
      }
      mesh = surface.apply(mesh);
    }
    return mesh;
  }

  Future<Map<String, SpatialMaterial>> _parseMaterial(
    String filePath,
  ) async {
    final lines = (await Flame.assets.readFile(filePath)).split('\n');

    final materials = <String, SpatialMaterial>{};
    SpatialMaterial? currentMat;
    for (final line in lines) {
      final [type, ...parts] = line.split(' ');
      switch (type) {
        // Comment
        case '#':
          continue;
        // Creating a new material
        case 'newmtl':
          currentMat = SpatialMaterial(
            albedoTexture: ColorTexture(const Color(0xFFFFFFFF)),
          );
          materials[parts[0].trim()] = currentMat;
        // Diffuse color
        case 'Kd':
          currentMat?.albedoColor = Color.from(
            alpha: 1.0,
            red: double.parse(parts[0]),
            green: double.parse(parts[1]),
            blue: double.parse(parts[2]),
          );
      }
    }
    return materials;
  }
}

class Face {
  const Face(this.vertex, this.texCoord, this.normal);

  final List<int> vertex;
  final List<int> texCoord;
  final List<int> normal;

  Face.empty() : vertex = [], texCoord = [], normal = [];
}
