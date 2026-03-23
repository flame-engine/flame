import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/joints_info.dart';

class RenderContext3D extends RenderContext {
  RenderContext3D(super.device);

  Matrix4 get model => _modelMatrix;
  final Matrix4 _modelMatrix = Matrix4.zero();

  Matrix4 get view => _viewMatrix;
  final Matrix4 _viewMatrix = Matrix4.zero();

  Matrix4 get projection => _projectionMatrix;
  final Matrix4 _projectionMatrix = Matrix4.zero();

  /// Camera world-space position, precomputed from the view matrix.
  /// Set once per frame via [setCamera], avoids repeated matrix inversions.
  Vector3 get cameraPosition => _cameraPosition;
  final Vector3 _cameraPosition = Vector3.zero();

  final JointsInfo jointsInfo = JointsInfo();

  final LightingInfo lightingInfo = LightingInfo();

  final _drawPool = <_DrawEntry>[];
  int _drawCount = 0;

  /// Set camera matrices for this frame.
  void setCamera(Matrix4 viewMatrix, Matrix4 projectionMatrix) {
    _viewMatrix.setFrom(viewMatrix);
    _projectionMatrix.setFrom(projectionMatrix);
    _cameraPosition.setFrom(
      Matrix4.inverted(viewMatrix).transform3(Vector3.zero()),
    );
  }

  /// Submit a deferred draw.
  void submitDraw(Object3D object, Matrix4 worldTransform) {
    // Distance for each object in world space. We dont use
    // Vector3 here as that would be unnecessarily allocating
    // values.
    final dx = _cameraPosition.x - worldTransform.storage[12];
    final dy = _cameraPosition.y - worldTransform.storage[13];
    final dz = _cameraPosition.z - worldTransform.storage[14];

    if (_drawCount >= _drawPool.length) {
      _drawPool.add(_DrawEntry());
    }
    _drawPool[_drawCount]
      ..distance = dx * dx + dy * dy + dz * dz
      ..object = object;
    _drawCount++;
  }

  /// Sort and execute all deferred draws (back-to-front for alpha blending).
  void flush() {
    for (var i = 1; i < _drawCount; i++) {
      final entry = _drawPool[i];
      var j = i - 1;
      while (j >= 0 && _drawPool[j].distance < entry.distance) {
        _drawPool[j + 1] = _drawPool[j];
        j--;
      }
      _drawPool[j + 1] = entry;
    }

    // Draw and then release the objects in the draw pool.
    for (var i = 0; i < _drawCount; i++) {
      _drawPool[i].object!.draw(this);
      _drawPool[i].object = null;
    }
    _drawCount = 0;
  }

  void drawMesh(Mesh mesh) {
    mesh.draw(this);
  }

  void drawSurface(Surface surface) {
    device.clearBindings();
    applyMaterial(surface.material);
    device.bindGeometry(surface);
  }

  void applyMaterial(Material material) {
    device.bindPipeline(material.resource, material.cullMode);
    material.apply(this);
    material.vertexShader.bind(device);
    material.fragmentShader.bind(device);
  }
}

class _DrawEntry {
  double distance = 0;
  Object3D? object;
}
