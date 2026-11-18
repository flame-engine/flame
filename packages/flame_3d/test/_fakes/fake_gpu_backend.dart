import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// A [GpuBackend] that records what is created, bound and drawn, for tests
/// that do not need pixels.
///
/// Slots whose name ends in `Texture` or `Map` are samplers, the others
/// uniform blocks of [blockSize] bytes whose members are laid out at
/// 1024-byte intervals in the order they are first asked for.
final class FakeGpuBackend({
  /// The vertex inputs every vertex shader reports, or `null` for none.
  final List<GpuShaderInput>? inputs,

  /// The size of every uniform block not in [blockSizes].
  final int blockSize = 8192,

  /// The size of uniform blocks, by name.
  final Map<String, int> blockSizes = const {},
  final int uniformAlignmentInBytes = 256,

  /// Whether it creates texture targets, see [supportsTextureTargets].
  final bool textureTargets = false,

  /// Whether its texture targets can be 32-bit floats.
  final bool floatTextureTargets = true,
}) extends GpuBackend {
  @override
  int get uniformAlignment => uniformAlignmentInBytes;

  /// Every recorded command, in order, as text (e.g. `drawIndexed 6 x3`).
  final List<String> commands = [];

  /// Every buffer created.
  final List<FakeBuffer> buffers = [];

  /// Every render target created, as (width, height, sample count).
  final List<(int, int, int)> renderTargets = [];

  /// Every pipeline created.
  final List<FakePipeline> pipelines = [];

  /// Where each uniform slot was last bound, by slot name.
  final Map<String, (FakeBuffer, int, int)> uniformBindings = {};

  /// The texture and sampler each sampler slot was last bound to, by slot
  /// name.
  final Map<String, (FakeTexture, TextureSampler)> textureBindings = {};

  /// The data most recently bound to each uniform slot, by slot name.
  ///
  /// Uniform data is uploaded when the pass ends, so read it after that.
  Map<String, Float32List> get uniforms => {
    for (final MapEntry(:key, value: (buffer, offset, length))
        in uniformBindings.entries)
      key: Float32List.fromList(
        buffer.contents.buffer.asFloat32List(offset, length ~/ 4),
      ),
  };

  /// The instance data of every draw, as (buffer, offset, count). The data is
  /// uploaded when the pass ends, so read it after that.
  final List<(FakeBuffer, int, int)> drawnInstances = [];

  /// The instance floats of the draw at [draw] in [drawnInstances].
  List<Float32List> instancesOf(int draw) {
    final (buffer, offset, count) = drawnInstances[draw];
    return [
      for (var i = 0; i < count; i++)
        buffer.contents.buffer.asFloat32List(
          offset + i * VertexLayout.instanceStrideInFloats * 4,
          VertexLayout.instanceStrideInFloats,
        ),
    ];
  }

  /// Callbacks of submitted passes waiting for completion.
  final List<void Function()> pendingCompletions = [];

  /// Whether submitted passes complete immediately.
  bool completeImmediately = false;

  final Map<String, FakeShaderLibrary> _libraries = {};

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    return _libraries.putIfAbsent(assetName, () => FakeShaderLibrary(this));
  }

  /// Every texture created.
  final List<FakeTexture> textures = [];

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
    int mipLevelCount = 1,
  }) {
    final texture = FakeTexture(width, height, mipLevelCount);
    textures.add(texture);
    return texture;
  }

  /// What [maxMipLevelCount] returns, or `null` for the default.
  int? maxMipLevels;

  @override
  int maxMipLevelCount(int width, int height) =>
      maxMipLevels ?? super.maxMipLevelCount(width, height);

  @override
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  }) {
    final buffer = FakeBuffer(sizeInBytes);
    buffers.add(buffer);
    return buffer;
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
    GpuVertexLayout? vertexLayout,
  }) {
    final pipeline = FakePipeline(
      vertexShader as FakeShader,
      fragmentShader as FakeShader,
      vertexLayout,
    );
    pipelines.add(pipeline);
    return pipeline;
  }

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
    int msaaSampleCount = 1,
  }) {
    renderTargets.add((width, height, msaaSampleCount));
    return FakeRenderTarget(width, height);
  }

  @override
  bool get supportsTextureTargets => textureTargets;

  @override
  bool get supportsFloatTextureTargets => floatTextureTargets;

  /// Every texture target created, as (width, height, format).
  final List<(int, int, GpuPixelFormat)> textureTargetsCreated = [];

  @override
  GpuTextureTarget createTextureTarget({
    required int width,
    required int height,
    required GpuPixelFormat format,
    required Color clearValue,
  }) {
    if (!textureTargets) {
      return super.createTextureTarget(
        width: width,
        height: height,
        format: format,
        clearValue: clearValue,
      );
    }
    textureTargetsCreated.add((width, height, format));
    final texture = FakeTexture(width, height, 1);
    textures.add(texture);
    return FakeTextureTarget(width, height, format, texture);
  }

  @override
  GpuFrame beginFrame() => FakeFrame(this);

  /// Completes every submitted pass.
  void completePasses() {
    final callbacks = List.of(pendingCompletions);
    pendingCompletions.clear();
    for (final callback in callbacks) {
      callback();
    }
  }

  /// The number of recorded commands starting with [prefix].
  int countCommands(String prefix) {
    return commands.where((c) => c.startsWith(prefix)).length;
  }
}

class FakeShaderLibrary(final FakeGpuBackend backend)
    implements GpuShaderLibrary {
  final Map<String, FakeShader> _shaders = {};

  @override
  GpuShader operator [](String entryPoint) {
    return _shaders.putIfAbsent(
      entryPoint,
      () => FakeShader(
        backend,
        entryPoint,
        entryPoint == 'TextureVertex' ? backend.inputs : const [],
      ),
    );
  }
}

class FakeShader(
  final FakeGpuBackend backend,
  final String entryPoint,
  @override final List<GpuShaderInput>? inputs,
) implements GpuShader {
  final Map<String, GpuUniformSlot> _slots = {};

  @override
  GpuUniformSlot getUniformSlot(String slot) {
    return _slots.putIfAbsent(
      slot,
      () => slot.endsWith('Texture') || slot.endsWith('Map')
          ? FakeSamplerSlot(slot)
          : FakeUniformSlot(
              slot,
              backend.blockSizes[slot] ?? backend.blockSize,
            ),
    );
  }

  @override
  String toString() => 'FakeShader($entryPoint)';
}

class FakeSamplerSlot(@override final String name) implements GpuUniformSlot {
  @override
  int? get sizeInBytes => null;

  @override
  int? getMemberOffsetInBytes(String member) => null;
}

class FakeUniformSlot(
  @override final String name,
  @override final int sizeInBytes,
) implements GpuUniformSlot {
  final Map<String, int> _offsets = {};

  /// Members that do not exist in the block.
  final Set<String> missing = {};

  @override
  int? getMemberOffsetInBytes(String member) {
    if (missing.contains(member)) {
      return null;
    }
    return _offsets.putIfAbsent(member, () => _offsets.length * 1024);
  }
}

class FakeTexture(
  final int width,
  final int height,
  @override final int mipLevelCount,
) implements GpuTexture {
  /// Every write, as (mip level, bytes).
  final List<(int, Uint8List)> writes = [];

  @override
  Image asImage() => throw UnimplementedError();

  @override
  void write(ByteData data, {int mipLevel = 0}) {
    writes.add((
      mipLevel,
      Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    ));
  }
}

class FakeBuffer(@override final int sizeInBytes) implements GpuBuffer {
  late final Uint8List contents = Uint8List(sizeInBytes);

  /// Every write, as (offset, bytes).
  final List<(int, Uint8List)> writes = [];

  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    final bytes = Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    writes.add((destinationOffsetInBytes, bytes));
    contents.setRange(
      destinationOffsetInBytes,
      destinationOffsetInBytes + bytes.length,
      bytes,
    );
  }
}

class FakePipeline(
  final FakeShader vertexShader,
  final FakeShader fragmentShader,
  final GpuVertexLayout? vertexLayout,
) implements GpuPipeline;

class FakeRenderTarget(
  @override final int width,
  @override final int height,
) implements GpuRenderTarget;

class FakeTextureTarget(
  @override final int width,
  @override final int height,
  @override final GpuPixelFormat format,
  @override final FakeTexture texture,
) implements GpuTextureTarget;

class FakeFrame(final FakeGpuBackend backend) implements GpuFrame {
  @override
  GpuRenderPass beginRenderPass(GpuRenderTarget target) {
    backend.commands.add('beginRenderPass ${target.width}x${target.height}');
    return FakeRenderPass(backend);
  }

  @override
  void end() {}
}

class FakeRenderPass(final FakeGpuBackend backend) implements GpuRenderPass {
  List<String> get _commands => backend.commands;

  // Where the instance buffer (slot 1) is bound.
  FakeBuffer? _instanceBuffer;
  int _instanceOffset = 0;

  @override
  void bindPipeline(GpuPipeline pipeline) {
    _commands.add(
      'bindPipeline ${backend.pipelines.indexOf(pipeline as FakePipeline)}',
    );
  }

  @override
  void setBlendState(BlendState blend) =>
      _commands.add('setBlendState ${blend.name}');

  @override
  void setDepthState({
    required CompareFunction compare,
    required bool writeEnabled,
  }) => _commands.add('setDepthState ${compare.name} $writeEnabled');

  @override
  void setCullMode(CullMode cullMode) =>
      _commands.add('setCullMode ${cullMode.name}');

  @override
  void setWindingOrder(WindingOrder windingOrder) =>
      _commands.add('setWindingOrder ${windingOrder.name}');

  @override
  void bindVertexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    int slot = 0,
  }) {
    if (slot == 1) {
      _instanceBuffer = buffer as FakeBuffer;
      _instanceOffset = offsetInBytes;
    }
    _commands.add('bindVertexBuffer $slot $lengthInBytes');
  }

  @override
  void bindIndexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    required GpuIndexType indexType,
  }) => _commands.add('bindIndexBuffer ${indexType.name}');

  @override
  void bindUniform(
    GpuUniformSlot slot,
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
  }) {
    if (offsetInBytes % backend.uniformAlignment != 0) {
      throw StateError('Misaligned uniform offset $offsetInBytes');
    }
    backend.uniformBindings[slot.name] = (
      buffer as FakeBuffer,
      offsetInBytes,
      lengthInBytes,
    );
    _commands.add('bindUniform ${slot.name}');
  }

  @override
  void bindTexture(
    GpuUniformSlot slot,
    GpuTexture texture, {
    TextureSampler sampler = TextureSampler.nearest,
  }) {
    backend.textureBindings[slot.name] = (texture as FakeTexture, sampler);
    _commands.add('bindTexture ${slot.name}');
  }

  @override
  void clearBindings() => _commands.add('clearBindings');

  @override
  void draw(int vertexCount, {int instanceCount = 1}) =>
      _commands.add('draw $vertexCount x$instanceCount');

  @override
  void drawIndexed(int indexCount, {int instanceCount = 1}) {
    final buffer = _instanceBuffer;
    if (buffer != null) {
      backend.drawnInstances.add((buffer, _instanceOffset, instanceCount));
    }
    _commands.add('drawIndexed $indexCount x$instanceCount');
  }

  @override
  Image submit({void Function()? onCompleted}) {
    _commands.add('submit');
    _complete(onCompleted);
    return _FakeImage();
  }

  @override
  void commit({void Function()? onCompleted}) {
    _commands.add('commit');
    _complete(onCompleted);
  }

  void _complete(void Function()? onCompleted) {
    if (onCompleted != null) {
      if (backend.completeImmediately) {
        onCompleted();
      } else {
        backend.pendingCompletions.add(onCompleted);
      }
    }
  }
}

class _FakeImage() implements Image {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
