import 'dart:js_interop';
import 'dart:typed_data';

@JS('navigator.gpu')
external GPU? get webGPU;

extension type GPU._(JSObject _) implements JSObject {
  Future<GPUAdapter?> requestAdapter([GPURequestAdapterOptions? options]) {
    return _requestAdapter(options ?? GPURequestAdapterOptions()).toDart;
  }

  @JS('requestAdapter')
  external JSPromise<GPUAdapter?> _requestAdapter([
    GPURequestAdapterOptions options,
  ]);
}

extension type GPURequestAdapterOptions._(JSObject _) implements JSObject {
  external factory GPURequestAdapterOptions({
    String powerPreference,
    bool forceFallbackAdapter,
  });
}

extension type GPUAdapter._(JSObject _) implements JSObject {
  Future<GPUDevice> requestDevice() {
    return _requestDevice().toDart;
  }

  @JS('requestDevice')
  external JSPromise<GPUDevice> _requestDevice();
}

extension type GPUDevice._(JSObject _) implements JSObject {
  external GPUQueue get queue;

  external GPUBuffer createBuffer(GPUBufferDescriptor descriptor);

  external GPUTexture createTexture(GPUTextureDescriptor descriptor);

  external GPUSampler createSampler(GPUSamplerDescriptor descriptor);

  external GPUShaderModule createShaderModule(
    GPUShaderModuleDescriptor descriptor,
  );

  external GPUBindGroup createBindGroup(GPUBindGroupDescriptor descriptor);

  external GPURenderPipeline createRenderPipeline(
    GPURenderPipelineDescriptor descriptor,
  );

  external GPUCommandEncoder createCommandEncoder();

  void addEventListener(
    String type,
    void Function(GPUUncapturedErrorEvent) listener,
  ) => _addEventListener(type, listener.toJS);

  @JS('addEventListener')
  external void _addEventListener(String type, JSFunction listener);
}

extension type GPUError._(JSObject _) implements JSObject {
  external String get message;
}

extension type GPUUncapturedErrorEvent._(JSObject _) implements JSObject {
  external GPUError get error;
}

extension type GPUQueue._(JSObject _) implements JSObject {
  void writeBuffer(GPUBuffer buffer, int bufferOffset, Uint8List data) =>
      _writeBuffer(buffer, bufferOffset, data.toJS);

  @JS('writeBuffer')
  external void _writeBuffer(
    GPUBuffer buffer,
    int bufferOffset,
    JSObject data,
  );

  void writeTexture(
    GPUImageCopyTexture destination,
    Uint8List data,
    GPUImageDataLayout dataLayout,
    GPUExtent3D size,
  ) => _writeTexture(destination, data.toJS, dataLayout, size);

  @JS('writeTexture')
  external void _writeTexture(
    GPUImageCopyTexture destination,
    JSObject data,
    GPUImageDataLayout dataLayout,
    GPUExtent3D size,
  );

  void submit(List<GPUCommandBuffer> commandBuffers) =>
      _submit(commandBuffers.toJS);

  @JS('submit')
  external void _submit(JSArray<GPUCommandBuffer> commandBuffers);
}

extension type GPUBuffer._(JSObject _) implements JSObject {
  external void destroy();
}

extension type GPUTexture._(JSObject _) implements JSObject {
  external GPUTextureView createView();

  external void destroy();
}

extension type GPUTextureView._(JSObject _) implements JSObject {}

extension type GPUSampler._(JSObject _) implements JSObject {}

extension type GPUShaderModule._(JSObject _) implements JSObject {}

extension type GPUBindGroupLayout._(JSObject _) implements JSObject {}

extension type GPUBindGroup._(JSObject _) implements JSObject {}

extension type GPURenderPipeline._(JSObject _) implements JSObject {
  external GPUBindGroupLayout getBindGroupLayout(int index);
}

extension type GPUCommandBuffer._(JSObject _) implements JSObject {}

extension type GPUCommandEncoder._(JSObject _) implements JSObject {
  external GPURenderPassEncoder beginRenderPass(
    GPURenderPassDescriptor descriptor,
  );

  external GPUCommandBuffer finish();
}

extension type GPURenderPassEncoder._(JSObject _) implements JSObject {
  external void setPipeline(GPURenderPipeline pipeline);

  external void setBindGroup(int index, GPUBindGroup bindGroup);

  external void setVertexBuffer(
    int slot,
    GPUBuffer buffer,
    int offset,
    int size,
  );

  external void setIndexBuffer(
    GPUBuffer buffer,
    String indexFormat,
    int offset,
    int size,
  );

  external void drawIndexed(int indexCount);

  external void end();
}

extension type GPUCanvasContext._(JSObject _) implements JSObject {
  external void configure(GPUCanvasConfiguration configuration);

  external GPUTexture getCurrentTexture();
}

extension type GPUBufferDescriptor._(JSObject _) implements JSObject {
  external factory GPUBufferDescriptor({
    int size,
    int usage,
    bool mappedAtCreation,
  });
}

extension type GPUExtent3D._(JSObject _) implements JSObject {
  external factory GPUExtent3D({
    int width,
    int height,
    int depthOrArrayLayers,
  });
}

extension type GPUTextureDescriptor._(JSObject _) implements JSObject {
  external factory GPUTextureDescriptor({
    GPUExtent3D size,
    String format,
    int usage,
  });
}

extension type GPUSamplerDescriptor._(JSObject _) implements JSObject {
  external factory GPUSamplerDescriptor({
    String magFilter,
    String minFilter,
    String addressModeU,
    String addressModeV,
  });
}

extension type GPUShaderModuleDescriptor._(JSObject _) implements JSObject {
  external factory GPUShaderModuleDescriptor({String code});
}

extension type GPUBufferBinding._(JSObject _) implements JSObject {
  external factory GPUBufferBinding({
    GPUBuffer buffer,
    int offset,
    int size,
  });
}

extension type GPUBindGroupEntry._(JSObject _) implements JSObject {
  external factory GPUBindGroupEntry({int binding, JSAny resource});
}

extension type GPUBindGroupDescriptor._(JSObject _) implements JSObject {
  factory GPUBindGroupDescriptor({
    required GPUBindGroupLayout layout,
    required List<GPUBindGroupEntry> entries,
  }) => GPUBindGroupDescriptor._raw(layout: layout, entries: entries.toJS);

  external factory GPUBindGroupDescriptor._raw({
    GPUBindGroupLayout layout,
    JSArray<GPUBindGroupEntry> entries,
  });
}

extension type GPUVertexAttribute._(JSObject _) implements JSObject {
  external factory GPUVertexAttribute({
    String format,
    int offset,
    int shaderLocation,
  });
}

extension type GPUVertexBufferLayout._(JSObject _) implements JSObject {
  factory GPUVertexBufferLayout({
    required int arrayStride,
    required String stepMode,
    required List<GPUVertexAttribute> attributes,
  }) => GPUVertexBufferLayout._raw(
    arrayStride: arrayStride,
    stepMode: stepMode,
    attributes: attributes.toJS,
  );

  external factory GPUVertexBufferLayout._raw({
    int arrayStride,
    String stepMode,
    JSArray<GPUVertexAttribute> attributes,
  });
}

extension type GPUVertexState._(JSObject _) implements JSObject {
  factory GPUVertexState({
    required GPUShaderModule module,
    required String entryPoint,
    required List<GPUVertexBufferLayout> buffers,
  }) => GPUVertexState._raw(
    module: module,
    entryPoint: entryPoint,
    buffers: buffers.toJS,
  );

  external factory GPUVertexState._raw({
    GPUShaderModule module,
    String entryPoint,
    JSArray<GPUVertexBufferLayout> buffers,
  });
}

extension type GPUBlendComponent._(JSObject _) implements JSObject {
  external factory GPUBlendComponent({
    String operation,
    String srcFactor,
    String dstFactor,
  });
}

extension type GPUBlendState._(JSObject _) implements JSObject {
  external factory GPUBlendState({
    GPUBlendComponent color,
    GPUBlendComponent alpha,
  });
}

extension type GPUColorTargetState._(JSObject _) implements JSObject {
  external factory GPUColorTargetState({String format, GPUBlendState blend});
}

extension type GPUFragmentState._(JSObject _) implements JSObject {
  factory GPUFragmentState({
    required GPUShaderModule module,
    required String entryPoint,
    required List<GPUColorTargetState> targets,
  }) => GPUFragmentState._raw(
    module: module,
    entryPoint: entryPoint,
    targets: targets.toJS,
  );

  external factory GPUFragmentState._raw({
    GPUShaderModule module,
    String entryPoint,
    JSArray<GPUColorTargetState> targets,
  });
}

extension type GPUPrimitiveState._(JSObject _) implements JSObject {
  external factory GPUPrimitiveState({
    String topology,
    String cullMode,
    String frontFace,
  });
}

extension type GPUDepthStencilState._(JSObject _) implements JSObject {
  external factory GPUDepthStencilState({
    String format,
    bool depthWriteEnabled,
    String depthCompare,
  });
}

extension type GPURenderPipelineDescriptor._(JSObject _) implements JSObject {
  factory GPURenderPipelineDescriptor({
    required String layout,
    required GPUVertexState vertex,
    required GPUFragmentState fragment,
    required GPUPrimitiveState primitive,
    required GPUDepthStencilState depthStencil,
  }) => GPURenderPipelineDescriptor._raw(
    layout: layout.toJS,
    vertex: vertex,
    fragment: fragment,
    primitive: primitive,
    depthStencil: depthStencil,
  );

  external factory GPURenderPipelineDescriptor._raw({
    JSAny layout,
    GPUVertexState vertex,
    GPUFragmentState fragment,
    GPUPrimitiveState primitive,
    GPUDepthStencilState depthStencil,
  });
}

extension type GPUColor._(JSObject _) implements JSObject {
  external factory GPUColor({double r, double g, double b, double a});
}

extension type GPURenderPassColorAttachment._(JSObject _) implements JSObject {
  external factory GPURenderPassColorAttachment({
    GPUTextureView view,
    GPUColor clearValue,
    String loadOp,
    String storeOp,
  });
}

extension type GPURenderPassDepthStencilAttachment._(JSObject _)
    implements JSObject {
  external factory GPURenderPassDepthStencilAttachment({
    GPUTextureView view,
    double depthClearValue,
    String depthLoadOp,
    String depthStoreOp,
  });
}

extension type GPURenderPassDescriptor._(JSObject _) implements JSObject {
  factory GPURenderPassDescriptor({
    required List<GPURenderPassColorAttachment> colorAttachments,
    required GPURenderPassDepthStencilAttachment depthStencilAttachment,
  }) => GPURenderPassDescriptor._raw(
    colorAttachments: colorAttachments.toJS,
    depthStencilAttachment: depthStencilAttachment,
  );

  external factory GPURenderPassDescriptor._raw({
    JSArray<GPURenderPassColorAttachment> colorAttachments,
    GPURenderPassDepthStencilAttachment depthStencilAttachment,
  });
}

extension type GPUImageCopyTexture._(JSObject _) implements JSObject {
  external factory GPUImageCopyTexture({GPUTexture texture});
}

extension type GPUImageDataLayout._(JSObject _) implements JSObject {
  external factory GPUImageDataLayout({
    int offset,
    int bytesPerRow,
    int rowsPerImage,
  });
}

extension type GPUCanvasConfiguration._(JSObject _) implements JSObject {
  external factory GPUCanvasConfiguration({
    GPUDevice device,
    String format,
    int usage,
    String alphaMode,
  });
}

extension type OffscreenCanvas._(JSObject _) implements JSObject {
  external factory OffscreenCanvas(int width, int height);

  external int get width;

  external int get height;

  external JSObject transferToImageBitmap();

  GPUCanvasContext contextGPU() => _getContext('webgpu')! as GPUCanvasContext;

  CanvasContext2D context2D() => _getContext('2d')! as CanvasContext2D;

  @JS('getContext')
  external JSObject? _getContext(String contextId);
}

extension type CanvasContext2D._(JSObject _) implements JSObject {
  external void drawImage(JSObject image, num dx, num dy);
}

abstract final class GPUBufferUsage {
  static const int copyDst = 0x0008;
  static const int index = 0x0010;
  static const int vertex = 0x0020;
  static const int uniform = 0x0040;
}

abstract final class GPUTextureUsage {
  static const int copyDst = 0x02;
  static const int textureBinding = 0x04;
  static const int renderAttachment = 0x10;
}
