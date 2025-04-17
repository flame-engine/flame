import 'dart:async';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:meta/meta.dart';

abstract class PostProcess {
  PostProcess({double? pixelRatio})
      : pixelRatio = pixelRatio ??
            PlatformDispatcher.instance.views.first.devicePixelRatio;

  double pixelRatio;

  FutureOr<void> onLoad() {}

  void update(double dt) {}

  void Function(Canvas)? _renderTree;
  void Function(PostProcessRenderContext?)? _updateContext;
  Vector2? _size;

  @internal
  void render(
    Canvas canvas,
    Vector2 size,
    void Function(Canvas) renderTree,
    void Function(PostProcessRenderContext?) updateContext,
  ) {
    _renderTree = renderTree;
    _updateContext = updateContext;
    _size = size;

    canvas.save();
    postProcess(size, canvas);
    canvas.restore();

    _size = null;
    _renderTree = null;
    _updateContext = null;
  }

  @nonVirtual
  @protected
  ui.Image rasterizeSubtree() {
    final recorder = PictureRecorder();

    final innerCanvas = Canvas(recorder);

    renderSubtree(innerCanvas);

    final picture = recorder.endRecording();

    return picture.toImageSync(
      (pixelRatio * _size!.x).ceil(),
      (pixelRatio * _size!.y).ceil(),
    );
  }

  @nonVirtual
  @protected
  void renderSubtree(Canvas canvas) {
    canvas.save();
    _updateContext!(
      PostProcessRenderContext(postProcess: this),
    );
    _renderTree!(canvas);
    _updateContext!(null);
    canvas.restore();
  }

  void postProcess(Vector2 size, Canvas canvas) {
    renderSubtree(canvas);
  }
}

class PostProcessGroup extends PostProcess {
  PostProcessGroup({
    required this.postProcesses,
  });

  final List<PostProcess> postProcesses;

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
    var renderTreeCurrent = renderTree;
    for (final postProcess in postProcesses) {
      final renderTree = renderTreeCurrent;
      void renderTreeNext(Canvas canvas) {
        postProcess.render(canvas, size, renderTree, updateContext);
      }

      renderTreeCurrent = renderTreeNext;
    }

    canvas.save();
    renderTreeCurrent(canvas);
    canvas.restore();
  }
}
