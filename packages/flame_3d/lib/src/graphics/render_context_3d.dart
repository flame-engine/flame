import 'package:flame/extensions.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/joints_info.dart';

/// The sub-pass that [RenderContext3D.flush] is currently drawing.
enum PassKind() {
  /// No blending, depth write on.
  opaque,

  /// Depth-only pass for [Transparency.alphaDepthPrePass] materials.
  depthPrePass,

  /// Alpha blending, depth read only.
  blend,
}

class RenderContext3D(super.device) extends RenderContext {
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

  /// Must be set by the rendering pipeline before elements are bound.
  /// Can be accessed by elements in their bind method.
  Iterable<Light> lights = [];

  /// The sub-pass currently being drawn.
  PassKind get passKind => _passKind;
  PassKind _passKind = PassKind.opaque;

  bool _mirrored = false;

  final _drawPool = <_SurfaceDrawEntry>[];
  int _drawCount = 0;

  int get drawCount => _lastDrawCount;
  int _lastDrawCount = 0;

  /// Set camera matrices for this frame.
  void setCamera(Matrix4 viewMatrix, Matrix4 projectionMatrix) {
    _viewMatrix.setFrom(viewMatrix);
    _projectionMatrix.setFrom(projectionMatrix);
    _cameraPosition.setFrom(
      Matrix4.inverted(viewMatrix).transform3(Vector3.zero()),
    );
  }

  /// Queue each surface of [mesh] for drawing in [flush].
  ///
  /// [jointsPerSurface] maps a surface index to its joint transforms.
  void submitMesh(
    Mesh mesh,
    Matrix4 worldTransform, {
    Map<int, List<Matrix4>>? jointsPerSurface,
  }) {
    // Squared distance from the mesh origin, without Vector3 allocations.
    final dx = _cameraPosition.x - worldTransform.m41;
    final dy = _cameraPosition.y - worldTransform.m42;
    final dz = _cameraPosition.z - worldTransform.m43;
    final distance = dx * dx + dy * dy + dz * dz;
    final mirrored = worldTransform.determinant() < 0;

    for (final (index, surface) in mesh.surfaces.indexed) {
      if (_drawCount >= _drawPool.length) {
        _drawPool.add(_SurfaceDrawEntry());
      }
      _drawPool[_drawCount++]
        ..transform.setFrom(worldTransform)
        ..surface = surface
        ..joints = jointsPerSurface?[index]
        ..distance = distance
        ..mirrored = mirrored
        ..blended = surface.material.isBlended;
    }
  }

  /// Draw all queued surfaces.
  ///
  /// Opaque surfaces draw first, front-to-back. Blended surfaces draw last,
  /// back-to-front, after a depth-only pass for
  /// [Transparency.alphaDepthPrePass] surfaces.
  void flush() {
    _sort();
    var blendStart = 0;
    while (blendStart < _drawCount && !_drawPool[blendStart].blended) {
      blendStart++;
    }

    _passKind = PassKind.opaque;
    device.setPassState(BlendState.opaque, DepthStencilState.standard);
    for (var i = 0; i < blendStart; i++) {
      _execute(_drawPool[i]);
    }

    if (blendStart < _drawCount) {
      _passKind = PassKind.depthPrePass;
      device.setPassState(BlendState.noColor, DepthStencilState.standard);
      for (var i = blendStart; i < _drawCount; i++) {
        final entry = _drawPool[i];
        if (entry.surface!.material.transparency ==
            Transparency.alphaDepthPrePass) {
          _execute(entry);
        }
      }

      _passKind = PassKind.blend;
      device.setPassState(BlendState.alphaBlend, DepthStencilState.depthRead);
      for (var i = blendStart; i < _drawCount; i++) {
        _execute(_drawPool[i]);
      }
    }

    for (var i = 0; i < _drawCount; i++) {
      _drawPool[i]
        ..surface = null
        ..joints = null;
    }
    _lastDrawCount = _drawCount;
    _drawCount = 0;
  }

  /// Stable insertion sort: opaque before blended, then by
  /// [Material.renderPriority], then front-to-back for opaque and
  /// back-to-front for blended.
  void _sort() {
    for (var i = 1; i < _drawCount; i++) {
      final entry = _drawPool[i];
      var j = i - 1;
      while (j >= 0 && _compare(_drawPool[j], entry) > 0) {
        _drawPool[j + 1] = _drawPool[j];
        j--;
      }
      _drawPool[j + 1] = entry;
    }
  }

  static int _compare(_SurfaceDrawEntry a, _SurfaceDrawEntry b) {
    if (a.blended != b.blended) {
      return a.blended ? 1 : -1;
    }
    final priority = a.surface!.material.renderPriority.compareTo(
      b.surface!.material.renderPriority,
    );
    if (priority != 0) {
      return priority;
    }
    return a.blended
        ? b.distance.compareTo(a.distance)
        : a.distance.compareTo(b.distance);
  }

  void _execute(_SurfaceDrawEntry entry) {
    _mirrored = entry.mirrored;
    _modelMatrix.setFrom(entry.transform);
    jointsInfo.jointTransforms = entry.joints ?? const [];
    drawSurface(entry.surface!);
  }

  void drawSurface(Surface surface) {
    device.clearBindings();
    applyMaterial(surface.material);
    device.bindGeometry(surface);
  }

  void applyMaterial(Material material) {
    device.bindPipeline(material.resource, _cullMode(material.cullMode));
    material.apply(this);
    material.vertexShader.bind(device);
    material.fragmentShader.bind(device);
  }

  // A mirrored transform reverses the winding, so the culled face swaps.
  CullMode _cullMode(CullMode mode) => switch (mode) {
    CullMode.frontFace when _mirrored => CullMode.backFace,
    CullMode.backFace when _mirrored => CullMode.frontFace,
    _ => mode,
  };
}

class _SurfaceDrawEntry() {
  final Matrix4 transform = Matrix4.zero();
  Surface? surface;
  List<Matrix4>? joints;
  double distance = 0;
  bool blended = false;
  bool mirrored = false;
}
