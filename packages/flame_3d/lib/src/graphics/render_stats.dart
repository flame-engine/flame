/// {@template render_stats}
/// Counters of the GPU work recorded during one frame.
///
/// A `GraphicsDevice` resets its live counters when a frame begins and copies
/// them into its last-frame statistics when the frame ends, so the statistics
/// of the last complete frame can be read at any time (for example from a
/// game's `renderStats`).
/// {@endtemplate}
class RenderStats() {
  /// The number of render passes.
  int renderPasses = 0;

  /// The number of draw calls issued to the GPU (an instanced draw counts
  /// once).
  int drawCalls = 0;

  /// The number of instances drawn, summed over all draw calls.
  int instances = 0;

  /// The number of triangles drawn, summed over all instances.
  int triangles = 0;

  /// The number of times a different pipeline was bound.
  int pipelineChanges = 0;

  /// The number of render state changes applied: each change of the blend
  /// state, the depth state, the cull mode or the winding order counts once.
  int stateChanges = 0;

  /// The number of times the bound material changed.
  int materialChanges = 0;

  /// The number of uniform blocks uploaded to the GPU.
  int uniformUploads = 0;

  /// The number of bytes of uniform and instance data uploaded.
  int uploadedBytes = 0;

  /// The number of particles drawn by particle systems (a mesh particle
  /// counts once, however many surfaces its mesh has).
  int particles = 0;

  /// The number of the [renderPasses] that rendered a shadow map.
  int shadowPasses = 0;

  /// The number of the [drawCalls] issued by the passes that rendered a
  /// shadow map.
  int shadowDrawCalls = 0;

  /// Resets every counter to zero.
  void reset() {
    renderPasses = 0;
    drawCalls = 0;
    instances = 0;
    triangles = 0;
    pipelineChanges = 0;
    stateChanges = 0;
    materialChanges = 0;
    uniformUploads = 0;
    uploadedBytes = 0;
    particles = 0;
    shadowPasses = 0;
    shadowDrawCalls = 0;
  }

  /// Copies every counter from [other].
  void setFrom(RenderStats other) {
    renderPasses = other.renderPasses;
    drawCalls = other.drawCalls;
    instances = other.instances;
    triangles = other.triangles;
    pipelineChanges = other.pipelineChanges;
    stateChanges = other.stateChanges;
    materialChanges = other.materialChanges;
    uniformUploads = other.uniformUploads;
    uploadedBytes = other.uploadedBytes;
    particles = other.particles;
    shadowPasses = other.shadowPasses;
    shadowDrawCalls = other.shadowDrawCalls;
  }

  @override
  String toString() {
    return 'RenderStats(passes: $renderPasses, drawCalls: $drawCalls, '
        'instances: $instances, triangles: $triangles, '
        'pipelineChanges: $pipelineChanges, stateChanges: $stateChanges, '
        'materialChanges: $materialChanges, uniformUploads: $uniformUploads, '
        'uploadedBytes: $uploadedBytes, particles: $particles, '
        'shadowPasses: $shadowPasses, shadowDrawCalls: $shadowDrawCalls)';
  }
}
