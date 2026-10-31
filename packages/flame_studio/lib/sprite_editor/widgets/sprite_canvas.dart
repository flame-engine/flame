import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/bloc/sprite_editor_cubit.dart';
import 'package:flame_studio/sprite_editor/widgets/sprite_painter.dart';
import 'package:flame_studio/sprite_editor/widgets/sprite_view_transform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sprite_canvas}
/// The canvas of the sprite editor. It shows the image of the sprite, and
/// the user selects a region of it by dragging on the image, moves the
/// region by dragging it, and resizes it with its handles. Scrolling pans
/// the image.
///
/// It decodes the image, and tells the [SpriteEditorCubit] about its size.
/// {@endtemplate}
class const SpriteCanvas({super.key}) extends StatefulWidget {
  /// {@macro sprite_canvas}
  this;

  /// The background of the canvas, the same as the preview's.
  static const backgroundColor = Color(0xFF1E1E1E);

  @override
  State<SpriteCanvas> createState() => _SpriteCanvasState();
}

class _SpriteCanvasState() extends State<SpriteCanvas> {
  ui.Image? _image;
  Uint8List? _decoding;

  // The drag in progress: the handle that is dragged, or whether the region
  // is moved, or else a new region is being selected from where it started.
  SpriteRegionHandle? _draggedHandle;
  bool _isMoving = false;
  Offset _dragStart = Offset.zero;
  Rect _dragRegion = Rect.zero;
  MouseCursor _cursor = MouseCursor.defer;

  SpriteEditorCubit get _cubit => context.read<SpriteEditorCubit>();

  Rect get _region {
    final ComponentSprite(:srcPosition, :srcSize) = _cubit.state.sprite;
    return Rect.fromLTWH(
      srcPosition.x,
      srcPosition.y,
      srcSize.width,
      srcSize.height,
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_decode(_cubit.state.bytes));
  }

  @override
  void dispose() {
    _decoding = null;
    _image?.dispose();
    super.dispose();
  }

  Future<void> _decode(Uint8List? bytes) async {
    _decoding = bytes;
    final previous = _image;
    setState(() => _image = null);
    previous?.dispose();
    if (bytes == null) {
      return;
    }
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      final image = frame.image;
      // Another image may have been picked meanwhile.
      if (!mounted || !identical(_decoding, bytes)) {
        image.dispose();
        return;
      }
      setState(() => _image = image);
      _cubit.imageDecoded(image.width, image.height);
    } on Exception {
      if (mounted && identical(_decoding, bytes)) {
        _cubit.imageFailed();
      }
    }
  }

  void _onPanStart(DragStartDetails details, SpriteViewTransform transform) {
    final point = details.localPosition;
    final region = _region;
    final imagePoint = transform.toImage(point);
    _dragStart = imagePoint;
    _dragRegion = region;
    _draggedHandle = transform.handleAt(region, point);
    _isMoving = _draggedHandle == null && region.contains(imagePoint);
  }

  void _onPanUpdate(DragUpdateDetails details, SpriteViewTransform transform) {
    final point = transform.toImage(details.localPosition);
    final handle = _draggedHandle;
    if (_isMoving) {
      final moved = _dragRegion.topLeft + point - _dragStart;
      _cubit.regionMoved(moved.dx, moved.dy);
      return;
    }
    final region = handle != null
        ? handle.dragged(_dragRegion, point)
        : Rect.fromPoints(_dragStart, point);
    final image = _image;
    if (image == null) {
      return;
    }
    // Clipped here so that a selection dragged past the side of the image
    // keeps its other side where it is.
    final clipped = region.intersect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );
    _cubit.regionChanged(
      clipped.left,
      clipped.top,
      clipped.width,
      clipped.height,
    );
  }

  void _onHover(PointerHoverEvent event, SpriteViewTransform transform) {
    final point = event.localPosition;
    final handle = transform.handleAt(_region, point);
    final cursor = switch (handle) {
      SpriteRegionHandle.top ||
      SpriteRegionHandle.bottom => SystemMouseCursors.resizeUpDown,
      SpriteRegionHandle.left ||
      SpriteRegionHandle.right => SystemMouseCursors.resizeLeftRight,
      SpriteRegionHandle.topLeft || SpriteRegionHandle.bottomRight =>
        SystemMouseCursors.resizeUpLeftDownRight,
      SpriteRegionHandle.topRight ||
      SpriteRegionHandle.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
      null when _region.contains(transform.toImage(point)) =>
        SystemMouseCursors.move,
      null => SystemMouseCursors.precise,
    };
    if (cursor != _cursor) {
      setState(() => _cursor = cursor);
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _cubit.panned(-event.scrollDelta.dx, -event.scrollDelta.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpriteEditorCubit, SpriteEditorState>(
      listenWhen: (previous, current) =>
          !identical(previous.bytes, current.bytes),
      listener: (context, state) => unawaited(_decode(state.bytes)),
      child: ColoredBox(
        color: SpriteCanvas.backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = _image;
            final state = context.watch<SpriteEditorCubit>().state;
            if (state.isImageInvalid) {
              return const Center(child: Text('The image could not be read'));
            }
            if (image == null) {
              return Center(
                child: Text(
                  state.sprite.image == null
                      ? 'Select an image from the list'
                      : 'Loading image…',
                ),
              );
            }
            final size = constraints.biggest;
            final transform =
                SpriteViewTransform.fit(
                      Size(image.width.toDouble(), image.height.toDouble()),
                      size,
                    )
                    .zoomed(state.zoom, size.center(Offset.zero))
                    .panned(Offset(state.panX, state.panY));
            return Listener(
              onPointerSignal: _onPointerSignal,
              onPointerPanZoomUpdate: (event) =>
                  _cubit.panned(event.panDelta.dx, event.panDelta.dy),
              child: MouseRegion(
                cursor: _cursor,
                onHover: (event) => _onHover(event, transform),
                child: GestureDetector(
                  // Trackpad scrolling pans instead of dragging.
                  supportedDevices: const {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.touch,
                  },
                  // Drags start where the pointer went down.
                  dragStartBehavior: DragStartBehavior.down,
                  onPanStart: (details) => _onPanStart(details, transform),
                  onPanUpdate: (details) => _onPanUpdate(details, transform),
                  child: CustomPaint(
                    size: size,
                    painter: SpritePainter(
                      image: image,
                      region: _region,
                      transform: transform,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
