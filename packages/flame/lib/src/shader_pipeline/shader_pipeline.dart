import 'dart:async';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:meta/meta.dart';

abstract class PostProcess {
  const PostProcess();

  int get samplingPasses;

  Future<void> onLoad();

  void update(double dt) {}

  void postProcess(List<ui.Image> samples, Vector2 size, Canvas canvas);
}

abstract class FragmentShaderPostProcess extends PostProcess {
  Future<FragmentProgram> fragmentProgramLoader();

  late FragmentShader fragmentShader;

  @override
  Future<void> onLoad() async {
    final fragmentProgram = await fragmentProgramLoader();
    fragmentShader = fragmentProgram.fragmentShader();
  }

  Paint getPaint() => Paint()..shader = fragmentShader;

  @override
  int get samplingPasses => 1;

  @override
  void postProcess(List<ui.Image> samples, Vector2 size, Canvas canvas) {
    canvas
      ..save()
      ..drawRect(Offset.zero & size.toSize(), getPaint())
      ..restore();
  }
}

/// A [PositionComponent] that applies a post-processing effect to its children.
/// This component is useful for applying effects such as bloom, blur, other
/// fragment shader effects to a group of components.
class PostProcessComponent<T extends PostProcess> extends PositionComponent {
  PostProcessComponent({
    required this.postProcess,
    double? pixelRatio,
    super.position,
    super.size,
    super.scale,
    super.angle,
    double? nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  })  : pixelRatio = pixelRatio ??
            PlatformDispatcher.instance.views.first.devicePixelRatio,
        super(
          nativeAngle: nativeAngle ?? 0,
        );

  @override
  PostProcessRenderContext<T> get renderContext => _renderContext;

  late final PostProcessRenderContext<T> _renderContext =
      PostProcessRenderContext<T>(
    postProcess: postProcess,
    passIndex: 0,
  );

  final T postProcess;
  final double pixelRatio;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await postProcess.onLoad();
    return super.onLoad();
  }

  @override
  @mustCallSuper
  void renderTree(Canvas canvas) {
    decorator.applyChain(
      (canvas) {
        // Pre-render children as much as necessary
        final results = List<ui.Image>.generate(
          postProcess.samplingPasses,
          (i) {
            return _renderAndRecord(size, i, pixelRatio);
          },
        );

        canvas.save();
        postProcess.postProcess(results, size, canvas);
        canvas.restore();
      },
      canvas,
    );
  }

  ui.Image _renderAndRecord(Vector2 size, int pass, double pixelRatio) {
    final recorder = PictureRecorder();

    final innerCanvas = Canvas(recorder);

    // update context before rendering children
    _renderContext.passIndex = pass;
    super.renderTree(innerCanvas);

    final picture = recorder.endRecording();

    return picture.toImageSync(
      (pixelRatio * size.x).ceil(),
      (pixelRatio * size.y).ceil(),
    );
  }
}

class PostProcessRenderContext<T extends PostProcess>
    extends ComponentRenderContext {
  PostProcessRenderContext({
    required this.postProcess,
    required this.passIndex,
  });

  final T postProcess;
  int passIndex;
}

extension PostProcessingContext on Component {
  PostProcessRenderContext<T>? findPostProcessContext<T extends PostProcess>() {
    return findRenderContext<PostProcessRenderContext<T>>();
  }
}
