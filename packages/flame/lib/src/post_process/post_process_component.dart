import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:meta/meta.dart';

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
  PostProcessComponentRenderContext<T> get renderContext => _renderContext;

  final _renderContext =
      PostProcessComponentRenderContext<T>(postProcess: null);

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
            _renderContext.postProcess =  postProcess;
          },
        );
      },
      canvas,
    );
  }
}

class PostProcessComponentRenderContext<T extends PostProcess>
    extends ComponentRenderContext {
  PostProcessComponentRenderContext({
    required this.postProcess,
  });

  T? postProcess;
}

extension PostProcessingContextFinder on Component {
  T? findPostProcessFromContext<T extends PostProcess>() {
    final closestContext =
        findRenderContext<PostProcessComponentRenderContext<T>>();
    if (closestContext != null) {
      return closestContext.postProcess;
    }
    final contextInCamera =
        findRenderContext<CameraRenderContext>()?.currentPostProcess;
    if (contextInCamera is T) {
      return contextInCamera;
    }

    return null;
  }
}
