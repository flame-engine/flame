import 'dart:async';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:meta/meta.dart';

abstract class PostProcess {
  PostProcess({double? pixelRatio})
      : pixelRatio = pixelRatio ??
            PlatformDispatcher.instance.views.first.devicePixelRatio;

  double pixelRatio;

  int get samplingPasses;

  FutureOr<void> onLoad() {}

  void update(double dt) {}

  void render(
    Canvas canvas,
    Vector2 size,
    void Function(Canvas) renderTree,
    void Function(PostProcessRenderContext?) updateContext,
  ) {
    // Pre-render children as much as necessary
    final results = List<ui.Image>.generate(
      samplingPasses,
      (i) {
        return _renderAndRecord(size, i, renderTree, updateContext);
      },
    );

    canvas.save();
    postProcess(results, size, canvas);
    canvas.restore();
  }

  ui.Image _renderAndRecord(
    Vector2 size,
    int pass,
    void Function(Canvas) renderTree,
    void Function(PostProcessRenderContext?) updateContext,
  ) {
    final recorder = PictureRecorder();

    final innerCanvas = Canvas(recorder);

    updateContext(
      PostProcessRenderContext(
        postProcess: this,
        passIndex: pass,
      ),
    );
    renderTree(innerCanvas);
    updateContext(null);

    final picture = recorder.endRecording();

    return picture.toImageSync(
      (pixelRatio * size.x).ceil(),
      (pixelRatio * size.y).ceil(),
    );
  }

  void postProcess(List<ui.Image> samples, Vector2 size, Canvas canvas);
}

class PostProcessGroup extends PostProcess {
  PostProcessGroup({
    required this.postProcesses,
  });

  final List<PostProcess> postProcesses;

  @override
  int get samplingPasses => 1;

  @override
  Future<void> onLoad() async {
    for (final postProcess in postProcesses) {
      await postProcess.onLoad();
    }
  }

  @override
  void update(double dt) {
    for (final postProcess in postProcesses) {
      postProcess.update(dt);
    }
  }

  @override
  void render(
    Canvas canvas,
    Vector2 size,
    void Function(Canvas) renderTree,
    void Function(PostProcessRenderContext?) updateContext,
  ) {
    for (final postProcess in postProcesses) {
      postProcess.render(canvas, size, renderTree, updateContext);
    }
  }

  @override
  void postProcess(List<ui.Image> samples, Vector2 size, Canvas canvas) {}
}

class PostProcessSequentialGroup extends PostProcessGroup {
  PostProcessSequentialGroup({
    required super.postProcesses,
  });

  @override
  void render(
    Canvas canvas,
    Vector2 size,
    void Function(Canvas) renderTree,
    void Function(PostProcessRenderContext?) updateContext,
  ) {
    var currentRenderTree = renderTree;
    for (final (index, postProcess) in postProcesses.indexed) {
      assert(
        postProcess.samplingPasses >= 1 && index > 0,
        'PostProcessSequentialGroup has a PostProcess with no sampling passes.'
        ' This is only acceptable for the first post process in the group.'
        ' Otherwise, this post process will discard the results of the'
        ' previous ones.\n'
        'Consider using PostProcessGroup instead.\n'
        'Offending PostProcess:'
        ' $postProcess',
      );
      currentRenderTree = (canvas) {
        postProcess.render(canvas, size, currentRenderTree, updateContext);
      };
    }

    currentRenderTree(canvas);
  }
}

/// A [PositionComponent] that applies a post-processing effect to its children.
/// This component is useful for applying effects such as bloom, blur, other
/// fragment shader effects to a group of components.
class PostProcessComponent<T extends PostProcess> extends PositionComponent {
  PostProcessComponent({
    required this.postProcess,
    super.position,
    super.size,
    super.scale,
    super.angle,
    double? nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : super(
          nativeAngle: nativeAngle ?? 0,
        );

  @override
  PostProcessRenderContext? get renderContext => _renderContext;

  PostProcessRenderContext? _renderContext;

  final T postProcess;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await postProcess.onLoad();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    postProcess.update(dt);
  }

  @override
  @mustCallSuper
  void renderTree(Canvas canvas) {
    decorator.applyChain(
      (canvas) {
        postProcess.render(
          canvas,
          size,
          super.renderTree,
          (context) {
            _renderContext = context;
          },
        );
      },
      canvas,
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

extension PostProcessingContextFinder on Component {
  PostProcessRenderContext<T>? findPostProcessContext<T extends PostProcess>() {
    final closestContext = findRenderContext<PostProcessRenderContext<T>>();
    if (closestContext != null) {
      return closestContext;
    }
    final contextInCamera =
        findRenderContext<CameraRenderContext>()?.currentPostProcessContext;
    if (contextInCamera is PostProcessRenderContext<T>) {
      return contextInCamera;
    }

    return null;
  }
}
