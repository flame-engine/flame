import 'dart:async';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A way to apply effects to a whole component tree.
///
/// This is specially useful for applying effects based on [FragmentShader]s.
///
/// Post processes are created by sub-classing  and implementing the
/// [postProcess] method.
///
/// Within the [postProcess] method, you can use the [renderSubtree] method
/// to render the component tree. This method will take care of setting up
/// the context for the post process, so children can know if they are being
/// rendered within a post process by using
/// [PostProcessingContextFinder.findPostProcessFromContext].
///
/// The subtree of a post process is the children of the owner, if it is a
/// [PostProcessComponent], or the [World] if
/// the owner is a [CameraComponent]. When using a
/// [PostProcessSequentialGroup], the subtree also includes the preceding
/// post processes in the group.
///
/// Another useful method is [rasterizeSubtree], which will render the component
/// tree to an image. This is useful for using such image as a texture in
/// a shader.
///
/// Post process can be combined using [PostProcessGroup] or
/// [PostProcessSequentialGroup] to build a chain of post processes.
///
/// Post processes can be used via [CameraComponent.postProcess] or
/// [PostProcessComponent].
///
/// A post process may even render a subtree multiple times if it needs to.
/// In addition, if children check for
/// [PostProcessingContextFinder.findPostProcessFromContext],
/// they may even render differently in each render pass.
/// Ideal for mask textures.
///
/// See also:
/// - [PostProcessComponent] for a component that applies a post process
/// - [PostProcessGroup] for a group of post processes that will be applied
///   in parallel
/// - [PostProcessSequentialGroup] for a group of post processes that will be
///   applied in sequence
/// - [FragmentProgram] for a way to create post processes using fragment
///   shaders
/// - [PostProcessingContextFinder] for a way to access the post process
///   context from within a component during rendering
abstract class PostProcess {
  PostProcess({double? pixelRatio})
    : pixelRatio =
          pixelRatio ??
          PlatformDispatcher.instance.views.first.devicePixelRatio;

  /// The pixel ratio of the screen. This is used to scale the image generated
  /// by  [rasterizeSubtree] to the correct size.
  ///
  /// Defaults to [FlutterView.devicePixelRatio].
  double pixelRatio;

  /// Similarly to components, post processes can be loaded asynchronously.
  ///
  /// Use this to load any resources needed for the post process. This is called
  /// when the post process is added to a [CameraComponent] or a
  /// [PostProcessComponent].
  ///
  /// See also:
  /// - [Component.onLoad] for more information on how to load components.
  FutureOr<void> onLoad() {}

  /// This method is called every frame to update the post process.
  ///
  /// Use this to update any state that needs to be updated every frame.
  /// This is called after the [update] method of the [Component] class.
  ///
  /// An example of usage is to update the time uniform of a shader.
  void update(double dt) {}

  void Function(Canvas)? _renderTree;
  void Function(PostProcess?)? _updateContext;
  Vector2? _size;

  /// This method is called to render the post process, to be called by the
  /// "owner" of
  /// the post process, like a [CameraComponent] or a [PostProcessComponent].
  @internal
  void render(
    Canvas canvas,
    Vector2 size,
    ValueSetter<Canvas> renderTree,
    ValueSetter<PostProcess?> updateContext,
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

  /// One of the two methods that subclasses should invoke to render the
  /// what is considered the "subtree" of the post process.
  ///
  /// Differently from [renderSubtree], this method will rasterize the
  /// subtree to an image, which can be used as a texture in a shader. This
  /// is an expensive operation, so it should be used sparingly.
  ///
  /// This method will set the context of the post process, so that
  /// components can know they are being rendered within a post process.
  @nonVirtual
  @protected
  ui.Image rasterizeSubtree() {
    final recorder = PictureRecorder();
    final innerCanvas = Canvas(recorder);

    renderSubtree(innerCanvas);

    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(
        (pixelRatio * _size!.x).ceil(),
        (pixelRatio * _size!.y).ceil(),
      );
    } finally {
      picture.dispose();
    }
  }

  /// One of the two methods that subclasses should invoke to render the
  /// what is considered the "subtree" of the post process.
  ///
  /// This method will set the context of the post process, so that
  /// components can know they are being rendered within a post process.
  /// See [PostProcessingContextFinder.findPostProcessFromContext].
  @nonVirtual
  @protected
  void renderSubtree(Canvas canvas) {
    canvas.save();
    _updateContext!(this);
    _renderTree!(canvas);
    _updateContext!(null);
    canvas.restore();
  }

  /// There the effects of the post process are applied. This is where you
  /// should implement the logic of the post process. Including eventual calls
  /// to [rasterizeSubtree] and [renderSubtree].
  ///
  /// If neither is called the post process will not render anything apart from
  /// what is implemented in this method.
  void postProcess(Vector2 size, Canvas canvas) {
    renderSubtree(canvas);
  }
}

/// A special type of [PostProcess] that is used to group multiple post
/// processes together. This is useful for applying multiple post processes
/// at once.
///
/// Beware that all elements in [postProcesses] will be rendered with the same
/// "subtree", sof if more than one item calls [renderSubtree], the subtree
/// will be rendered multiple times. If multiple post processes need to call
/// [rasterizeSubtree] or [renderSubtree], consider using
/// [PostProcessSequentialGroup].
///
/// In other words, the subtree of the group post process will be shared in
/// parallel with all the post processes in the group.
///
/// See also:
/// - [PostProcess] for a single post process and more information on what
/// is the "subtree" of a post process.
/// - [PostProcessSequentialGroup] for a group of post processes that will be
/// applied in sequence where each post process will be considered part of the
/// subtree of the next one.
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
    ValueSetter<Canvas> renderTree,
    ValueSetter<PostProcess?> updateContext,
  ) {
    for (final postProcess in postProcesses) {
      postProcess.render(canvas, size, renderTree, updateContext);
    }
  }
}

/// A special type of [PostProcess] that is used to group multiple post
/// processes together. This is useful for applying multiple post processes
/// at once, but in a sequential manner.
///
/// This means that each post process will be considered part of the subtree
/// of the next one. This is useful for post processes that need to be
/// rendered in a specific order, or that need to share the same subtree.
///
/// In other words, the subtree of the group post process will be the subtree of
/// the first post process in the group, and all the other post processes
/// will be rendered with the same subtree.
///
/// See also:
/// - [PostProcess] for a single post process and more information on what
/// is the "subtree" of a post process.
/// - [PostProcessGroup] for a group of post processes that will be applied
/// in parallel where all the post processes will be rendered with the same
/// subtree.
class PostProcessSequentialGroup extends PostProcessGroup {
  PostProcessSequentialGroup({
    required super.postProcesses,
  });

  @override
  void render(
    Canvas canvas,
    Vector2 size,
    ValueSetter<Canvas> renderTree,
    ValueSetter<PostProcess?> updateContext,
  ) {
    // Build the stack of post processes in reverse order
    final stack = postProcesses.reversed.toList();

    // Start with the original renderTree
    void runNext(Canvas c) {
      if (stack.isEmpty) {
        renderTree(c);
        return;
      }

      final postProcess = stack.removeAt(0);
      postProcess.render(c, size, runNext, updateContext);
    }

    canvas.save();
    runNext(canvas);
    canvas.restore();
  }
}
