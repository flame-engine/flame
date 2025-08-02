import 'package:flutter_gpu/gpu.dart' as gpu;

// TODO(luan): for now, we need to support both old (returns T?) and
//             newer (returns T!) versions of some Flutter GPU context methods.
class GpuContextWrapper {
  static final Map<gpu.GpuContext, GpuContextWrapper> _instances = {};

  final gpu.GpuContext _gpuContext;

  factory GpuContextWrapper(gpu.GpuContext gpuContext) {
    return _instances.putIfAbsent(
      gpuContext,
      () => GpuContextWrapper._(gpuContext),
    );
  }

  GpuContextWrapper._(this._gpuContext);

  gpu.Texture createTexture(
    gpu.StorageMode storageMode,
    int width,
    int height, {
    gpu.PixelFormat format = gpu.PixelFormat.r8g8b8a8UNormInt,
  }) {
    return unwrap(
      _gpuContext.createTexture(
        storageMode,
        width,
        height,
        format: format,
      ),
    );
  }

  gpu.DeviceBuffer createDeviceBuffer(
    gpu.StorageMode storageMode,
    int sizeInBytes,
  ) {
    return unwrap(_gpuContext.createDeviceBuffer(storageMode, sizeInBytes));
  }

  static T unwrap<T>(T? t) {
    return t!;
  }
}
