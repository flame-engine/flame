/// {@template resource}
/// Base lazy GPU resource wrapper (`GpuBuffer`, `GpuTexture`, `GpuShader`).
/// {@endtemplate}
abstract class Resource<R>() {
  R? _resource;
  bool recreateResource = true;

  /// Whether a live GPU resource is currently allocated and up to date.
  bool get hasResource => _resource != null && !recreateResource;

  R createResource();

  R get resource {
    if (recreateResource || _resource == null) {
      _resource = createResource();
      recreateResource = false;
    }
    return _resource!;
  }

  /// Releases the cached GPU handle so it can be reclaimed (and lazily
  /// recreated if accessed again).
  void dispose() {
    _resource = null;
    recreateResource = true;
  }
}
